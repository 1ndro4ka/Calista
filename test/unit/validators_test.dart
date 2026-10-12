import 'package:flutter_test/flutter_test.dart';
import 'package:calista/core/validators/app_validators.dart';

void main() {
  group('AppValidators Unit Tests', () {
    test('validateName correctly checks non-empty and minimum length', () {
      expect(AppValidators.validateName(null, 'Имя'), isNotNull);
      expect(AppValidators.validateName('', 'Имя'), isNotNull);
      expect(AppValidators.validateName('A', 'Имя'), isNotNull);
      expect(AppValidators.validateName('Адильжан', 'Имя'), isNull);
    });

    test('validateEmail validates RFC compliant email addresses', () {
      expect(AppValidators.validateEmail(null), isNotNull);
      expect(AppValidators.validateEmail('invalid'), isNotNull);
      expect(AppValidators.validateEmail('test@'), isNotNull);
      expect(AppValidators.validateEmail('@domain.com'), isNotNull);
      expect(AppValidators.validateEmail('student@university.edu'), isNull);
      expect(AppValidators.validateEmail('user.name+tag@sub.example.com'), isNull);
    });

    test('validatePassword requires at least 8 characters', () {
      expect(AppValidators.validatePassword(null), isNotNull);
      expect(AppValidators.validatePassword('1234567'), isNotNull);
      expect(AppValidators.validatePassword('12345678'), isNull);
      expect(AppValidators.validatePassword('complex_password_123'), isNull);
    });

    test('validateConfirmPassword checks matching passwords', () {
      expect(AppValidators.validateConfirmPassword('pass1234', 'pass1234'), isNull);
      expect(AppValidators.validateConfirmPassword('pass1234', 'different'), isNotNull);
      expect(AppValidators.validateConfirmPassword(null, 'pass1234'), isNotNull);
    });

    test('validateTelegram checks format and normalizes @ sign', () {
      expect(AppValidators.normalizeTelegram('@student_dev'), equals('student_dev'));
      expect(AppValidators.normalizeTelegram('student_dev'), equals('student_dev'));
      expect(AppValidators.validateTelegram('usr'), isNotNull); // too short (<5)
      expect(AppValidators.validateTelegram('@valid_username'), isNull);
      expect(AppValidators.validateTelegram('valid_username123'), isNull);
      expect(AppValidators.validateTelegram('invalid-hyphen'), isNotNull);
    });

    test('validateProfileSkills requires at least 2 skills', () {
      expect(AppValidators.validateProfileSkills([]), isNotNull);
      expect(AppValidators.validateProfileSkills(['Flutter']), isNotNull);
      expect(AppValidators.validateProfileSkills(['Flutter', 'Dart']), isNull);
      expect(AppValidators.validateProfileSkills(['Flutter', 'Dart', 'UI/UX']), isNull);
    });

    test('validateProjectTitle enforces 5-80 characters', () {
      expect(AppValidators.validateProjectTitle(''), isNotNull);
      expect(AppValidators.validateProjectTitle('App'), isNotNull); // < 5
      expect(AppValidators.validateProjectTitle('Calista MVP Team'), isNull);
      expect(AppValidators.validateProjectTitle('A' * 81), isNotNull); // > 80
    });

    test('validateProjectDescription enforces 20-2000 characters', () {
      expect(AppValidators.validateProjectDescription(''), isNotNull);
      expect(AppValidators.validateProjectDescription('Short text'), isNotNull); // < 20
      expect(
        AppValidators.validateProjectDescription(
          'Создание мобильного приложения для учебных проектов на Flutter и Firebase',
        ),
        isNull,
      );
      expect(AppValidators.validateProjectDescription('A' * 2001), isNotNull);
    });

    test('validateMaxMembers enforces 2 to 8 members and respect current count', () {
      expect(AppValidators.validateMaxMembers(1), isNotNull);
      expect(AppValidators.validateMaxMembers(9), isNotNull);
      expect(AppValidators.validateMaxMembers(4), isNull);
      // If current members is 5, cannot set max to 3
      expect(AppValidators.validateMaxMembers(3, currentMembers: 5), isNotNull);
      expect(AppValidators.validateMaxMembers(5, currentMembers: 5), isNull);
    });

    test('validateDeadline allows only future dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(AppValidators.validateDeadline(null), isNotNull);
      expect(AppValidators.validateDeadline(yesterday), isNotNull);
      expect(AppValidators.validateDeadline(tomorrow), isNull);
    });

    test('validateProjectSkills requires at least 1 skill', () {
      expect(AppValidators.validateProjectSkills([]), isNotNull);
      expect(AppValidators.validateProjectSkills(['Flutter']), isNull);
    });

    test('validateApplicationMessage limits message to 300 characters', () {
      expect(AppValidators.validateApplicationMessage(null), isNull);
      expect(AppValidators.validateApplicationMessage('Могу взять UI'), isNull);
      expect(AppValidators.validateApplicationMessage('A' * 301), isNotNull);
    });
  });
}
