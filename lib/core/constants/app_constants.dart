/// App-wide constants and validation limits according to PM07 specifications.
abstract final class AppConstants {
  static const String appName = 'Calista';
  static const String appTagline = 'Поиск участников и формирование команд для учебных проектов';

  // Assets
  static const String logoSvg = 'assets/icons/calista_logo.svg';

  // Validation Limits
  static const int minProfileSkills = 2;
  static const int minProjectSkills = 1;

  static const int minProjectTitleLength = 5;
  static const int maxProjectTitleLength = 80;

  static const int minProjectDescriptionLength = 20;
  static const int maxProjectDescriptionLength = 2000;

  static const int minProjectMembers = 2;
  static const int maxProjectMembers = 8;

  static const int maxApplicationMessageLength = 300;

  static const int minPasswordLength = 8;

  // Query defaults
  static const int defaultProjectsLimit = 50;

  // Telegram URL prefix
  static const String telegramBaseUrl = 'https://t.me/';
}
