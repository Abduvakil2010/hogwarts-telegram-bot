import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'translations_uz.dart';
import 'translations_ru.dart';
import 'translations_en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('uz'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> get _currentTranslations {
    switch (locale.languageCode) {
      case 'ru':
        return translationsRu;
      case 'en':
        return translationsEn;
      case 'uz':
      default:
        return translationsUz;
    }
  }

  String translate(String key, [Map<String, dynamic>? params]) {
    String value = _currentTranslations[key] ?? key;
    if (params != null && params.isNotEmpty) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue.toString());
      });
    }
    return value;
  }

  String get appName => translate('app_name');
  String get appSlogan => translate('app_slogan');
  String get loading => translate('loading');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get back => translate('back');
  String get next => translate('next');
  String get close => translate('close');
  String get search => translate('search');
  String get error => translate('error');
  String get success => translate('success');
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get requiredField => translate('required_field');
  String get optional => translate('optional');

  String get selectRole => translate('select_role');
  String get teacher => translate('teacher');
  String get student => translate('student');
  String get enterTelegramId => translate('enter_telegram_id');
  String get telegramIdHint => translate('telegram_id_hint');
  String get telegramBotInfo => translate('telegram_bot_info');
  String get getIdFromBot => translate('get_id_from_bot');
  String get idNotFound => translate('id_not_found');
  String get idAlreadyUsed => translate('id_already_used');
  String get invalidIdFormat => translate('invalid_id_format');
  String get enterFullName => translate('enter_full_name');
  String get fullNameHint => translate('full_name_hint');
  String get selectSubject => translate('select_subject');
  String get selectSubjectHint => translate('select_subject_hint');
  String get createNewSubject => translate('create_new_subject');
  String get registerButton => translate('register_button');
  String get registrationSuccess => translate('registration_success');

  String get navHome => translate('nav_home');
  String get navTests => translate('nav_tests');
  String get navRating => translate('nav_rating');
  String get navShop => translate('nav_shop');
  String get navSettings => translate('nav_settings');

  String helloStudent(String name) => translate('hello_student', {'name': name});
  String get studentSlogan => translate('student_slogan');
  String get earnedPoints => translate('earned_points');
  String get myGroups => translate('my_groups');
  String get joinGroup => translate('join_group');
  String get enterGroupCode => translate('enter_group_code');
  String get groupCodeHint => translate('group_code_hint');
  String get join => translate('join');
  String get groupNotFound => translate('group_not_found');
  String get alreadyInGroup => translate('already_in_group');
  String get joinGroupSuccess => translate('join_group_success');
  String get noGroupsStudent => translate('no_groups_student');
  String get teacherLabel => translate('teacher_label');

  String get availableTests => translate('available_tests');
  String get noTestsStudent => translate('no_tests_student');
  String questionsCount(int count) => translate('questions_count', {'count': count});
  String get startTest => translate('start_test');
  String get testCompleted => translate('test_completed');
  String get alreadyTakenTest => translate('already_taken_test');
  String get enterAnswers => translate('enter_answers');
  String get submitTest => translate('submit_test');
  String get confirmSubmitTest => translate('confirm_submit_test');
  String get testResultTitle => translate('test_result_title');
  String pointsEarned(int points) => translate('points_earned', {'points': points});
  String scoreRatio(int correct, int total) =>
      translate('score_ratio', {'correct': correct, 'total': total});
  String get resultDialogDesc => translate('result_dialog_desc');
  String get backToTests => translate('back_to_tests');

  String get createTest => translate('create_test');
  String get testTitle => translate('test_title');
  String get testTitleHint => translate('test_title_hint');
  String get selectGroup => translate('select_group');
  String get numberOfQuestions => translate('number_of_questions');
  String get correctAnswers => translate('correct_answers');
  String get correctAnswersHint => translate('correct_answers_hint');
  String get testImageUrl => translate('test_image_url');
  String get saveTest => translate('save_test');
  String get testCreatedSuccess => translate('test_created_success');
  String get noTestsTeacher => translate('no_tests_teacher');
  String totalSubmissions(int count) =>
      translate('total_submissions', {'count': count});

  String get groupRating => translate('group_rating');
  String get selectGroupForRating => translate('select_group_for_rating');
  String get ratingEmpty => translate('rating_empty');
  String get studentProfile => translate('student_profile');
  String get totalPoints => translate('total_points');
  String get submittedTests => translate('submitted_tests');
  String get correctAnswersStat => translate('correct_answers_stat');
  String get wrongAnswersStat => translate('wrong_answers_stat');
  String get addPoints => translate('add_points');
  String get removePoints => translate('remove_points');
  String get pointsAmount => translate('points_amount');
  String get reason => translate('reason');
  String get reasonHint => translate('reason_hint');
  String get pointsUpdatedSuccess => translate('points_updated_success');

  String get shopTitle => translate('shop_title');
  String get myPurchases => translate('my_purchases');
  String get allOrders => translate('all_orders');
  String get noProductsStudent => translate('no_products_student');
  String get noProductsTeacher => translate('no_products_teacher');
  String get buyButton => translate('buy_button');
  String get notEnoughPoints => translate('not_enough_points');
  String get purchaseSuccess => translate('purchase_success');
  String confirmPurchase(int points) =>
      translate('confirm_purchase', {'points': points});
  String get statusPending => translate('status_pending');
  String get statusGiven => translate('status_given');
  String get markAsGiven => translate('mark_as_given');
  String get markedGivenSuccess => translate('marked_given_success');
  String get noPurchasesStudent => translate('no_purchases_student');
  String get noOrdersTeacher => translate('no_orders_teacher');
  String get purchasedDate => translate('purchased_date');

  String get addProduct => translate('add_product');
  String get productName => translate('product_name');
  String get productNameHint => translate('product_name_hint');
  String get productPrice => translate('product_price');
  String get productImageUrl => translate('product_image_url');
  String get productVisibility => translate('product_visibility');
  String get allMyGroups => translate('all_my_groups');
  String get selectedGroupsOnly => translate('selected_groups_only');
  String get productCreatedSuccess => translate('product_created_success');

  String helloTeacher(String name) => translate('hello_teacher', {'name': name});
  String get teacherGroupsTitle => translate('teacher_groups_title');
  String get createGroup => translate('create_group');
  String get groupName => translate('group_name');
  String get groupNameHint => translate('group_name_hint');
  String get groupDesc => translate('group_desc');
  String get groupDescHint => translate('group_desc_hint');
  String get groupCreatedSuccess => translate('group_created_success');
  String groupCodeCreated(String code) =>
      translate('group_code_created', {'code': code});
  String get copyCode => translate('copy_code');
  String get codeCopied => translate('code_copied');
  String studentsCount(int count) => translate('students_count', {'count': count});
  String get noGroupsTeacher => translate('no_groups_teacher');

  String get settingsTitle => translate('settings_title');
  String get language => translate('language');
  String get theme => translate('theme');
  String get themeLight => translate('theme_light');
  String get themeDark => translate('theme_dark');
  String get editProfile => translate('edit_profile');
  String get logout => translate('logout');
  String get logoutConfirmTitle => translate('logout_confirm_title');
  String get logoutConfirmDesc => translate('logout_confirm_desc');
  String get profileUpdatedSuccess => translate('profile_updated_success');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['uz', 'ru', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
