import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/project_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_search_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final projectsAsync = ref.watch(filteredProjectsProvider);
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final unreadNotifsCount = ref.watch(unreadNotificationsCountProvider).value ?? 0;
    final currentUid = ref.watch(currentUserIdProvider);

    final userProfile = userProfileAsync.value;
    final favorites = favoritesAsync.value ?? <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (unreadNotifsCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadNotifsCount > 9 ? '9+' : '$unreadNotifsCount',
                      style: const TextStyle(
                        fontSize: 9.0,
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(newProjectsStreamProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userProfile != null && userProfile.firstName.isNotEmpty) ...[
                      Text(
                        'Здравствуйте, ${userProfile.firstName}',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      'Найди проект, в котором хочется участвовать',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    const HomeSearchBar(),
                    const SizedBox(height: 20.0),
                    SectionHeader(
                      title: 'Новые проекты',
                      trailing: projectsAsync.maybeWhen(
                        data: (list) => Text(
                          '${list.length}',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        orElse: () => null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            projectsAsync.when(
              loading: () => SliverPadding(
                padding: AppSpacing.pagePaddingHorizontal,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: ProjectCardSkeleton(),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorState(
                  message: err.toString(),
                  onRetry: () => ref.invalidate(newProjectsStreamProvider),
                ),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off_outlined,
                      title: 'Проекты не найдены',
                      message: 'Попробуйте изменить параметры поиска или фильтров.',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        final isFavorite = favorites.contains(project.id);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ProjectCard(
                            project: project,
                            isFavorite: isFavorite,
                            onTap: () => context.push('/project/${project.id}'),
                            onFavoriteToggle: () {
                              if (currentUid == null) return;
                              ref
                                  .read(projectRepositoryProvider)
                                  .toggleFavorite(
                                    userId: currentUid,
                                    projectId: project.id,
                                    isFavorite: !isFavorite,
                                  );
                            },
                          ),
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
