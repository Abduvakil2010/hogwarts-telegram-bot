import os
import re

from dotenv import load_dotenv
from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, MessageHandler, filters
from verification_store import VerificationStore

# .env faylini yuklash
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
BOT_USERNAME = os.getenv("TELEGRAM_BOT_USERNAME", "HogwartsEduBot")

VERIFICATION_STORE = VerificationStore()


async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.effective_chat is None or update.message is None:
        return

    user_id = update.effective_chat.id
    code = VERIFICATION_STORE.issue_code(user_id)

    await update.message.reply_html(
        f"Assalomu alaykum!\n\n"
        f"Sizning 6 xonali tasdiqlash kodingiz: <b>{code}</b>\n\n"
        f"Ushbu kodni HOGWARTS ilovasidagi Telegram ID maydoniga kiriting.\n"
        f"Kod 10 daqiqa amal qiladi. Yangi kod olish uchun /start ni qayta bosing."
    )


async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.message is None:
        return

    await update.message.reply_text(
        "Botdan 6 xonali tasdiqlash kodi olish uchun /start buyrug'ini bosing.\n"
        "Keyin shu kodni HOGWARTS ilovasiga kiriting."
    )


async def handle_text(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if update.effective_chat is None or update.message is None:
        return

    text = update.message.text.strip()
    if re.fullmatch(r"\d{6}", text):
        await update.message.reply_text(
            "Kodni HOGWARTS ilovasidagi tasdiqlash maydoniga kiriting. "
            "Botga yuborish kodni tasdiqlamaydi."
        )
        return

    await update.message.reply_text(
        "Iltimos, faqat 6 xonali raqamli kod kiriting yoki /start buyrug'ini bosing."
    )


def main() -> None:
    if not TOKEN:
        raise RuntimeError(
            "TELEGRAM_BOT_TOKEN topilmadi. bot/.env faylini yarating va TOKENni o'rnating."
        )

    application = ApplicationBuilder().token(TOKEN).build()
    application.add_handler(CommandHandler("start", start_command))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(
        MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text)
    )

    print(f"Telegram bot ishga tushdi: @{BOT_USERNAME}")

    import asyncio

    asyncio.set_event_loop(asyncio.new_event_loop())
application.run_polling(stop_signals=None)