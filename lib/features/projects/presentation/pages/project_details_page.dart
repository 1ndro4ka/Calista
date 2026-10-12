import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/url_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_outlined_button.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/category_chip.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../../../applications/presentation/widgets/apply_bottom_sheet.dart';
import 'package:calista/features/projects/presentation/controllers/project_controller.dart';
import 'package:calista/features/projects/domain/entities/project.dart';
import 'package:calista/features/projects/domain/entities/project_member.dart';

class ProjectDetailsPage extends ConsumerWidget {
  final String projectId;

  const ProjectDetailsPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailsProvider(projectId));
    final membersAsync = ref.watch(projectMembersProvider(projectId));
    final currentUid = ref.watch(currentUserIdProvider);
    final currentUser = ref.watch(currentUserProfileProvider).value;
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final myAppAsync = currentUid != null
        ? ref.watch(
            applicationRepositoryProvider,
          ).watchApplicationForProjectAndUser(
            projectId: projectId,
            applicantId: currentUid,
          )
        : null;

    final isFavorite = favoritesAsync.value?.contains(projectId) ?? false;

    return projectAsync.when(
      loading: () => const Scaffold(
        body: LoadingState(message: 'Загрузка проекта...'),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(projectDetailsProvider(projectId)),
        ),
      ),
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(
              title: 'Проект не найден',
              message: 'Возможно, проект был удален автором.',
            ),
          );
        }

        final isOwner = currentUid != null && currentUid == project.ownerId;

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            title: const Text('Детали проекта'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorite ? AppColors.accent : AppColors.textPrimary,
                ),
                onPressed: () {
                  if (currentUid == null) return;
                  ref.read(projectRepositoryProvider).toggleFavorite(
                        userId: currentUid,
                        projectId: project.id,
                        isFavorite: !isFavorite,
                      );
                },
              ),
              if (isOwner)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == 'edit') {
                      context.push('/project/${project.id}/edit');
                    } else if (value == 'delete') {
                      final confirmed = await ConfirmDialog.show(
                        context,
                        title: 'Удалить проект?',
                        message: 'Это действие нельзя отменить. Все связанные заявки и участники будут удалены.',
                        confirmLabel: 'Удалить',
                        isDestructive: true,
                      );
                      if (confirmed && context.mounted) {
                        final success = await ref
                            .read(projectActionControllerProvider.notifier)
                            .deleteProject(project.id);
                        if (success && context.mounted) {
                          context.showSnackBarMessage('Проект успешно удален');
                          context.pop();
                        }
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20.0),
                          SizedBox(width: 12.0),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20.0, color: AppColors.error),
                          SizedBox(width: 12.0),
                          Text('Удалить', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(width: 8.0),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: AppSpacing.pagePadding,
                  children: [
                    // Category & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CategoryChip(label: project.category),
                        _buildStatusBadge(project),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Title
                    Text(
                      project.title,
                      style: AppTypography.display.copyWith(fontSize: 22.0),
                    ),
                    const SizedBox(height: 16.0),

                    // Info parameters card
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppRadius.radiusMd,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildParameterColumn(
                            icon: Icons.group_outlined,
                            label: 'Команда',
                            value: '${project.memberCount} из ${project.maxMembers}',
                          ),
                          Container(width: 1.0, height: 32.0, color: AppColors.border),
                          _buildParameterColumn(
                            icon: Icons.calendar_today_outlined,
                            label: 'Дедлайн',
                            value: project.deadline.toRussianFormattedString(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Description
                    const SectionHeader(title: 'Описание проекта'),
                    Text(
                      project.description,
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: 24.0),

                    // Required Skills
                    const SectionHeader(title: 'Требуемые навыки'),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: project.requiredSkills
                          .map((skill) => SkillChip(label: skill))
                          .toList(),
                    ),
                    const SizedBox(height: 28.0),

                    // Team Members
                    membersAsync.when(
                      loading: () => const LoadingState(),
                      error: (err, stack) => Text(
                        'Не удалось загрузить участников',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      ),
                      data: (members) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: 'Команда проекта',
                              subtitle: '${members.length} / ${project.maxMembers} участников',
                            ),
                            const SizedBox(height: 8.0),
                            ...members.map((member) => _buildMemberTile(context, member)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),

              // Bottom Sticky Action Bar
              StreamBuilder(
                stream: myAppAsync,
                builder: (context, snapshot) {
                  final myApp = snapshot.data;
                  final members = membersAsync.value ?? [];
                  final isMember =
                      currentUid != null && members.any((m) => m.userId == currentUid);

                  return _buildActionBar(
                    context: context,
                    ref: ref,
                    project: project,
                    isOwner: isOwner,
                    isMember: isMember,
                    currentUid: currentUid,
                    currentUser: currentUser,
                    myApplication: myApp,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Project project) {
    String label = 'Открыт набор';
    Color bg = AppColors.successLight;
    Color fg = AppColors.success;

    if (project.isDeadlineExpired) {
      label = 'Срок истёк';
      bg = AppColors.errorLight;
      fg = AppColors.error;
    } else if (project.isFull) {
      label = 'Команда набрана';
      bg = AppColors.warningLight;
      fg = AppColors.warning;
    } else if (project.isClosed) {
      label = 'Закрыт';
      bg = AppColors.surfaceSubtle;
      fg = AppColors.textTertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.radiusRound,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildParameterColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.0, color: AppColors.textTertiary),
            const SizedBox(width: 4.0),
            Text(label, style: AppTypography.bodySmall),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildMemberTile(BuildContext context, ProjectMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          AvatarWidget(
            avatarUrl: member.userAvatarUrl,
            firstName: member.userName.split(' ').first,
            lastName: member.userName.split(' ').skip(1).join(' '),
            size: 40.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.userName.isNotEmpty ? member.userName : 'Участник',
                        style: AppTypography.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (member.isOwner)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Создатель',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                if (member.userTelegram.isNotEmpty) ...[
                  const SizedBox(height: 2.0),
                  GestureDetector(
                    onTap: () => UrlUtils.openTelegram(member.userTelegram),
                    child: Text(
                      '@${member.userTelegram}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                if (member.userSkills.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: member.userSkills
                        .take(3)
                        .map((s) => SkillChip(label: s, isCompact: true))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar({
    required BuildContext context,
    required WidgetRef ref,
    required Project project,
    required bool isOwner,
    required bool isMember,
    required String? currentUid,
    required dynamic currentUser,
    required dynamic myApplication,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            // Case 1: Current user is Owner
            if (isOwner) {
              return Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: 'Редактировать',
                      icon: Icons.edit_outlined,
                      onPressed: () => context.push('/project/${project.id}/edit'),
                    ),
                  ),
                ],
              );
            }

            // Case 2: Current user is a participating member (not owner)
            if (isMember) {
              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 16.0, color: AppColors.success),
                              const SizedBox(width: 6.0),
                              Text(
                                'Вы участник проекта',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          AppOutlinedButton(
                            text: 'Покинуть проект',
                            textColor: AppColors.error,
                            borderColor: AppColors.error,
                            onPressed: () async {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: 'Покинуть проект?',
                                message: 'Вы перестанете быть участником команды «${project.title}».',
                                confirmLabel: 'Покинуть',
                                isDestructive: true,
                              );
                              if (confirmed && context.mounted && currentUid != null) {
                                final success = await ref
                                    .read(projectActionControllerProvider.notifier)
                                    .leaveProject(
                                      projectId: project.id,
                                      userId: currentUid,
                                      userName: currentUser?.fullName ?? 'Участник',
                                    );
                                if (success && context.mounted) {
                                  context.showSnackBarMessage('Вы покинули проект');
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Case 3: Current user has a pending application
            if (myApplication != null && myApplication.isPending) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.hourglass_empty,
                                size: 16.0, color: AppColors.warning),
                            const SizedBox(width: 6.0),
                            Text(
                              'Заявка ожидает рассмотрения',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        AppOutlinedButton(
                          text: 'Отменить заявку',
                          textColor: AppColors.error,
                          borderColor: AppColors.error,
                          onPressed: () async {
                            final confirmed = await ConfirmDialog.show(
                              context,
                              title: 'Отменить заявку?',
                              message: 'Вы уверены, что хотите отозвать свою заявку?',
                              confirmLabel: 'Отменить заявку',
                              isDestructive: true,
                            );
                            if (confirmed && context.mounted && currentUid != null) {
                              try {
                                await ref
                                    .read(applicationRepositoryProvider)
                                    .cancelApplication(
                                      applicationId: myApplication.id,
                                      applicantId: currentUid,
                                    );
                                if (context.mounted) {
                                  context.showSnackBarMessage('Заявка отменена');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  context.showSnackBarMessage(e.toString(), isError: true);
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Case 4: Project is full or deadline has passed
            if (!project.canAcceptApplications) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  project.isDeadlineExpired
                      ? 'Прием заявок завершен (дедлайн истек)'
                      : 'Команда укомплектована (набор закрыт)',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            // Case 5: Can apply
            return AppButton(
              text: 'Подать заявку',
              icon: Icons.send_outlined,
              onPressed: () => ApplyBottomSheet.show(context, project),
            );
          },
        ),
      ),
    );
  }
}
