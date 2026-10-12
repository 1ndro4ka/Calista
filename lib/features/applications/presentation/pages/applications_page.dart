import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:calista/core/extensions/context_extensions.dart';
import 'package:calista/core/theme/app_colors.dart';
import 'package:calista/core/theme/app_radius.dart';
import 'package:calista/core/theme/app_typography.dart';
import 'package:calista/core/widgets/confirm_dialog.dart';
import 'package:calista/core/widgets/empty_state.dart';
import 'package:calista/core/widgets/error_state.dart';
import 'package:calista/core/widgets/skeleton_loader.dart';
import 'package:calista/features/applications/presentation/controllers/applications_controller.dart';
import 'package:calista/features/applications/presentation/widgets/incoming_application_card.dart';
import 'package:calista/features/applications/presentation/widgets/my_application_card.dart';

class ApplicationsPage extends ConsumerStatefulWidget {
  const ApplicationsPage({super.key});

  @override
  ConsumerState<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends ConsumerState<ApplicationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incomingAsync = ref.watch(incomingApplicationsProvider);
    final myAppsAsync = ref.watch(myApplicationsProvider);
    final actionState = ref.watch(applicationsControllerProvider);
    final incomingCount = incomingAsync.value?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Заявки'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadius.radiusMd,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.radiusMd,
              ),
              labelColor: AppColors.textInverse,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.labelLarge,
              unselectedLabelStyle: AppTypography.labelLarge,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Входящие'),
                      if (incomingCount > 0) ...[
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: AppRadius.radiusRound,
                          ),
                          child: Text(
                            '$incomingCount',
                            style: const TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textInverse,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Мои'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Incoming Applications Tab
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(incomingApplicationsProvider),
            child: incomingAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) => const ProjectCardSkeleton(),
              ),
              error: (err, stack) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.invalidate(incomingApplicationsProvider),
              ),
              data: (applications) {
                if (applications.isEmpty) {
                  return const EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'Входящих заявок нет',
                    message: 'Когда кто-то захочет вступить в ваш проект, заявка появится здесь.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                  itemCount: applications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return IncomingApplicationCard(
                      application: app,
                      isLoading: actionState.isLoading,
                      onAccept: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Принять кандидата?',
                          message: 'Пользователь «${app.applicantName}» станет участником проекта «${app.projectTitle}».',
                          confirmLabel: 'Принять в команду',
                        );
                        if (confirmed && context.mounted) {
                          final success = await ref
                              .read(applicationsControllerProvider.notifier)
                              .acceptApplication(app);
                          if (success && context.mounted) {
                            context.showSnackBarMessage('Участник успешно добавлен в команду');
                          } else if (context.mounted) {
                            final err = ref.read(applicationsControllerProvider).errorMessage;
                            if (err != null) context.showSnackBarMessage(err, isError: true);
                          }
                        }
                      },
                      onReject: () async {
                        final confirmed = await ConfirmDialog.show(
                          context,
                          title: 'Отклонить заявку?',
                          message: 'Вы уверены, что хотите отклонить заявку от «${app.applicantName}»?',
                          confirmLabel: 'Отклонить',
                          isDestructive: true,
                        );
                        if (confirmed && context.mounted) {
                          final success = await ref
                              .read(applicationsControllerProvider.notifier)
                              .rejectApplication(app);
                          if (success && context.mounted) {
                            context.showSnackBarMessage('Заявка отклонена');
                          } else if (context.mounted) {
                            final err = ref.read(applicationsControllerProvider).errorMessage;
                            if (err != null) context.showSnackBarMessage(err, isError: true);
                          }
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // 2. My Applications Tab
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(myApplicationsProvider),
            child: myAppsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: 3,
                separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                itemBuilder: (context, index) => const ProjectCardSkeleton(),
              ),
              error: (err, stack) => ErrorState(
                message: err.toString(),
                onRetry: () => ref.invalidate(myApplicationsProvider),
              ),
              data: (applications) {
                if (applications.isEmpty) {
                  return const EmptyState(
                    icon: Icons.send_outlined,
                    title: 'Вы ещё не подавали заявок',
                    message: 'Просматривайте проекты на главной и подавайте заявки в интересующие команды.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                  itemCount: applications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12.0),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    return MyApplicationCard(
                      application: app,
                      onTap: () => context.push('/project/${app.projectId}'),
                      onCancel: app.isPending
                          ? () async {
                              final confirmed = await ConfirmDialog.show(
                                context,
                                title: 'Отозвать заявку?',
                                message: 'Вы уверены, что хотите отозвать заявку на участие в «${app.projectTitle}»?',
                                confirmLabel: 'Отозвать',
                                isDestructive: true,
                              );
                              if (confirmed && context.mounted) {
                                final success = await ref
                                    .read(applicationsControllerProvider.notifier)
                                    .cancelApplication(app.id);
                                if (success && context.mounted) {
                                  context.showSnackBarMessage('Заявка отозвана');
                                } else if (context.mounted) {
                                  final err = ref
                                      .read(applicationsControllerProvider)
                                      .errorMessage;
                                  if (err != null) {
                                    context.showSnackBarMessage(err, isError: true);
                                  }
                                }
                              }
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
