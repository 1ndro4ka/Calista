import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calista/app/providers/app_providers.dart';
import 'package:calista/features/notifications/domain/entities/app_notification.dart';

final notificationsListProvider =
    StreamProvider<List<AppNotification>>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(notificationRepositoryProvider).watchNotifications(uid);
});

class NotificationActionsController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> markAsRead(String id) async {
    await ref.read(notificationRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null) return;
    await ref.read(notificationRepositoryProvider).markAllAsRead(uid);
  }

  Future<void> deleteNotification(String id) async {
    await ref.read(notificationRepositoryProvider).deleteNotification(id);
  }
}

final notificationActionsControllerProvider =
    NotifierProvider<NotificationActionsController, bool>(
  NotificationActionsController.new,
);
