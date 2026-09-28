import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/student_profile_model.dart';
import '../models/teacher_profile_model.dart';
import '../models/subject_model.dart';
import '../models/group_model.dart';
import '../models/test_model.dart';
import '../models/test_result_model.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../models/point_transaction_model.dart';
import '../models/telegram_id_model.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';
import '../../core/utils/code_generator.dart';

class DatabaseRepository extends ChangeNotifier {
  static final DatabaseRepository _instance = DatabaseRepository._internal();
  factory DatabaseRepository() => _instance;
  DatabaseRepository._internal();

  final Uuid _uuid = const Uuid();

  // In-memory collections mirroring Firestore
  final Map<String, UserModel> _users = {};
  final Map<String, StudentProfileModel> _students = {};
  final Map<String, TeacherProfileModel> _teachers = {};
  final Map<String, TelegramIdModel> _telegramIds = {};
  final Map<String, SubjectModel> _subjects = {};
  final Map<String, GroupModel> _groups = {};
  final Map<String, TestModel> _tests = {};
  final Map<String, TestResultModel> _testResults = {};
  final Map<String, ProductModel> _products = {};
  final Map<String, PurchaseModel> _purchases = {};
  final List<PointTransactionModel> _pointTransactions = [];

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes database from local persistent cache or default seed data
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Load persisted users
    final usersData = await LocalStorageService.loadCollection('users');
    if (usersData != null && usersData.isNotEmpty) {
      for (var map in usersData) {
        final u = UserModel.fromMap(map);
        _users[u.id] = u;
      }
    }

    // Load persisted students
    final studentsData = await LocalStorageService.loadCollection('students');
    if (studentsData != null) {
      for (var map in studentsData) {
        final s = StudentProfileModel.fromMap(map);
        _students[s.userId] = s;
      }
    }

    // Load persisted teachers
    final teachersData = await LocalStorageService.loadCollection('teachers');
    if (teachersData != null) {
      for (var map in teachersData) {
        final t = TeacherProfileModel.fromMap(map);
        _teachers[t.userId] = t;
      }
    }

    // Load persisted telegram_ids
    final idsData = await LocalStorageService.loadCollection('telegram_ids');
    if (idsData != null) {
      for (var map in idsData) {
        final tid = TelegramIdModel.fromMap(map);
        _telegramIds[tid.code] = tid;
      }
    }

    // Load persisted groups
    final groupsData = await LocalStorageService.loadCollection('groups');
    if (groupsData != null) {
      for (var map in groupsData) {
        final g = GroupModel.fromMap(map);
        _groups[g.groupId] = g;
      }
    }

    // Load persisted tests
    final testsData = await LocalStorageService.loadCollection('tests');
    if (testsData != null) {
      for (var map in testsData) {
        final t = TestModel.fromMap(map);
        _tests[t.testId] = t;
      }
    }

    // Load test results
    final resultsData =
        await LocalStorageService.loadCollection('test_results');
    if (resultsData != null) {
      for (var map in resultsData) {
        final r = TestResultModel.fromMap(map);
        _testResults[r.resultId] = r;
      }
    }

    // Load products
    final productsData = await LocalStorageService.loadCollection('products');
    if (productsData != null) {
      for (var map in productsData) {
        final p = ProductModel.fromMap(map);
        _products[p.productId] = p;
      }
    }

    // Load purchases
    final purchasesData = await LocalStorageService.loadCollection('purchases');
    if (purchasesData != null) {
      for (var map in purchasesData) {
        final pr = PurchaseModel.fromMap(map);
        _purchases[pr.purchaseId] = pr;
      }
    }

    // Load point transactions
    final transData =
        await LocalStorageService.loadCollection('point_transactions');
    if (transData != null) {
      for (var map in transData) {
        _pointTransactions.add(PointTransactionModel.fromMap(map));
      }
    }

    // Load subjects
    final subjectsData = await LocalStorageService.loadCollection('subjects');
    if (subjectsData != null && subjectsData.isNotEmpty) {
      for (var map in subjectsData) {
        final s = SubjectModel.fromMap(map);
        _subjects[s.subjectId] = s;
      }
    } else {
      // Seed default subjects
      for (var s in SubjectModel.defaultSubjects) {
        _subjects[s.subjectId] = s;
      }
    }

