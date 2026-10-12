import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

abstract final class ErrorHandler {
  /// Converts any exception into a user-friendly AppException with human-readable Russian message.
  static AppException handle(dynamic error) {
    debugPrint('ErrorHandler caught exception: $error');
    if (error is AppException) {
      return error;
    }

    if (error is FirebaseAuthException) {
      return AuthException(_mapFirebaseAuthError(error), code: error.code, originalError: error);
    }

    if (error is FirebaseException) {
      return _mapFirebaseException(error);
    }

    // Default fallback
    return AppException(
      'Произошла непредвиденная ошибка. Пожалуйста, попробуйте снова.',
      originalError: error,
    );
  }

  static String _mapFirebaseAuthError(FirebaseAuthException e) {
    if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
      return 'В консоли Firebase не включена авторизация (Email/Password)';
    }

    switch (e.code) {
      case 'configuration-not-found':
        return 'В консоли Firebase не включена авторизация (Email/Password)';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный адрес электронной почты или пароль';
      case 'email-already-in-use':
        return 'Пользователь с такой почтой уже зарегистрирован';
      case 'invalid-email':
        return 'Некорректный формат адреса электронной почты';
      case 'weak-password':
        return 'Пароль слишком простой. Используйте более сложный пароль';
      case 'user-disabled':
        return 'Учётная запись была заблокирована';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Попробуйте позже';
      case 'network-request-failed':
        return 'Отсутствует подключение к сети Интернет';
      default:
        return 'Ошибка авторизации. Проверьте данные и попробуйте снова';
    }
  }

  static AppException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return PermissionDeniedException(
          'Не удалось выполнить действие: недостаточно прав доступа',
        );
      case 'not-found':
        return const NotFoundException('Запрашиваемый документ не найден');
      case 'already-exists':
        return const DuplicateApplicationException('Запись уже существует');
      case 'unavailable':
      case 'deadline-exceeded':
        return const NetworkException('Сервис временно недоступен. Проверьте сеть');
      default:
        return AppException(
          'Не удалось выполнить операцию. Проверьте соединение и попробуйте снова.',
          code: e.code,
          originalError: e,
        );
    }
  }
}
