/// Base application exception with user-facing human-readable messages.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Проверьте подключение к сети'])
      : super(code: 'network_error');
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Запрошенные данные не найдены'])
      : super(code: 'not_found');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([
    super.message = 'У вас нет прав для выполнения этой операции',
  ]) : super(code: 'permission_denied');
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

class ProjectFullException extends AppException {
  const ProjectFullException([
    super.message = 'Набор в проект уже завершён, команда сформирована',
  ]) : super(code: 'project_full');
}

class DeadlineExpiredException extends AppException {
  const DeadlineExpiredException([
    super.message = 'Срок подачи заявок на данный проект истёк',
  ]) : super(code: 'deadline_expired');
}

class DuplicateApplicationException extends AppException {
  const DuplicateApplicationException([
    super.message = 'Вы уже подали заявку на участие в этом проекте',
  ]) : super(code: 'duplicate_application');
}