    // Seed default Telegram IDs if empty (e.g. 583214 as requested in prompt)
    if (_telegramIds.isEmpty) {
      _seedDefaultData();
    }

    _isInitialized = true;
    notifyListeners();
  }

  void _seedDefaultData() {
    // Standard prompt ID
    const seedCodes = [
      '583214',
      '749201',
      '123456',
      '884920',
      '654321',
      '999888'
    ];
    for (var code in seedCodes) {
      _telegramIds[code] = TelegramIdModel(
        id: _uuid.v4(),
        code: code,
        status: 'active',
        createdAt: DateTime.now(),
      );
    }

    // Seed a sample Teacher for immediate out-of-the-box readiness
    const teacherId = 'teacher_demo_01';
    final teacherUser = UserModel(
      id: teacherId,
      role: UserRole.teacher,
      fullName: 'Azizbek Aliyev',
      telegramId: '999888',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );
    _users[teacherId] = teacherUser;
    _teachers[teacherId] = TeacherProfileModel(
      userId: teacherId,
      groupIds: ['grp_math_101', 'grp_eng_ielts'],
      subjectIds: ['sub_math', 'sub_eng'],
    );

    // Seed Sample Groups
    final group1 = GroupModel(
      groupId: 'grp_math_101',
      teacherId: teacherId,
      teacherName: 'Azizbek Aliyev',
      name: 'Matematika 101',
      subjectId: 'sub_math',
      subjectName: 'Matematika',
      groupCode: 'MAT-7K29',
      studentIds: ['student_demo_01', 'student_demo_02', 'student_demo_03'],
      description: 'Algebra va geometriya asoslari guruhi',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    );

    final group2 = GroupModel(
      groupId: 'grp_eng_ielts',
      teacherId: teacherId,
      teacherName: 'Azizbek Aliyev',
      name: 'IELTS Intensive',
      subjectId: 'sub_eng',
      subjectName: 'Ingliz tili',
      groupCode: 'ENG-9X42',
      studentIds: ['student_demo_01', 'student_demo_02'],
      description: 'Band 7.5+ tayyorgarlik kursi',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );
    _groups[group1.groupId] = group1;
    _groups[group2.groupId] = group2;

    // Seed Sample Students for Leaderboard ranking
    final student1 = UserModel(
      id: 'student_demo_01',
      role: UserRole.student,
      fullName: 'Abdulloh Mahmudov',
      telegramId: '123456',
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    );
    final student2 = UserModel(
      id: 'student_demo_02',
      role: UserRole.student,
      fullName: 'Muhammad Yoqubov',
      telegramId: '749201',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    );
    final student3 = UserModel(
      id: 'student_demo_03',
      role: UserRole.student,
      fullName: 'Aziz Karimov',
      telegramId: '884920',
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now(),
    );
    _users[student1.id] = student1;
    _users[student2.id] = student2;
    _users[student3.id] = student3;

    _students[student1.id] = StudentProfileModel(
      userId: student1.id,
      groupIds: ['grp_math_101', 'grp_eng_ielts'],
      totalPoints: 450,
    );
    _students[student2.id] = StudentProfileModel(
      userId: student2.id,
      groupIds: ['grp_math_101', 'grp_eng_ielts'],
      totalPoints: 390,
    );
    _students[student3.id] = StudentProfileModel(
      userId: student3.id,
      groupIds: ['grp_math_101'],
      totalPoints: 350,
    );

    // Seed Sample Tests
    final test1 = TestModel(
      testId: 'test_algebra_01',
      teacherId: teacherId,
      groupId: 'grp_math_101',
      groupName: 'Matematika 101',
      subjectId: 'sub_math',
      subjectName: 'Matematika',
      title: 'Algebra №1 — Chiziqli tenglamalar',
      imageUrl:
          'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800&auto=format&fit=crop&q=80',
      questionCount: 5,
      correctAnswers: {1: 'A', 2: 'C', 3: 'B', 4: 'D', 5: 'A'},
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      active: true,
    );

    final test2 = TestModel(
      testId: 'test_trig_01',
      teacherId: teacherId,
      groupId: 'grp_math_101',
      groupName: 'Matematika 101',
      subjectId: 'sub_math',
      subjectName: 'Matematika',
      title: 'Trigonometriya asoslari №1',
      imageUrl:
          'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800&auto=format&fit=crop&q=80',
      questionCount: 5,
      correctAnswers: {1: 'B', 2: 'D', 3: 'A', 4: 'C', 5: 'D'},
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      active: true,
    );
    _tests[test1.testId] = test1;
    _tests[test2.testId] = test2;

    // Seed Sample Products
    final prod1 = ProductModel(
      productId: 'prod_pen_01',
      teacherId: teacherId,
      teacherName: 'Azizbek Aliyev',
      groupIds: ['all'],
      name: 'HOGWARTS Premium ruchka',
      imageUrl:
          'https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?w=800&auto=format&fit=crop&q=80',
      price: 100,
      active: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    );

    final prod2 = ProductModel(
      productId: 'prod_notebook_01',
      teacherId: teacherId,
      teacherName: 'Azizbek Aliyev',
      groupIds: ['all'],
      name: 'Maxsus Matematika daftari',
      imageUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80',
      price: 150,
      active: true,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    );
    _products[prod1.productId] = prod1;
    _products[prod2.productId] = prod2;

    _saveAll();
  }

  Future<void> _saveAll() async {
    await LocalStorageService.saveCollection(
        'users', _users.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'students', _students.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'teachers', _teachers.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'telegram_ids', _telegramIds.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'groups', _groups.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'tests', _tests.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'test_results', _testResults.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'products', _products.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'purchases', _purchases.values.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection('point_transactions',
        _pointTransactions.map((e) => e.toMap()).toList());
    await LocalStorageService.saveCollection(
        'subjects', _subjects.values.map((e) => e.toMap()).toList());
  }

  // ==========================================
  // TELEGRAM BOT & ID SYSTEM
  // ==========================================

  Future<void> cacheVerifiedTelegramCode(String code) async {
    final cleanCode = code.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      throw Exception('invalid_id_format');
    }

    _telegramIds[cleanCode] = TelegramIdModel(
      id: _uuid.v4(),
      code: cleanCode,
      createdAt: DateTime.now(),
    );
    await _saveAll();
    notifyListeners();
  }

  /// Verifies a 6-digit Telegram ID issued by the Hogwarts bot.
  ({bool isValid, String? errorKey, TelegramIdModel? idModel}) verifyTelegramId(
      String code) {
    final cleanCode = code.trim();
    if (cleanCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
      return (isValid: false, errorKey: 'invalid_id_format', idModel: null);
    }

    final model = _telegramIds[cleanCode];
    if (model == null) {
      return (isValid: false, errorKey: 'id_not_found', idModel: null);
    }

    if (model.isUsed) {
      return (isValid: false, errorKey: 'id_already_used', idModel: model);
    }

    return (isValid: true, errorKey: null, idModel: model);
  }

  // ==========================================
  // AUTHENTICATION & USERS
  // ==========================================

  Future<UserModel> registerUser({
    required UserRole role,
    required String telegramId,
    required String fullName,
    required String primarySubjectId,
  }) async {
    final verification = verifyTelegramId(telegramId);
    if (!verification.isValid) {
      throw Exception(verification.errorKey ?? 'Invalid ID');
    }

    final userId = _uuid.v4();
    final user = UserModel(
      id: userId,
      role: role,
      fullName: fullName.trim(),
      telegramId: telegramId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _users[userId] = user;

    // Mark Telegram ID as used
    final updatedId = verification.idModel!.markUsed(userId);
    _telegramIds[telegramId] = updatedId;

    if (role == UserRole.teacher) {
      _teachers[userId] = TeacherProfileModel(
        userId: userId,
        groupIds: [],
        subjectIds: [primarySubjectId],
      );
    } else {
      _students[userId] = StudentProfileModel(
        userId: userId,
        groupIds: [],
        totalPoints: 0,
      );
    }

    await LocalStorageService.saveCurrentUserId(userId);
    await _saveAll();
    notifyListeners();
    return user;
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> updateUser(UserModel user) async {
    _users[user.id] = user;
    await _saveAll();
    notifyListeners();
  }

  Future<void> logout() async {
    await LocalStorageService.saveCurrentUserId(null);
    notifyListeners();
  }

  // ==========================================
  // SUBJECTS
  // ==========================================

  List<SubjectModel> getSubjects() {
    return _subjects.values.toList();
  }

  Future<SubjectModel> createSubject(String name, String teacherId) async {
    final subId = 'sub_${_uuid.v4().substring(0, 8)}';
    final subject = SubjectModel(
      subjectId: subId,
      name: name.trim(),
      createdBy: teacherId,
      isDefault: false,
      createdAt: DateTime.now(),
    );
    _subjects[subId] = subject;
    await _saveAll();
    notifyListeners();
    return subject;
  }

  // ==========================================
  // GROUPS
  // ==========================================

  List<GroupModel> getTeacherGroups(String teacherId) {
    return _groups.values.where((g) => g.teacherId == teacherId).toList();
  }

  List<GroupModel> getStudentGroups(String studentId) {
    return _groups.values
        .where((g) => g.studentIds.contains(studentId))
        .toList();
  }

  GroupModel? getGroupById(String groupId) {
    return _groups[groupId];
  }

  Future<void> refreshFromStorage() async {
    final groupsData = await LocalStorageService.loadCollection('groups');
    if (groupsData != null) {
      _groups.clear();
      for (var map in groupsData) {
        final g = GroupModel.fromMap(map);
        _groups[g.groupId] = g;
      }
    }

    final usersData = await LocalStorageService.loadCollection('users');
    if (usersData != null) {
      _users.clear();
      for (var map in usersData) {
        final u = UserModel.fromMap(map);
        _users[u.id] = u;
      }
    }

    final studentsData = await LocalStorageService.loadCollection('students');
    if (studentsData != null) {
      _students.clear();
      for (var map in studentsData) {
        final s = StudentProfileModel.fromMap(map);
        _students[s.userId] = s;
      }
    }

    final teachersData = await LocalStorageService.loadCollection('teachers');
    if (teachersData != null) {
      _teachers.clear();
      for (var map in teachersData) {
        final t = TeacherProfileModel.fromMap(map);
        _teachers[t.userId] = t;
      }
    }
  }

  GroupModel? findGroupByCode(String groupCode) {
    final cleanCode = groupCode.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;
    for (final group in _groups.values) {
      if (group.groupCode.trim().toUpperCase() == cleanCode) {
        return group;
      }
    }
    return null;
  }

  Future<GroupModel> createGroup({
    required String teacherId,
    required String teacherName,
    required String name,
    required String subjectId,
    required String subjectName,
    String description = '',
  }) async {
    final groupId = 'grp_${_uuid.v4().substring(0, 8)}';
    final groupCode = CodeGenerator.generateGroupCode(subjectName)
        .toString()
        .trim()
        .toUpperCase();

    final group = GroupModel(
      groupId: groupId,
      teacherId: teacherId,
      teacherName: teacherName,
      name: name.trim(),
      subjectId: subjectId,
      subjectName: subjectName,
      groupCode: groupCode,
      studentIds: [],
      description: description.trim(),
      createdAt: DateTime.now(),
    );

    _groups[groupId] = group;

    final teacher = _teachers[teacherId];
    if (teacher != null) {
      final updatedList = List<String>.from(teacher.groupIds)..add(groupId);
      _teachers[teacherId] = teacher.copyWith(groupIds: updatedList);
    }

    await _saveAll();
    notifyListeners();
    return group;
  }

  Future<GroupModel> joinGroupByCode({
    required String studentId,
    required String groupCode,
  }) async {
    await refreshFromStorage();

    final cleanCode = groupCode.trim().toUpperCase();
    final group = _groups.values.firstWhere(
      (g) => g.groupCode.trim().toUpperCase() == cleanCode,
      orElse: () => throw Exception('group_not_found'),
    );

    if (group.studentIds.contains(studentId)) {
      throw Exception('already_in_group');
    }

    final updatedStudents = List<String>.from(group.studentIds)..add(studentId);
    _groups[group.groupId] = group.copyWith(studentIds: updatedStudents);

    final student = _students[studentId];
    if (student != null) {
      final updatedGroupIds = List<String>.from(student.groupIds)
        ..add(group.groupId);
      _students[studentId] = student.copyWith(groupIds: updatedGroupIds);
    }

    await _saveAll();
    notifyListeners();
    return _groups[group.groupId]!;
  }

  // ==========================================
  // TESTS
  // ==========================================

  List<TestModel> getTestsForStudent(String studentId) {
    final studentGroups =
        getStudentGroups(studentId).map((g) => g.groupId).toSet();
    return _tests.values
        .where((t) => t.active && studentGroups.contains(t.groupId))
        .map((t) => t.forStudent()) // Strip answers for security!
        .toList();
  }

  List<TestModel> getTestsForTeacher(String teacherId) {
    return _tests.values.where((t) => t.teacherId == teacherId).toList();
  }

  bool hasStudentSubmittedTest(String testId, String studentId) {
    return _testResults.values
        .any((r) => r.testId == testId && r.studentId == studentId);
  }

  TestResultModel? getTestResult(String testId, String studentId) {
    try {
      return _testResults.values
          .firstWhere((r) => r.testId == testId && r.studentId == studentId);
    } catch (_) {
      return null;
    }
  }

  int getTestSubmissionsCount(String testId) {
    return _testResults.values.where((r) => r.testId == testId).length;
  }

  Future<TestModel> createTest(TestModel test) async {
    _tests[test.testId] = test;
    await _saveAll();
    notifyListeners();
    return test;
  }

  /// Secure test checking on backend
  /// Compares answers strictly against backend test.correctAnswers
  /// Awards +1 ⭐ per correct answer
  /// Enforces single submission protection
  Future<TestResultModel> submitTest({
    required String testId,
    required String studentId,
    required String studentName,
    required Map<int, String> studentAnswers,
  }) async {
    if (hasStudentSubmittedTest(testId, studentId)) {
      throw Exception('already_taken_test');
    }

    final test = _tests[testId];
    if (test == null || !test.active) {
      throw Exception('test_not_found');
    }

    int correct = 0;
    int wrong = 0;

    test.correctAnswers.forEach((qNum, correctAns) {
      final userAns = studentAnswers[qNum]?.toUpperCase().trim();
      if (userAns != null && userAns == correctAns.toUpperCase().trim()) {
        correct++;
      } else {
        wrong++;
      }
    });

    final earnedPoints = correct; // +1 ⭐ per correct answer

    final resultId = 'res_${_uuid.v4().substring(0, 8)}';
    final result = TestResultModel(
      resultId: resultId,
      testId: testId,
      testTitle: test.title,
      studentId: studentId,
      studentName: studentName,
      correctCount: correct,
      wrongCount: wrong,
      earnedPoints: earnedPoints,
      answers: studentAnswers,
      submittedAt: DateTime.now(),
    );

    _testResults[resultId] = result;

    // Transactionally update student points
    final student = _students[studentId];
    if (student != null) {
      _students[studentId] = student.copyWith(
        totalPoints: student.totalPoints + earnedPoints,
      );

      _pointTransactions.add(PointTransactionModel(
        transactionId: _uuid.v4(),
        studentId: studentId,
        teacherId: test.teacherId,
        amount: earnedPoints,
        type: PointTransactionType.testReward,
        reason: 'Test: ${test.title}',
        createdAt: DateTime.now(),
      ));
    }

    await _saveAll();
    notifyListeners();
    return result;
  }

  // ==========================================
  // RATING & STUDENT LEADERBOARD
  // ==========================================

  List<({UserModel user, int totalPoints})> getGroupLeaderboard(
      String groupId) {
    final group = _groups[groupId];
    if (group == null) return [];

    final list = <({UserModel user, int totalPoints})>[];
    for (var studentId in group.studentIds) {
      final user = _users[studentId];
      final profile = _students[studentId];
      if (user != null) {
        list.add((user: user, totalPoints: profile?.totalPoints ?? 0));
      }
    }

    // Sort descending by points; tiebreaker by name
    list.sort((a, b) {
      final cmp = b.totalPoints.compareTo(a.totalPoints);
      if (cmp != 0) return cmp;
      return a.user.fullName.compareTo(b.user.fullName);
    });

    return list;
  }

  ({int totalPoints, int testsCount, int correctCount, int wrongCount})
      getStudentStats(String studentId) {
    final profile = _students[studentId];
    final results =
        _testResults.values.where((r) => r.studentId == studentId).toList();

    int correct = 0;
    int wrong = 0;
    for (var r in results) {
      correct += r.correctCount;
      wrong += r.wrongCount;
    }

    return (
      totalPoints: profile?.totalPoints ?? 0,
      testsCount: results.length,
      correctCount: correct,
      wrongCount: wrong,
    );
  }

  Future<void> updateStudentPoints({
    required String teacherId,
    required String studentId,
    required int amount,
    required PointTransactionType type,
    String reason = '',
  }) async {
    final student = _students[studentId];
    if (student == null) throw Exception('Student not found');

    final newPoints = (student.totalPoints + amount).clamp(0, 999999);
    _students[studentId] = student.copyWith(totalPoints: newPoints);

    _pointTransactions.add(PointTransactionModel(
      transactionId: _uuid.v4(),
      studentId: studentId,
      teacherId: teacherId,
      amount: amount,
      type: type,
      reason: reason,
      createdAt: DateTime.now(),
    ));

    await _saveAll();
    notifyListeners();
  }

  // ==========================================
  // SHOP & PURCHASES
  // ==========================================

  List<ProductModel> getProductsForStudent(String studentId) {
    final studentGroupIds =
        getStudentGroups(studentId).map((g) => g.groupId).toSet();
    return _products.values.where((p) {
      if (!p.active) return false;
      if (p.groupIds.isEmpty || p.groupIds.contains('all')) return true;
      return p.groupIds.any((gid) => studentGroupIds.contains(gid));
    }).toList();
  }

  List<ProductModel> getProductsForTeacher(String teacherId) {
    return _products.values.where((p) => p.teacherId == teacherId).toList();
  }

  Future<ProductModel> createProduct(ProductModel product) async {
    _products[product.productId] = product;
    await _saveAll();
    notifyListeners();
    return product;
  }

  /// Secure purchase transaction:
  /// Verifies balance, reduces points, records purchase with pending status
  Future<PurchaseModel> purchaseProduct({
    required String studentId,
    required String studentName,
    required String productId,
  }) async {
    final student = _students[studentId];
    if (student == null) throw Exception('Student not found');

    final product = _products[productId];
    if (product == null || !product.active)
      throw Exception('Product unavailable');

    if (student.totalPoints < product.price) {
      throw Exception('not_enough_points');
    }

    // Deduct points
    _students[studentId] = student.copyWith(
      totalPoints: student.totalPoints - product.price,
    );

    // Create Purchase
    final purchaseId = 'pur_${_uuid.v4().substring(0, 8)}';
    final purchase = PurchaseModel(
      purchaseId: purchaseId,
      studentId: studentId,
      studentName: studentName,
      teacherId: product.teacherId,
      productId: product.productId,
      productName: product.name,
      productImageUrl: product.imageUrl,
      price: product.price,
      status: PurchaseStatus.pending,
      purchasedAt: DateTime.now(),
    );

    _purchases[purchaseId] = purchase;

    // Log transaction
    _pointTransactions.add(PointTransactionModel(
      transactionId: _uuid.v4(),
      studentId: studentId,
      teacherId: product.teacherId,
      amount: -product.price,
      type: PointTransactionType.purchase,
      reason: 'Xarid: ${product.name}',
      createdAt: DateTime.now(),
    ));

    await _saveAll();
    notifyListeners();
    return purchase;
  }

  List<PurchaseModel> getStudentPurchases(String studentId) {
    final list =
        _purchases.values.where((p) => p.studentId == studentId).toList();
    list.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return list;
  }

  List<PurchaseModel> getTeacherOrders(String teacherId) {
    final list =
        _purchases.values.where((p) => p.teacherId == teacherId).toList();
    list.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return list;
  }

  Future<void> markPurchaseDelivered(String purchaseId) async {
    final purchase = _purchases[purchaseId];
    if (purchase != null) {
      _purchases[purchaseId] = purchase.copyWith(
        status: PurchaseStatus.given,
        givenAt: DateTime.now(),
      );
      await _saveAll();
      notifyListeners();
    }
  }

  int getStudentPoints(String studentId) {
    return _students[studentId]?.totalPoints ?? 0;
  }

  Future<void> syncFromFirebase({
    required String collection,
    required List<Map<String, dynamic>> data,
  }) async {
    await FirebaseService.syncCollection(collection: collection, data: data);
    notifyListeners();
  }
}
