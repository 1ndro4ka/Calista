import '../constants/app_constants.dart';

abstract final class AppValidators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  static final RegExp _telegramRegExp = RegExp(r'^[a-zA-Z0-9_]{5,32}$');

  /// Validates name or surname
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите $fieldName';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return '$fieldName должно содержать не менее 2 символов';
    }
    return null;
  }

  /// Validates email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, введите адрес электронной почты';
    }
    final trimmed = value.trim();
    if (!_emailRegExp.hasMatch(trimmed)) {
      return 'Введите корректный адрес электронной почты';
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите пароль';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Пароль должен содержать минимум ${AppConstants.minPasswordLength} символов';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, подтвердите пароль';
    }
    if (value != password) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  /// Validates telegram username (without @)
  static String? validateTelegram(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Пожалуйста, укажите имя пользователя Telegram';
    }
    final clean = normalizeTelegram(value);
    if (!_telegramRegExp.hasMatch(clean)) {
      return 'Имя пользователя должно содержать от 5 до 32 символов (латиница, цифры, _)';
    }
    return null;
  }

  /// Strips leading @ if user entered it
  static String normalizeTelegram(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('@')) {
      return trimmed.substring(1).trim();
    }
    return trimmed;
  }

  /// Validates profile skills count (minimum 2)
  static String? validateProfileSkills(List<String> skills) {
    if (skills.length < AppConstants.minProfileSkills) {
      return 'Выберите как минимум ${AppConstants.minProfileSkills} навыка';
    }
    return null;
  }

  /// Validates project title (5-80 chars)
  static String? validateProjectTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите название проекта';
    }
    final length = value.trim().length;
    if (length < AppConstants.minProjectTitleLength) {
      return 'Название должно быть не короче ${AppConstants.minProjectTitleLength} символов';
    }
    if (length > AppConstants.maxProjectTitleLength) {
      return 'Название не должно превышать ${AppConstants.maxProjectTitleLength} символов';
    }
    return null;
  }

  /// Validates project description (20-2000 chars)
  static String? validateProjectDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введите описание проекта';
    }
    final length = value.trim().length;
    if (length < AppConstants.minProjectDescriptionLength) {
      return 'Описание должно быть не короче ${AppConstants.minProjectDescriptionLength} символов';
    }
    if (length > AppConstants.maxProjectDescriptionLength) {
      return 'Описание не должно превышать ${AppConstants.maxProjectDescriptionLength} символов';
    }
    return null;
  }

  /// Validates project category
  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Выберите категорию проекта';
    }
    return null;
  }

  /// Validates max members count (2-8)
  static String? validateMaxMembers(int? value, {int? currentMembers}) {
    if (value == null) {
      return 'Укажите количество участников';
    }
    if (value < AppConstants.minProjectMembers || value > AppConstants.maxProjectMembers) {
      return 'Размер команды должен быть от ${AppConstants.minProjectMembers} до ${AppConstants.maxProjectMembers} человек';
    }
    if (currentMembers != null && value < currentMembers) {
      return 'Максимальный размер не может быть меньше текущего числа участников ($currentMembers)';
    }
    return null;
  }

  /// Validates project deadline (must be future date)
  static String? validateDeadline(DateTime? deadline) {
    if (deadline == null) {
      return 'Выберите дедлайн проекта';
    }
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final deadlineStart = DateTime(deadline.year, deadline.month, deadline.day);
    if (!deadlineStart.isAfter(todayStart)) {
      return 'Дедлайн должен быть будущей датой';
    }
    return null;
  }

  /// Validates project required skills (minimum 1)
  static String? validateProjectSkills(List<String> skills) {
    if (skills.length < AppConstants.minProjectSkills) {
      return 'Укажите хотя бы один требуемый навык';
    }
    return null;
  }

  /// Validates application optional message (up to 300 chars)
  static String? validateApplicationMessage(String? value) {
    if (value != null && value.trim().length > AppConstants.maxApplicationMessageLength) {
      return 'Сообщение не должно превышать ${AppConstants.maxApplicationMessageLength} символов';
    }
    return null;
  }
}
