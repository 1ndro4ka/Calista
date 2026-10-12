import 'package:flutter/material.dart';
import '../../features/projects/domain/entities/project.dart';
import '../extensions/date_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'category_chip.dart';
import 'skill_chip.dart';

/// Clean, modern project card adhering strictly to Calista design guidelines.
/// No emoji.
class ProjectCard extends StatelessWidget {
  final Project project;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ProjectCard({
    super.key,
    required this.project,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
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
                // Category & Favorite button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CategoryChip(
                      label: project.category,
                      isSelected: false,
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? AppColors.accent : AppColors.textTertiary,
                        size: 22.0,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 20.0,
                      onPressed: onFavoriteToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Title
                Text(
                  project.title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6.0),

                // Short description
                Text(
                  project.description,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12.0),

                // Required skills
                if (project.requiredSkills.isNotEmpty) ...[
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: <Widget>[
                      ...project.requiredSkills.take(4).map((skill) {
                        return SkillChip(
                          label: skill,
                          isCompact: true,
                        );
                      }),
                      if (project.requiredSkills.length > 4)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: AppRadius.radiusRound,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '+${project.requiredSkills.length - 4}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                ],

                const Divider(height: 1.0, color: AppColors.borderSubtle),
                const SizedBox(height: 12.0),

                // Footer: Member count & Deadline
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 16.0,
                          color: project.isFull ? AppColors.warning : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          '${project.memberCount} / ${project.maxMembers} участников',
                          style: AppTypography.labelMedium.copyWith(
                            color: project.isFull
                                ? AppColors.warning
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14.0,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          'Дедлайн: ${project.deadline.toRussianFormattedString()}',
                          style: AppTypography.bodySmall.copyWith(
                            color: project.isDeadlineExpired
                                ? AppColors.error
                                : AppColors.textTertiary,
                          ),
                        ),
                      ],
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
