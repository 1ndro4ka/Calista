import 'package:flutter/material.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/skill_chip.dart';
import 'package:calista/features/applications/domain/entities/project_application.dart';

class IncomingApplicationCard extends StatelessWidget {
  final ProjectApplication application;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingApplicationCard({
    super.key,
    required this.application,
    this.isLoading = false,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project name banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'Проект: ${application.projectTitle}',
              style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12.0),

          // Applicant Header
          Row(
            children: [
              AvatarWidget(
                avatarUrl: application.applicantAvatarUrl,
                firstName: application.applicantName.split(' ').first,
                lastName: application.applicantName.split(' ').skip(1).join(' '),
                size: 44.0,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.applicantName,
                      style: AppTypography.titleMedium,
                    ),
                    if (application.applicantTelegram.isNotEmpty) ...[
                      const SizedBox(height: 2.0),
                      GestureDetector(
                        onTap: () => UrlUtils.openTelegram(application.applicantTelegram),
                        child: Text(
                          '@${application.applicantTelegram}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                application.createdAt.toRussianFormattedString(),
                style: AppTypography.bodySmall,
              ),
            ],
          ),

          // Applicant Skills
          if (application.applicantSkills.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Text('Навыки кандидата:', style: AppTypography.labelSmall),
            const SizedBox(height: 6.0),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: application.applicantSkills
                  .map((s) => SkillChip(label: s, isCompact: true))
                  .toList(),
            ),
          ],

          // Applicant Message
          if (application.message != null && application.message!.isNotEmpty) ...[
            const SizedBox(height: 12.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Text(
                application.message!,
                style: AppTypography.bodyMedium,
              ),
            ),
          ],

          const SizedBox(height: 16.0),
          const Divider(height: 1.0, color: AppColors.border),
          const SizedBox(height: 12.0),

          // Actions
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  text: 'Отклонить',
                  textColor: AppColors.error,
                  borderColor: AppColors.error,
                  isLoading: isLoading,
                  onPressed: onReject,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: AppButton(
                  text: 'Принять',
                  backgroundColor: AppColors.success,
                  isLoading: isLoading,
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
