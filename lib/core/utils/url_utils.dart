import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

abstract final class UrlUtils {
  /// Opens Telegram chat by username.
  /// First tries opening directly, falls back to external browser if needed.
  static Future<bool> openTelegram(String rawUsername) async {
    final cleanUsername = rawUsername.replaceAll('@', '').trim();
    if (cleanUsername.isEmpty) return false;

    final webUri = Uri.parse('${AppConstants.telegramBaseUrl}$cleanUsername');

    try {
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {
      // Fallback to in-app or platform default browser
      try {
        return await launchUrl(webUri, mode: LaunchMode.platformDefault);
      } catch (_) {
        return false;
      }
    }
    return false;
  }
}
