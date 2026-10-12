import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/core/theme/app_colors.dart';
import 'package:calista/core/theme/app_radius.dart';
import 'package:calista/core/theme/app_typography.dart';
import 'package:calista/core/widgets/empty_state.dart';
import 'package:calista/core/widgets/error_state.dart';
import 'package:calista/core/widgets/project_card.dart';
import 'package:calista/core/widgets/skeleton_loader.dart';
import 'package:calista/features/projects/presentation/controllers/project_controller.dart';
import 'package:calista/features/projects/domain/entities/project.dart';

class MyProjectsPage extends ConsumerStatefulWidget {
  const MyProjectsPage({super.key});

  @override
  ConsumerState<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends ConsumerState<MyProjectsPage>
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
    final createdProjectsAsync = ref.watch(myCreatedProjectsProvider);
    final participatingProjectsAsync = ref.watch(myParticipatingProjectsProvider);
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final currentUid = ref.watch(currentUserIdProvider);
    final favorites = favoritesAsync.value ?? <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Мои проекты'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: () => context.push('/create-project'),
              icon: const Icon(Icons.add, size: 18.0),
              label: const Text('Создать'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.surfaceSubtle,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
            ),
          ),
        ],
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
              tabs: const [
                Tab(text: 'Созданные'),
                Tab(text: 'Участвую'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Created Projects
          _buildProjectsList(
            asyncValue: createdProjectsAsync,
            favorites: favorites,
            currentUid: currentUid,
            emptyTitle: 'Вы пока не создали ни одного проекта',
            emptyMessage: 'Нажмите «Создать проект», чтобы собрать свою учебную команду.',
            emptyActionLabel: 'Создать проект',
            onEmptyAction: () => context.push('/create-project'),
            onRefresh: () => ref.invalidate(myCreatedProjectsProvider),
          ),

          // Tab 2: Participating Projects
          _buildProjectsList(
            asyncValue: participatingProjectsAsync,
            favorites: favorites,
            currentUid: currentUid,
            emptyTitle: 'Вы пока не участвуете в проектах',
            emptyMessage: 'Найдите интересный проект на главной странице и отправьте заявку.',
            onRefresh: () => ref.invalidate(myParticipatingProjectsProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList({
    required AsyncValue<List<Project>> asyncValue,
    required Set<String> favorites,
    required String? currentUid,
    required String emptyTitle,
    required String emptyMessage,
    String? emptyActionLabel,
    VoidCallback? onEmptyAction,
    required VoidCallback onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: asyncValue.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) => const ProjectCardSkeleton(),
        ),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: onRefresh,
        ),
        data: (projects) {
          if (projects.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: emptyTitle,
              message: emptyMessage,
              actionLabel: emptyActionLabel,
              onAction: onEmptyAction,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
            itemCount: projects.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12.0),
            itemBuilder: (context, index) {
              final project = projects[index];
              final isFavorite = favorites.contains(project.id);

              return ProjectCard(
                project: project,
                isFavorite: isFavorite,
                onTap: () => context.push('/project/${project.id}'),
                onFavoriteToggle: () {
                  if (currentUid == null) return;
                  ref.read(projectRepositoryProvider).toggleFavorite(
                        userId: currentUid,
                        projectId: project.id,
                        isFavorite: !isFavorite,
                      );
                },
              );
            },
          );
        },
      ),
    );
  }
}
