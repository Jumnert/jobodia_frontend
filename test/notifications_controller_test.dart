import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';

import 'notifications_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<GetStorage>()])
void main() {
  late MockGetStorage mockStorage;

  setUp(() {
    Get.testMode = true;
    mockStorage = MockGetStorage();
    FlutterSecureStorage.setMockInitialValues({});

    when(mockStorage.read<List>('readNotificationIds')).thenReturn(null);
    when(mockStorage.write(any, any)).thenAnswer((_) async => true);
  });

  tearDown(() {
    Get.reset();
  });

  group('NotificationsController', () {
    NotificationsController makeController() {
      final c = NotificationsController(storage: mockStorage);
      c.onInit();
      return c;
    }

    test('initial state — all notifications are unread', () {
      final c = makeController();
      expect(c.unreadCount, c.notifications.length);
    });

    test('markRead sets isRead on the notification', () {
      final c = makeController();
      expect(c.notifications.first.isRead, isFalse);

      c.markRead('n1');

      expect(c.notifications.first.isRead, isTrue);
    });

    test('markRead reduces unreadCount', () {
      final c = makeController();
      final initialUnread = c.unreadCount;

      c.markRead('n1');

      expect(c.unreadCount, initialUnread - 1);
    });

    test('markRead is idempotent', () {
      final c = makeController();
      c.markRead('n1');
      final countAfterFirst = c.unreadCount;

      c.markRead('n1');
      expect(c.unreadCount, countAfterFirst);
    });

    test('markAllRead marks every notification as read', () {
      final c = makeController();
      expect(c.unreadCount, c.notifications.length);

      c.markAllRead();

      expect(c.unreadCount, 0);
      expect(c.notifications.every((n) => n.isRead), isTrue);
    });

    test('markAllRead persists to storage', () {
      final c = makeController();
      c.markAllRead();

      verify(mockStorage.write('readNotificationIds', any)).called(1);
    });

    test('dismissNotification removes the item', () {
      final c = makeController();
      final initialLength = c.notifications.length;

      try {
        c.dismissNotification('n3');
      } catch (_) {}

      expect(c.notifications.length, initialLength - 1);
      expect(c.notifications.any((n) => n.id == 'n3'), isFalse);
    });

    test('markRead for unknown id is a no-op', () {
      final c = makeController();
      final initialUnread = c.unreadCount;

      c.markRead('nonexistent');

      expect(c.unreadCount, initialUnread);
    });
  });
}
