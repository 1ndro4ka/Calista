import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'app_outlined_button.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Подтвердить',
    this.cancelLabel = 'Отмена',
    this.isDestructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Подтвердить',
    String cancelLabel = 'Отмена',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 12.0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      actionsPadding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 20.0),
      title: Text(
        title,
        style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
      ),
      content: Text(
        message,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppOutlinedButton(
                text: cancelLabel,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: AppButton(
                text: confirmLabel,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                textColor: AppColors.textInverse,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
