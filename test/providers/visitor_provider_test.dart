import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/visitor_model.dart';
import 'package:prm393_project/providers/visitor_provider.dart';
import 'package:prm393_project/services/base_firestore_service.dart';
import 'package:prm393_project/services/visitor_service.dart';

void main() {
  late FakeVisitorRepository repository;
  late VisitorProvider provider;

  setUp(() {
    repository = FakeVisitorRepository();
    provider = VisitorProvider(repository: repository);
  });

  tearDown(() {
    provider.dispose();
  });

  test('loadAll populates visitors and insideCount', () async {
    repository.all = [
      _visitor(id: '1', status: VisitorStatus.checkedIn),
      _visitor(id: '2', status: VisitorStatus.registered),
      _visitor(id: '3', status: VisitorStatus.checkedOut),
    ];

    await provider.loadAll();

    expect(provider.visitors, hasLength(3));
    expect(provider.insideCount, 1);
    expect(provider.errorMessage, isNull);
  });

  test('filteredVisitors matches name phone apartment', () async {
    repository.all = [
      _visitor(
        id: '1',
        name: 'Nguyen Van A',
        phone: '0901111111',
        apt: 'A-101',
      ),
      _visitor(id: '2', name: 'Tran Thi B', phone: '0902222222', apt: 'B-202'),
    ];
    await provider.loadAll();

    provider.setSearchQuery('thi');
    expect(provider.filteredVisitors, hasLength(1));
    expect(provider.filteredVisitors.first.id, '2');

    provider.setSearchQuery('0901');
    expect(provider.filteredVisitors.first.id, '1');

    provider.setSearchQuery('b-2');
    expect(provider.filteredVisitors.first.apartmentId, 'B-202');
  });

  test('registerVisitor success', () async {
    final ok = await provider.registerVisitor(
      visitorName: 'Khach',
      visitorPhone: '0901234567',
      purpose: 'Tham',
      registeredBy: 'res-1',
      apartmentId: 'A-101',
      expectedTime: DateTime(2026, 7, 20, 10),
    );

    expect(ok, isTrue);
    expect(repository.registerCalls, 1);
  });

  test('checkIn reloads list and maps status', () async {
    repository.all = [_visitor(id: '1', status: VisitorStatus.registered)];
    await provider.loadAll();

    repository.all = [_visitor(id: '1', status: VisitorStatus.checkedIn)];

    final ok = await provider.checkIn(visitorId: '1', staffId: 'staff-1');

    expect(ok, isTrue);
    expect(repository.checkInCalls, 1);
    expect(provider.visitors.first.status, VisitorStatus.checkedIn);
    expect(provider.insideCount, 1);
  });

  test('checkOut surfaces FirestoreException', () async {
    repository.throwOnCheckOut = const FirestoreException(
      'Khách chưa check-in',
    );

    final ok = await provider.checkOut('1');

    expect(ok, isFalse);
    expect(provider.errorMessage, 'Khách chưa check-in');
  });
}

VisitorModel _visitor({
  required String id,
  String? name,
  String phone = '0900000000',
  String apt = 'A-101',
  String status = VisitorStatus.registered,
}) {
  final now = DateTime(2026, 7, 1);
  return VisitorModel(
    id: id,
    visitorName: name ?? 'Khách $id',
    visitorPhone: phone,
    purpose: 'Thăm',
    registeredBy: 'res-1',
    apartmentId: apt,
    expectedTime: now,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeVisitorRepository implements VisitorRepository {
  List<VisitorModel> all = [];
  List<VisitorModel> byResident = [];
  int registerCalls = 0;
  int checkInCalls = 0;
  FirestoreException? throwOnCheckOut;

  @override
  Future<List<VisitorModel>> getAllVisitors() async => List.from(all);

  @override
  Future<List<VisitorModel>> getByResident(String residentId) async =>
      List.from(byResident);

  @override
  Future<VisitorModel?> getVisitor(String id) async {
    try {
      return all.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String> registerVisitor({
    required String visitorName,
    required String visitorPhone,
    required String purpose,
    required String registeredBy,
    required String apartmentId,
    required DateTime expectedTime,
  }) async {
    registerCalls++;
    return 'new-visitor';
  }

  @override
  Future<void> checkIn({
    required String visitorId,
    required String staffId,
  }) async {
    checkInCalls++;
  }

  @override
  Future<void> checkOut({required String visitorId}) async {
    if (throwOnCheckOut != null) throw throwOnCheckOut!;
  }
}
