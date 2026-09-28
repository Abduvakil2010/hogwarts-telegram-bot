# Hogwarts

## Ishga tushirish (Windows, Git Bash)

Loyiha VS Code terminali uchun Git Bash profilidan foydalanadi. Yangi terminal oching; agar oldin ochilgan PowerShell terminali turgan bo'lsa, uni yoping va yangisini oching. Sozlama Git Bash'ni ishga tushiradi va Flutter SDK'ni PATH'ga qo'shadi.

Bot va verification API'ni ikkita alohida CMD yoki Git Bash terminalida ishga tushiring. Birinchi terminalda API serverini boshlang:

```bash
cd /c/Users/user/Downloads/HOGWARTS/bot
python start_server.py
```

API terminalda `http://127.0.0.1:8000` va mavjud LAN IP manzillarini ko'rsatadi. `http://127.0.0.1:8000/health` manzili `ok` qaytarishi kerak. API va bot bir xil `bot/telegram_verification.sqlite3` bazasidan foydalanadi.

Ikkinchi terminalda Telegram botni boshlang:

```bash
cd /c/Users/user/Downloads/HOGWARTS/bot
python telegram_bot.py
```

`bot/.env` ichida `TELEGRAM_BOT_TOKEN` sozlangan bo'lishi kerak. `requirements.txt` faqat botning Python paketlarini o'rnatadi; API Python standart kutubxonasi bilan ishlaydi. Bir bot tokeni uchun faqat bitta bot polling nusxasini ishga tushiring.

Keyin boshqa terminalda Flutter ilovasini ishga tushiring:

```bash
cd /c/Users/user/Downloads/HOGWARTS
flutter pub get
flutter test test/widget_test.dart
flutter run -d web-server --web-port=3000
```

Chrome'da `http://localhost:3000` ni oching. Tasdiqlash ekranida Telegram botni ochib `/start` bosing; bot yuborgan kod 10 daqiqa amal qiladi va bir marta ishlatiladi.

Android emulator uchun:

```bash
flutter run --dart-define=TELEGRAM_API_BASE_URL=http://10.0.2.2:8000
```

Jismoniy Android telefon uchun API URL'da server terminali chiqargan kompyuterning LAN IPv4 manzilini ishlating. Masalan:

```bash
flutter run --dart-define=TELEGRAM_API_BASE_URL=http://192.168.1.24:8000
```

Telefon va kompyuter bir Wi-Fi tarmog'ida bo'lishi, Windows Firewall esa Python'ga Private network uchun ruxsat berishi kerak. Chrome/Web'da ilova `localhost:3000` dan ochilsa, standart API URL to'g'ri. Release deploy uchun HTTPS ishlating; tokenni faqat serverdagi `bot/.env` faylida saqlang.

Python backend testlari:

```bash
cd /c/Users/user/Downloads/HOGWARTS/bot
source .venv/Scripts/activate
python -m unittest -v test_verification_store test_verification_api
```
