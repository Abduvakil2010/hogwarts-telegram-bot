import json
import ipaddress
import os
import socket
import threading
import time
from collections import defaultdict, deque
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any
from urllib.parse import urlsplit

from verification_store import VerificationStore


class _RateLimiter:
    def __init__(self, limit: int = 10, window_seconds: int = 600) -> None:
        self.limit = limit
        self.window_seconds = window_seconds
        self._attempts: dict[str, deque[float]] = defaultdict(deque)
        self._lock = threading.Lock()

    def allow(self, key: str) -> bool:
        now = time.monotonic()
        with self._lock:
            attempts = self._attempts[key]
            while attempts and now - attempts[0] >= self.window_seconds:
                attempts.popleft()
            if len(attempts) >= self.limit:
                return False
            attempts.append(now)
            return True

    def clear(self, key: str) -> None:
        with self._lock:
            self._attempts.pop(key, None)


class VerificationApiServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(
        self,
        address: tuple[str, int],
        store: VerificationStore,
        allowed_origins: set[str] | None = None,
    ) -> None:
        super().__init__(address, _VerificationRequestHandler)
        self.store = store
        configured_origins = os.getenv("TELEGRAM_APP_ORIGINS")
        self.allowed_origins = (
            allowed_origins
            if allowed_origins is not None
            else {
                origin.strip()
                for origin in (configured_origins or "").split(",")
                if origin.strip()
            }
        )
        self.allow_local_network_origins = (
            allowed_origins is None and not configured_origins
        )
        self.rate_limiter = _RateLimiter()


class _VerificationRequestHandler(BaseHTTPRequestHandler):
    server: VerificationApiServer

    def do_GET(self) -> None:
        if urlsplit(self.path).path == "/health":
            self._send_json(200, {"ok": True, "service": "telegram-verification"})
            return
        self._send_json(404, {"valid": False, "error": "not_found"})

    def do_OPTIONS(self) -> None:
        if urlsplit(self.path).path != "/verify-code":
            self._send_json(404, {"valid": False, "error": "not_found"})
            return
        self.send_response(204)
        self._send_cors_headers()
        self.end_headers()

    def do_POST(self) -> None:
        if urlsplit(self.path).path != "/verify-code":
            self._send_json(404, {"valid": False, "error": "not_found"})
            return

        try:
            content_length = int(self.headers.get("Content-Length", "0"))
            if content_length <= 0 or content_length > 4096:
                raise ValueError("invalid body size")
            payload: Any = json.loads(self.rfile.read(content_length))
            if not isinstance(payload, dict) or not isinstance(payload.get("code"), str):
                raise ValueError("code must be a string")
        except (ValueError, json.JSONDecodeError):
            self._send_json(400, {"valid": False, "error": "invalid_request"})
            return

        client_ip = self.client_address[0]
        if not self.server.rate_limiter.allow(client_ip):
            self._send_json(429, {"valid": False, "error": "too_many_attempts"})
            return

        result = self.server.store.verify_code(payload["code"])
        if result == "verified":
            self.server.rate_limiter.clear(client_ip)
            self._send_json(200, {"valid": True})
        else:
            status = {
                "invalid_code": 400,
                "already_used": 409,
                "expired_code": 410,
            }.get(result, 400)
            self._send_json(status, {"valid": False, "error": result})

    def _send_json(self, status: int, payload: dict[str, Any]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self._send_cors_headers()
        self.end_headers()
        self.wfile.write(body)

    def _send_cors_headers(self) -> None:
        origin = self.headers.get("Origin")
        if origin and self._is_allowed_origin(origin):
            self.send_header("Access-Control-Allow-Origin", origin)
            self.send_header("Vary", "Origin")
            self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def _is_allowed_origin(self, origin: str) -> bool:
        if origin in self.server.allowed_origins:
            return True
        if not self.server.allow_local_network_origins:
            return False
        try:
            parsed = urlsplit(origin)
            if parsed.scheme != "http" or not parsed.hostname:
                return False
            hostname = parsed.hostname.lower()
            if hostname == "localhost":
                return True
            address = ipaddress.ip_address(hostname)
            return address.is_loopback or address.is_private
        except ValueError:
            return False

    def log_message(self, format: str, *args: object) -> None:
        return


def create_server(store: VerificationStore) -> VerificationApiServer:
    host = os.getenv("TELEGRAM_API_HOST", "0.0.0.0")
    port = int(os.getenv("TELEGRAM_API_PORT", "8000"))
    return VerificationApiServer((host, port), store)


def serve_api(store: VerificationStore) -> None:
    server = create_server(store)
    host, port = server.server_address
    print(f"Telegram verification API listening on http://127.0.0.1:{port}")
    for address in _local_ipv4_addresses():
        print(f"Android phone API URL: http://{address}:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("Telegram verification API stopped")
    finally:
        server.server_close()


def _local_ipv4_addresses() -> list[str]:
    addresses: set[str] = set()
    primary_address = None
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as route_socket:
            route_socket.connect(("8.8.8.8", 80))
            primary_address = route_socket.getsockname()[0]
            if ipaddress.ip_address(primary_address).is_loopback:
                primary_address = None
    except OSError:
        pass
    try:
        for result in socket.getaddrinfo(socket.gethostname(), None, socket.AF_INET):
            address = result[4][0]
            if not ipaddress.ip_address(address).is_loopback:
                addresses.add(address)
    except OSError:
        pass
    if primary_address:
        addresses.discard(primary_address)
        return [primary_address, *sorted(addresses)]
    return sorted(addresses)