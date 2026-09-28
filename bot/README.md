# Hogwarts Telegram Bot

Bot `/start` buyrug'ida 6 xonali tasdiqlash kodi beradi. Kodlar bot va alohida verification API serveri foydalanadigan SQLite bazasida saqlanadi.

## 1) O'rnatish

```bash
cd bot
python -m venv .venv
source .venv/Scripts/activate  # Git Bash on Windows
pip install -r requirements.txt
```

## 2) Token sozlash

`bot/.env` faylini yaratib quyidagilarni kiriting:

```env
TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN
TELEGRAM_BOT_USERNAME=HogwartsEduBot
```

Mumkin bo'lsa, `.env.example` dan nusxa ko'chiring.

## 3) Verification API serverini ishga tushirish

```bash
python start_server.py
```

Server `http://127.0.0.1:8000/health` health endpointini va `POST /verify-code` tasdiqlash endpointini taqdim etadi. Startup terminali telefon uchun kompyuterning LAN IP manzilini ham ko'rsatadi. API Python standart kutubxonasidan foydalanadi; qo'shimcha web framework dependency talab qilinmaydi.

## 4) Telegram botini alohida terminalda ishga tushirish

```bash
python telegram_bot.py
```

Botga `/start` yuborilsa, 6 xonali kod keladi. Kod 10 daqiqada tugaydi; `/start` ni qayta bosish oldingi kodni bekor qiladi. Bot va API bir xil `telegram_verification.sqlite3` bazasini ishlatadi. Telegram `getUpdates` uchun faqat bitta bot nusxasini ishga tushiring; API alohida process bo'lgani uchun bot polling'iga xalaqit bermaydi.

Flutter web app standart holatda `http://127.0.0.1:8000` dan foydalanadi. Dev server localhost va private LAN originlariga CORS ruxsat beradi. Production uchun `TELEGRAM_APP_ORIGINS` ga aniq originlar ro'yxatini kiriting.

Android emulator uchun:

```bash
flutter run --dart-define=TELEGRAM_API_BASE_URL=http://10.0.2.2:8000
```

Jismoniy telefon uchun Flutter'ga server terminalida ko'rsatilgan kompyuter LAN IP manzilini bering, masalan `--dart-define=TELEGRAM_API_BASE_URL=http://192.168.1.24:8000`. Telefon va kompyuter bir Wi-Fi'da bo'lsin va Windows Firewall Python uchun Private network'ga ruxsat bersin.

Production'da HTTPS va persistent storage ishlating. Telegram bot tokenini Flutter'ga qo'shmang. Kodlar bazasi `TELEGRAM_CODES_DB` bilan o'zgartirilishi mumkin.

## Testlar

```bash
python -m unittest -v test_verification_store test_verification_api
```
