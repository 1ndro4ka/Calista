import 'package:flutter/material.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

class MyApplicationCard extends StatelessWidget {
  final ProjectApplication application;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const MyApplicationCard({
    super.key,
    required this.application,
    this.onCancel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusBg = AppColors.surfaceSubtle;
    Color statusFg = AppColors.textSecondary;
    IconData statusIcon = Icons.hourglass_empty;

    if (application.isAccepted) {
      statusBg = AppColors.successLight;
      statusFg = AppColors.success;
      statusIcon = Icons.check_circle_outline;
    } else if (application.isRejected) {
      statusBg = AppColors.errorLight;
      statusFg = AppColors.error;
      statusIcon = Icons.cancel_outlined;
    } else if (application.isCancelled) {
      statusBg = AppColors.surfaceSubtle;
      statusFg = AppColors.textTertiary;
      statusIcon = Icons.remove_circle_outline;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        application.projectTitle,
                        style: AppTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: AppRadius.radiusRound,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14.0, color: statusFg),
                          const SizedBox(width: 4.0),
                          Text(
                            application.statusRussianLabel,
                            style: AppTypography.labelSmall.copyWith(
                              color: statusFg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),

                if (application.message != null && application.message!.isNotEmpty) ...[
                  Text(
                    'Ваш комментарий: ${application.message!}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Подана: ${application.createdAt.toRussianFormattedString()}',
                      style: AppTypography.bodySmall,
                    ),
                    if (application.isPending && onCancel != null)
                      AppOutlinedButton(
                        text: 'Отозвать',
                        textColor: AppColors.error,
                        borderColor: AppColors.error,
                        isFullWidth: false,
                        onPressed: onCancel,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
