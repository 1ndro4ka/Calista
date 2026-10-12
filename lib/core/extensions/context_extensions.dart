import 'package:flutter/material.dart';
import '../../app/router/app_router.dart';
import '../widgets/app_top_notification.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  void showSnackBarMessage(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    AppTopNotification.show(
      this,
      message: message,
      isError: isError,
      duration: duration,
      rootNavKey: rootNavigatorKey,
    );
  }
}
