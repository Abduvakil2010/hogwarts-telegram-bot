import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_styles.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/user_model.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';

import '../../data/repositories/database_repository.dart';
import 'auth_provider.dart';
import 'auth_success_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final DatabaseRepository _db = DatabaseRepository();
  String? _selectedSubjectId;
  String? _errorText;

  final TextEditingController _newSubjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final subjects = _db.getSubjects();
    if (subjects.isNotEmpty) {
      _selectedSubjectId = subjects.first.subjectId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newSubjectController.dispose();
    super.dispose();
  }

  void _showAddSubjectDialog() {
    final l10n = AppLocalizations.of(context);
    _newSubjectController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.createNewSubject,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: TextField(
          controller: _newSubjectController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.selectSubjectHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _newSubjectController.text.trim();
              if (name.isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final navigator = Navigator.of(ctx);
                final newSub = await _db.createSubject(name, auth.enteredTelegramId);
                setState(() {
                  _selectedSubjectId = newSub.subjectId;
                });
                navigator.pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegistration() async {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorText = l10n.requiredField;
      });
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.setFullName(name);
    if (_selectedSubjectId != null) {
      auth.setSelectedSubjectId(_selectedSubjectId!);
    }

    final success = await auth.completeRegistration();
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthSuccessScreen(),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
        (route) => false,
      );
    } else if (mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjects = _db.getSubjects();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                '${auth.selectedRole == UserRole.teacher ? l10n.teacher : l10n.student} ${l10n.registerButton}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ma’lumotlaringizni to‘ldiring',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 28),

              // Full Name input with "* Majburiy"
              CustomTextField(
                label: l10n.enterFullName,
                hintText: l10n.fullNameHint,
                controller: _nameController,
                isRequired: true,
                errorText: _errorText,
                prefixIcon: const Icon(Icons.person_outline, size: 22),
                onChanged: (_) {
                  if (_errorText != null) {
                    setState(() => _errorText = null);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  l10n.requiredField,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Subject Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.selectSubject,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (auth.selectedRole == UserRole.teacher)
                    TextButton.icon(
                      onPressed: _showAddSubjectDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(
                        l10n.createNewSubject,
                        style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: AppStyles.roundedMedium,
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1.2,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubjectId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    items: subjects.map((sub) {
                      return DropdownMenuItem<String>(
                        value: sub.subjectId,
                        child: Text(sub.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedSubjectId = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 48),

              CustomButton(
                text: l10n.registerButton,
                isLoading: auth.isLoading,
                onPressed: _submitRegistration,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
