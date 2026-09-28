from pathlib import Path

from dotenv import load_dotenv

from verification_api import serve_api
from verification_store import VerificationStore


def main() -> None:
    load_dotenv(Path(__file__).with_name(".env"))
    serve_api(VerificationStore())


if __name__ == "__main__":
    main()