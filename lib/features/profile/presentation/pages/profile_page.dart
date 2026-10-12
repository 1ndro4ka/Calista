import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skill_chip.dart';
import 'package:calista/features/auth/presentation/controllers/auth_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/edit-profile'),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingState(message: 'Загрузка профиля...'),
        error: (err, stack) => Center(
          child: Text(
            'Ошибка: ${err.toString()}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Профиль не найден'));
          }

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Profile Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      AvatarWidget(
                        avatarUrl: profile.avatarUrl,
                        firstName: profile.firstName,
                        lastName: profile.lastName,
                        size: 80.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        profile.fullName,
                        style: AppTypography.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      if (profile.specialty != null && profile.specialty!.isNotEmpty) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          profile.course != null
                              ? '${profile.specialty!} (${profile.course} курс)'
                              : profile.specialty!,
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (profile.telegramUsername.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        InkWell(
                          onTap: () async {
                            final launched = await UrlUtils.openTelegram(profile.telegramUsername);
                            if (!launched && context.mounted) {
                              context.showSnackBarMessage('Не удалось открыть Telegram');
                            }
                          },
                          borderRadius: AppRadius.radiusRound,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: AppRadius.radiusRound,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.send, size: 14.0, color: AppColors.accent),
                                const SizedBox(width: 6.0),
                                Text(
                                  '@${profile.telegramUsername}',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Bio
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'О себе', padding: EdgeInsets.zero),
                        const SizedBox(height: 8.0),
                        Text(
                          profile.bio!,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],

                // Skills Card
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.radiusLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Мои навыки', padding: EdgeInsets.zero),
                      const SizedBox(height: 12.0),
                      if (profile.skills.isEmpty)
                        Text(
                          'Навыки не указаны',
                          style: AppTypography.bodySmall,
                        )
                      else
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: profile.skills.map((s) => SkillChip(label: s)).toList(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),

                // Edit Profile Button
                AppOutlinedButton(
                  text: 'Редактировать профиль',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push('/edit-profile'),
                ),
                const SizedBox(height: 12.0),

                // Logout Button
                AppButton(
                  text: 'Выйти из аккаунта',
                  icon: Icons.logout,
                  backgroundColor: AppColors.surfaceSubtle,
                  textColor: AppColors.error,
                  onPressed: () async {
                    final confirmed = await ConfirmDialog.show(
                      context,
                      title: 'Выйти из аккаунта?',
                      message: 'Вам потребуется снова ввести логин и пароль для входа.',
                      confirmLabel: 'Выйти',
                      cancelLabel: 'Отмена',
                      isDestructive: true,
                    );

                    if (confirmed && context.mounted) {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          );
        },
      ),
    );
  }
}
