import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/notification_model.dart';
import 'package:prm393_project/providers/announcement_provider.dart';
import 'package:prm393_project/services/announcement_service.dart';
import 'package:prm393_project/services/base_firestore_service.dart';

void main() {
  late FakeAnnouncementRepository repository;
  late AnnouncementProvider provider;

  setUp(() {
    repository = FakeAnnouncementRepository();
    provider = AnnouncementProvider(repository: repository);
  });

  tearDown(() {
    provider.dispose();
  });

  test('loadAnnouncements populates items by type', () async {
    repository.byType['announcement'] = [
      _announcement(id: '1', title: 'Bảo trì'),
      _announcement(id: '2', title: 'Họp cư dân'),
    ];

    await provider.loadAnnouncements();

    expect(provider.items, hasLength(2));
    expect(provider.errorMessage, isNull);
    expect(repository.getCallsWithType, contains('announcement'));
  });

  test('loadAnnouncements falls back when type filter empty', () async {
    repository.byType['announcement'] = [];
    repository.all = [_announcement(id: 'sys', title: 'Hệ thống', type: 'system')];

    await provider.loadAnnouncements();

    expect(provider.items, hasLength(1));
    expect(provider.items.first.type, 'system');
  });

  test('createAnnouncement success then reloads', () async {
    repository.byType['announcement'] = [
      _announcement(id: 'new', title: 'Mới'),
    ];

    final ok = await provider.createAnnouncement(
      title: 'Mới',
      content: 'Nội dung',
      createdBy: 'admin-1',
    );

    expect(ok, isTrue);
    expect(repository.createCalls, 1);
    expect(provider.items, hasLength(1));
  });

  test('loadDetail surfaces missing announcement', () async {
    repository.detail = null;

    await provider.loadDetail('missing');

    expect(provider.selected, isNull);
    expect(provider.errorMessage, 'Không tìm thấy thông báo');
  });

  test('deleteAnnouncement surfaces repository errors', () async {
    repository.throwOnDelete = const FirestoreException('Không có quyền');

    final ok = await provider.deleteAnnouncement('1');

    expect(ok, isFalse);
    expect(provider.errorMessage, 'Không có quyền');
  });
}

NotificationModel _announcement({
  required String id,
  required String title,
  String type = 'announcement',
}) {
  final now = DateTime(2026, 7, 1);
  return NotificationModel(
    id: id,
    title: title,
    content: 'Nội dung $id',
    type: type,
    createdBy: 'admin-1',
    targetRoles: const ['resident'],
    createdAt: now,
    updatedAt: now,
  );
}

class FakeAnnouncementRepository implements AnnouncementRepository {
  final Map<String, List<NotificationModel>> byType = {};
  List<NotificationModel> all = [];
  NotificationModel? detail;
  int createCalls = 0;
  final List<String?> getCallsWithType = [];
  FirestoreException? throwOnDelete;

  @override
  Future<NotificationModel?> getByIdAnnouncement(String id) async => detail;

  @override
  Future<List<NotificationModel>> getAnnouncements({String? type}) async {
    getCallsWithType.add(type);
    if (type != null) {
      return List.from(byType[type] ?? const []);
    }
    return List.from(all);
  }

  @override
  Future<String> createAnnouncement({
    required String title,
    required String content,
    required String createdBy,
    String type = 'announcement',
    List<String> targetRoles = const ['resident', 'staff', 'admin'],
  }) async {
    createCalls++;
    return 'new-id';
  }

  @override
  Future<void> updateAnnouncement({
    required String id,
    required String title,
    required String content,
    String? type,
    List<String>? targetRoles,
  }) async {}

  @override
  Future<void> deleteAnnouncement(String id) async {
    if (throwOnDelete != null) throw throwOnDelete!;
  }
}
