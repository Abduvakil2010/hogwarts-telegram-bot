import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/database_repository.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/telegram_verification_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseRepository _db = DatabaseRepository();
  final TelegramVerificationService _telegramVerificationService;

  UserModel? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;
  late final Future<void> _sessionRestoration;

  // Temporary registration form state
  UserRole _selectedRole = UserRole.student;
  String _enteredTelegramId = '';
  String _enteredFullName = '';
  String _selectedSubjectId = 'sub_math';

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<void> get sessionRestoration => _sessionRestoration;

  UserRole get selectedRole => _selectedRole;
  String get enteredTelegramId => _enteredTelegramId;
  String get enteredFullName => _enteredFullName;
  String get selectedSubjectId => _selectedSubjectId;

  AuthProvider({TelegramVerificationService? telegramVerificationService})
      : _telegramVerificationService =
            telegramVerificationService ?? TelegramVerificationService() {
    _sessionRestoration = _checkSavedSession();
  }

  Future<void> _checkSavedSession() async {
    try {
      await _db.initialize();

      final savedId = await LocalStorageService.getCurrentUserId();
      if (savedId != null) {
        _currentUser = _db.getUser(savedId);
      }
    } catch (_) {
      _currentUser = null;
      _errorMessage = 'session_restore_failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _telegramVerificationService.dispose();
    super.dispose();
  }

  void setSelectedRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void setTelegramId(String id) {
    _enteredTelegramId = id.trim();
    _errorMessage = null;
    notifyListeners();
  }

  void setFullName(String name) {
    _enteredFullName = name;
    notifyListeners();
  }

  void setSelectedSubjectId(String id) {
    _selectedSubjectId = id;
    notifyListeners();
  }

  Future<bool> verifyTelegramId() async {
    _errorMessage = null;

    if (!RegExp(r'^\d{6}$').hasMatch(_enteredTelegramId)) {
      _errorMessage = 'invalid_code';
      notifyListeners();
      return false;
    }

    try {
      await _telegramVerificationService.verifyCode(_enteredTelegramId);
      await _db.cacheVerifiedTelegramCode(_enteredTelegramId);
      notifyListeners();
      return true;
    } on TelegramVerificationException catch (error) {
      _errorMessage = error.code;
    } catch (_) {
      _errorMessage = 'verification_unavailable';
    }
    notifyListeners();
    return false;
  }

  Future<bool> completeRegistration() async {
    if (_enteredFullName.trim().isEmpty) {
      _errorMessage = 'required_field';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _db.registerUser(
        role: _selectedRole,
        telegramId: _enteredTelegramId,
        fullName: _enteredFullName,
        primarySubjectId: _selectedSubjectId,
      );
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> updateFullName(String newName) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(fullName: newName.trim());
    await _db.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _enteredTelegramId = '';
    _enteredFullName = '';
    await _db.logout();
    notifyListeners();
  }
}
