import os
import re
import secrets
import sqlite3
import time
from pathlib import Path
from typing import Callable


class VerificationStore:
    def __init__(
        self,
        database_path: str | Path | None = None,
        *,
        ttl_seconds: int = 600,
        clock: Callable[[], float] = time.time,
        code_factory: Callable[[], str] | None = None,
    ) -> None:
        if ttl_seconds <= 0:
            raise ValueError("ttl_seconds must be positive")
        self.database_path = Path(
            database_path
            or os.getenv(
                "TELEGRAM_CODES_DB",
                str(Path(__file__).with_name("telegram_verification.sqlite3")),
            )
        )
        self.ttl_seconds = ttl_seconds
        self._clock = clock
        self._code_factory = code_factory or (
            lambda: f"{secrets.randbelow(900000) + 100000:06d}"
        )
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        self._initialize()

    def _connect(self) -> sqlite3.Connection:
        connection = sqlite3.connect(self.database_path, timeout=10)
        connection.row_factory = sqlite3.Row
        return connection

    def _initialize(self) -> None:
        connection = self._connect()
        try:
            connection.execute(
                """
                CREATE TABLE IF NOT EXISTS telegram_codes (
                    code TEXT PRIMARY KEY,
                    chat_id TEXT NOT NULL,
                    created_at INTEGER NOT NULL,
                    expires_at INTEGER NOT NULL,
                    status TEXT NOT NULL CHECK (
                        status IN ('active', 'used', 'expired', 'replaced')
                    )
                )
                """
            )
            connection.execute(
                "CREATE INDEX IF NOT EXISTS telegram_codes_chat_id "
                "ON telegram_codes(chat_id)"
            )
            connection.commit()
        finally:
            connection.close()

    def issue_code(self, chat_id: int | str) -> str:
        now = int(self._clock())
        chat_id = str(chat_id)
        connection = self._connect()
        try:
            connection.execute("BEGIN IMMEDIATE")
            connection.execute(
                "UPDATE telegram_codes SET status = 'replaced' "
                "WHERE chat_id = ? AND status = 'active'",
                (chat_id,),
            )
            while True:
                code = self._code_factory()
                if not re.fullmatch(r"\d{6}", code):
                    raise ValueError("code_factory must return a six-digit code")
                try:
                    connection.execute(
                        "INSERT INTO telegram_codes "
                        "(code, chat_id, created_at, expires_at, status) "
                        "VALUES (?, ?, ?, ?, 'active')",
                        (code, chat_id, now, now + self.ttl_seconds),
                    )
                    break
                except sqlite3.IntegrityError:
                    continue
            connection.commit()
            return code
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()

    def verify_code(self, code: str) -> str:
        clean_code = code.strip()
        if not re.fullmatch(r"\d{6}", clean_code):
            return "invalid_code"

        now = int(self._clock())
        connection = self._connect()
        try:
            connection.execute("BEGIN IMMEDIATE")
            row = connection.execute(
                "SELECT expires_at, status FROM telegram_codes WHERE code = ?",
                (clean_code,),
            ).fetchone()
            if row is None or row["status"] == "replaced":
                result = "invalid_code"
            elif row["status"] == "used":
                result = "already_used"
            elif row["status"] == "expired" or row["expires_at"] <= now:
                connection.execute(
                    "UPDATE telegram_codes SET status = 'expired' WHERE code = ?",
                    (clean_code,),
                )
                result = "expired_code"
            else:
                cursor = connection.execute(
                    "UPDATE telegram_codes SET status = 'used' "
                    "WHERE code = ? AND status = 'active' AND expires_at > ?",
                    (clean_code, now),
                )
                result = "verified" if cursor.rowcount == 1 else "already_used"
            connection.commit()
            return result
        except Exception:
            connection.rollback()
            raise
        finally:
            connection.close()