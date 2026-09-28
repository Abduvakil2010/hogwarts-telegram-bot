import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import 'auth_provider.dart';
import 'profile_setup_screen.dart';

class TelegramIdScreen extends StatefulWidget {
  const TelegramIdScreen({super.key});

  @override
  State<TelegramIdScreen> createState() => _TelegramIdScreenState();
}

class _TelegramIdScreenState extends State<TelegramIdScreen> {
  final TextEditingController _idController = TextEditingController();
  String? _localError;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _idController.text = auth.enteredTelegramId;
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  bool _validateAndStoreTelegramCode() {
    final text = _idController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (text.length != 6 || !RegExp(r'^\d{6}$').hasMatch(text)) {
      setState(() {
        _localError = AppLocalizations.of(context).invalidIdFormat;
      });
      return false;
    }

    auth.setTelegramId(text);
    setState(() => _localError = null);
    return true;
  }

  Future<void> _verifyAndProceed() async {
    if (!_validateAndStoreTelegramCode()) {
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isVerifying = true);
    final valid = await auth.verifyTelegramId();
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (!valid) {
      setState(() {
        _localError = switch (auth.errorMessage) {
          'expired_code' =>
            'Kod muddati tugagan. Botda /start ni qayta bosing.',
          'already_used' => 'Bu kod avval ishlatilgan. Botdan yangi kod oling.',
          'too_many_attempts' =>
            'Urinishlar ko‘payib ketdi. Biroz kutib qayta urinib ko‘ring.',
          'verification_unavailable' =>
            'Tasdiqlash serveriga ulanib bo‘lmadi. Bot serveri ishlayotganini tekshiring.',
          _ => 'Kod noto‘g‘ri. Botdan olingan 6 xonali kodni tekshiring.',
        };
      });
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProfileSetupScreen(),
        transitionsBuilder: (_, a, __, c) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
          child: c,
        ),
      ),
    );
  }

  Future<void> _openTelegramBot() async {
    const url = 'https://t.me/HogwartsEduApp_bot';
    final uri = Uri.parse(url);
    final opened = await canLaunchUrl(uri);
    var launched = false;
    if (opened) {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            launched
                ? 'Botda /start ni bosing. Yuborilgan kod 10 daqiqa amal qiladi.'
                : 'Telegram bot ochilmadi. @HogwartsEduApp_bot ni Telegramdan toping.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.enterTelegramId),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                l10n.enterTelegramId,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.telegramBotInfo,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // 6-digit numeric input
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                enabled: !_isVerifying,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.primaryBlue,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '000000',
                  hintStyle: GoogleFonts.outfit(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.darkCard : Colors.white,
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: AppStyles.roundedMedium,
                    borderSide: BorderSide(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppStyles.roundedMedium,
                    borderSide: const BorderSide(
                      color: AppColors.primaryLight,
                      width: 2.0,
                    ),
                  ),
                ),
                onChanged: (_) {
                  if (_localError != null) {
                    setState(() => _localError = null);
                  }
                },
              ),

              if (_localError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppColors.errorRed.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.errorRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _localError!,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(duration: 400.ms),
              ],

              const SizedBox(height: 24),

              // Get ID from Telegram Bot action
              Center(
                child: TextButton.icon(
                  onPressed: _isVerifying ? null : _openTelegramBot,
                  icon: const Icon(Icons.telegram,
                      color: Color(0xFF2AABEE), size: 22),
                  label: Text(
                    l10n.getIdFromBot,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '@HogwartsEduApp_bot',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.primaryLight : AppColors.primaryBlue,
                  ),
                ),
              ),

              const Spacer(),

              CustomButton(
                text: l10n.next,
                isLoading: _isVerifying,
                onPressed: _verifyAndProceed,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
