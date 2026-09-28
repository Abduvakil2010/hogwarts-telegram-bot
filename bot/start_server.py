import threading
from pathlib import Path

from dotenv import load_dotenv

from verification_api import serve_api
from verification_store import VerificationStore
import telegram_bot


def main() -> None:
    load_dotenv(Path(__file__).with_name(".env"))

    store = VerificationStore()

    # Bot va API bir xil verification store'dan foydalanadi
    telegram_bot.VERIFICATION_STORE = store

    # Telegram botni alohida thread'da ishga tushirish
    bot_thread = threading.Thread(
        target=telegram_bot.main,
        daemon=True,
    )
    bot_thread.start()

    # API asosiy thread'da ishlaydi
    serve_api(store)


if __name__ == "__main__":
    main()