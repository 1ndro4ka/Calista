import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../controllers/notifications_controller.dart';
import 'package:calista/features/notifications/domain/entities/app_notification.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Уведомления'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationActionsControllerProvider.notifier).markAllAsRead();
            },
            child: const Text('Прочитать все'),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(notificationsListProvider),
        child: notificationsAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            itemBuilder: (context, index) => Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(height: 18.0, width: 140.0),
                  SizedBox(height: 8.0),
                  SkeletonLoader(height: 14.0, width: double.infinity),
                  SizedBox(height: 6.0),
                  SkeletonLoader(height: 12.0, width: 80.0),
                ],
              ),
            ),
          ),
          error: (err, stack) => ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(notificationsListProvider),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return const EmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'Нет уведомлений',
                message: 'Здесь будут отображаться новости по вашим проектам и заявкам.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _buildNotificationCard(context, ref, notif);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    WidgetRef ref,
    AppNotification notif,
  ) {
    IconData icon = Icons.info_outline;
    Color iconColor = AppColors.primary;
    Color iconBg = AppColors.surfaceSubtle;

    switch (notif.type) {
      case 'application_received':
        icon = Icons.mail_outline;
        iconColor = AppColors.accent;
        iconBg = AppColors.accentLight;
        break;
      case 'application_accepted':
        icon = Icons.check_circle_outline;
        iconColor = AppColors.success;
        iconBg = AppColors.successLight;
        break;
      case 'application_rejected':
        icon = Icons.cancel_outlined;
        iconColor = AppColors.error;
        iconBg = AppColors.errorLight;
        break;
      case 'member_left':
        icon = Icons.person_remove_outlined;
        iconColor = AppColors.warning;
        iconBg = AppColors.warningLight;
        break;
    }

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: AppRadius.radiusMd,
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (direction) {
        ref.read(notificationActionsControllerProvider.notifier).deleteNotification(notif.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: notif.isRead ? AppColors.surface : const Color(0xFFF0F4FA),
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: notif.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.3),
            width: notif.isRead ? 1.0 : 1.2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.radiusMd,
            onTap: () {
              if (!notif.isRead) {
                ref.read(notificationActionsControllerProvider.notifier).markAsRead(notif.id);
              }
              if (notif.projectId != null) {
                context.push('/project/${notif.projectId}');
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20.0, color: iconColor),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notif.title,
                                style: AppTypography.labelLarge.copyWith(
                                  fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!notif.isRead)
                              Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          notif.body,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          notif.createdAt.toRussianDateTimeString(),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
