import json
import os
import tempfile
import threading
import unittest
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from unittest.mock import patch

from verification_api import VerificationApiServer
from verification_store import VerificationStore


class VerificationApiTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.code_number = 123455
        self.store = VerificationStore(
            Path(self.temp_dir.name) / "codes.sqlite3",
            ttl_seconds=60,
            code_factory=self._next_code,
        )
        api_store = VerificationStore(
            Path(self.temp_dir.name) / "codes.sqlite3",
            ttl_seconds=60,
        )
        with patch.dict(os.environ, {"TELEGRAM_APP_ORIGINS": ""}):
            self.server = VerificationApiServer(("127.0.0.1", 0), api_store)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.url = f"http://127.0.0.1:{self.server.server_port}/verify-code"

    def tearDown(self) -> None:
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp_dir.cleanup()

    def _next_code(self) -> str:
        self.code_number += 1
        return str(self.code_number)

    def _request(
        self,
        code: str,
        origin: str = "http://localhost:3000",
    ) -> tuple[int, dict[str, object], dict[str, str]]:
        request = Request(
            self.url,
            data=json.dumps({"code": code}).encode("utf-8"),
            headers={
                "Content-Type": "application/json",
                "Origin": origin,
            },
            method="POST",
        )
        try:
            response = urlopen(request, timeout=5)
        except HTTPError as error:
            response = error
        with response:
            return (
                response.status,
                json.loads(response.read()),
                dict(response.headers.items()),
            )

    def test_api_accepts_active_bot_code_once(self) -> None:
        code = self.store.issue_code(42)

        status, payload, headers = self._request(code)
        self.assertEqual(status, 200)
        self.assertEqual(payload, {"valid": True})
        self.assertEqual(headers.get("Access-Control-Allow-Origin"), "http://localhost:3000")

        status, payload, _ = self._request(code)
        self.assertEqual(status, 409)
        self.assertEqual(payload.get("error"), "already_used")

    def test_api_rejects_invalid_code(self) -> None:
        status, payload, _ = self._request("000000")

        self.assertEqual(status, 400)
        self.assertEqual(payload.get("error"), "invalid_code")

    def test_api_allows_flutter_dev_origin_and_private_lan_origin(self) -> None:
        for origin in ("http://localhost:5173", "http://192.168.1.24:3000"):
            status, _, headers = self._request("000000", origin=origin)
            self.assertEqual(status, 400)
            self.assertEqual(headers.get("Access-Control-Allow-Origin"), origin)

    def test_health_endpoint_reports_ready(self) -> None:
        request = Request(
            self.url.replace("/verify-code", "/health"),
            headers={"Origin": "http://localhost:3000"},
        )
        with urlopen(request, timeout=5) as response:
            self.assertEqual(response.status, 200)
            self.assertEqual(
                json.loads(response.read()),
                {"ok": True, "service": "telegram-verification"},
            )


if __name__ == "__main__":
    unittest.main()