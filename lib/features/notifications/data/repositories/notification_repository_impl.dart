import 'package:calista/core/errors/error_handler.dart';
import 'package:calista/features/notifications/domain/entities/app_notification.dart';
import 'package:calista/features/notifications/domain/repositories/notification_repository.dart';
import 'package:calista/features/notifications/data/datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return remoteDataSource.watchNotifications(userId);
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return remoteDataSource.watchUnreadCount(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await remoteDataSource.markAllAsRead(userId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
