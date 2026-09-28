import tempfile
import unittest
from pathlib import Path

from verification_store import VerificationStore


class VerificationStoreTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp_dir = tempfile.TemporaryDirectory()
        self.now = 1_000
        self.codes = iter(("123456", "654321"))
        self.store = VerificationStore(
            Path(self.temp_dir.name) / "codes.sqlite3",
            ttl_seconds=60,
            clock=lambda: self.now,
            code_factory=lambda: next(self.codes),
        )

    def tearDown(self) -> None:
        self.temp_dir.cleanup()

    def test_code_can_be_verified_only_once(self) -> None:
        code = self.store.issue_code(42)

        self.assertEqual(code, "123456")
        self.assertEqual(self.store.verify_code(code), "verified")
        self.assertEqual(self.store.verify_code(code), "already_used")

    def test_code_expires(self) -> None:
        code = self.store.issue_code(42)
        self.now += 60

        self.assertEqual(self.store.verify_code(code), "expired_code")

    def test_new_code_replaces_previous_active_code(self) -> None:
        old_code = self.store.issue_code(42)
        new_code = self.store.issue_code(42)

        self.assertEqual(self.store.verify_code(old_code), "invalid_code")
        self.assertEqual(self.store.verify_code(new_code), "verified")

    def test_malformed_code_is_rejected(self) -> None:
        self.assertEqual(self.store.verify_code("12a456"), "invalid_code")


if __name__ == "__main__":
    unittest.main()