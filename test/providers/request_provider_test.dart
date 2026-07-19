import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/request_model.dart';
import 'package:prm393_project/providers/request_provider.dart';
import 'package:prm393_project/services/base_firestore_service.dart';
import 'package:prm393_project/services/request_service.dart';

void main() {
  late FakeRequestRepository repository;
  late RequestProvider provider;

  setUp(() {
    repository = FakeRequestRepository();
    provider = RequestProvider(requestService: repository);
  });

  tearDown(() {
    provider.dispose();
  });

  test('loadResidentRequests populates list', () async {
    repository.residentRequests = [
      _request(id: '1', title: 'A', status: RequestStatus.pending),
      _request(id: '2', title: 'B', status: RequestStatus.completed),
    ];

    await provider.loadResidentRequests('res-1');

    expect(provider.isLoading, isFalse);
    expect(provider.requests, hasLength(2));
    expect(provider.errorMessage, isNull);
  });

  test('setStatusFilter filters in memory', () async {
    repository.allRequests = [
      _request(id: '1', title: 'A', status: RequestStatus.pending),
      _request(id: '2', title: 'B', status: RequestStatus.completed),
    ];
    await provider.loadAllRequests();
    provider.setStatusFilter(RequestStatus.pending);

    expect(provider.filteredRequests, hasLength(1));
    expect(provider.filteredRequests.single.id, '1');
  });

  test('createRequest success reloads resident list', () async {
    repository.createdId = 'new-1';
    repository.residentRequests = [
      _request(id: 'new-1', title: 'Moi', status: RequestStatus.pending),
    ];

    final ok = await provider.createRequest(
      title: 'Moi',
      description: 'Mo ta',
      category: RequestCategory.general,
      residentId: 'res-1',
      apartmentId: 'apt-1',
    );

    expect(ok, isTrue);
    expect(repository.createCalls, 1);
    expect(provider.requests, hasLength(1));
  });

  test('createRequest surfaces FirestoreException message', () async {
    repository.throwOnCreate = const FirestoreException('Lỗi mạng giả');

    final ok = await provider.createRequest(
      title: 'X',
      description: 'Y',
      category: RequestCategory.general,
      residentId: 'res-1',
      apartmentId: 'apt-1',
    );

    expect(ok, isFalse);
    expect(provider.errorMessage, 'Lỗi mạng giả');
  });

  test('updateStatus refreshes selected request', () async {
    repository.detail = _request(
      id: '1',
      title: 'A',
      status: RequestStatus.pending,
    );
    await provider.loadRequestDetail('1');

    repository.detail = _request(
      id: '1',
      title: 'A',
      status: RequestStatus.inProgress,
    );

    final ok = await provider.updateStatus(
      requestId: '1',
      status: RequestStatus.inProgress,
      staffId: 'staff-1',
    );

    expect(ok, isTrue);
    expect(provider.selected?.status, RequestStatus.inProgress);
    expect(repository.updateStatusCalls, 1);
  });
}

RequestModel _request({
  required String id,
  required String title,
  required RequestStatus status,
}) {
  final now = DateTime(2026, 7, 1);
  return RequestModel(
    id: id,
    title: title,
    description: 'desc',
    category: RequestCategory.general,
    residentId: 'res-1',
    apartmentId: 'apt-1',
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeRequestRepository implements RequestRepository {
  List<RequestModel> residentRequests = [];
  List<RequestModel> allRequests = [];
  RequestModel? detail;
  String createdId = 'created';
  int createCalls = 0;
  int updateStatusCalls = 0;
  FirestoreException? throwOnCreate;

  @override
  Future<RequestModel?> getRequest(String id) async => detail;

  @override
  Future<List<RequestModel>> getRequestsByResident(String residentId) async =>
      residentRequests;

  @override
  Future<List<RequestModel>> getAllRequests({RequestStatus? status}) async {
    if (status == null) return allRequests;
    return allRequests.where((r) => r.status == status).toList();
  }

  @override
  Future<String> createRequest({
    required String title,
    required String description,
    required RequestCategory category,
    required String residentId,
    required String apartmentId,
    List<File> imageFiles = const [],
  }) async {
    if (throwOnCreate != null) throw throwOnCreate!;
    createCalls++;
    return createdId;
  }

  @override
  Future<void> updateStatus({
    required String requestId,
    required RequestStatus status,
    String? staffId,
    String? resolutionNote,
  }) async {
    updateStatusCalls++;
  }

  @override
  Future<void> deleteRequest(String requestId) async {}
}
