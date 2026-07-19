import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/complaint_model.dart';
import 'package:prm393_project/providers/complaint_provider.dart';
import 'package:prm393_project/services/base_firestore_service.dart';
import 'package:prm393_project/services/complaint_service.dart';

void main() {
  late FakeComplaintRepository repository;
  late ComplaintProvider provider;

  setUp(() {
    repository = FakeComplaintRepository();
    provider = ComplaintProvider(complaintService: repository);
  });

  tearDown(() {
    provider.dispose();
  });

  test('loadResidentComplaints populates list', () async {
    repository.byResident = [
      _complaint(id: '1', status: ComplaintStatus.submitted),
      _complaint(id: '2', status: ComplaintStatus.resolved),
    ];

    await provider.loadResidentComplaints('res-1');

    expect(provider.complaints, hasLength(2));
    expect(provider.errorMessage, isNull);
  });

  test('createComplaint success then reloads', () async {
    repository.byResident = [
      _complaint(id: 'new', status: ComplaintStatus.submitted),
    ];

    final ok = await provider.createComplaint(
      content: 'Ồn ào',
      residentId: 'res-1',
      apartmentId: 'apt-1',
    );

    expect(ok, isTrue);
    expect(repository.createCalls, 1);
    expect(provider.complaints, hasLength(1));
  });

  test('respond marks selected as resolved', () async {
    repository.detail = _complaint(id: '1', status: ComplaintStatus.inReview);
    await provider.loadDetail('1');

    repository.detail = _complaint(
      id: '1',
      status: ComplaintStatus.resolved,
    ).copyWith(response: 'OK');

    final ok = await provider.respond(
      complaintId: '1',
      response: 'OK',
      respondedBy: 'staff-1',
    );

    expect(ok, isTrue);
    expect(repository.respondCalls, 1);
    expect(provider.selected?.status, ComplaintStatus.resolved);
  });

  test('markInReview surfaces errors', () async {
    repository.throwOnReview = const FirestoreException('Không có quyền');

    final ok = await provider.markInReview('1');

    expect(ok, isFalse);
    expect(provider.errorMessage, 'Không có quyền');
  });
}

ComplaintModel _complaint({
  required String id,
  required ComplaintStatus status,
}) {
  final now = DateTime(2026, 7, 1);
  return ComplaintModel(
    id: id,
    content: 'Nội dung $id',
    residentId: 'res-1',
    apartmentId: 'apt-1',
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeComplaintRepository implements ComplaintRepository {
  List<ComplaintModel> byResident = [];
  List<ComplaintModel> all = [];
  ComplaintModel? detail;
  int createCalls = 0;
  int respondCalls = 0;
  FirestoreException? throwOnReview;

  @override
  Future<ComplaintModel?> getComplaint(String id) async => detail;

  @override
  Future<List<ComplaintModel>> getComplaintsByResident(
    String residentId,
  ) async => byResident;

  @override
  Future<List<ComplaintModel>> getAllComplaints({
    ComplaintStatus? status,
  }) async {
    if (status == null) return all;
    return all.where((c) => c.status == status).toList();
  }

  @override
  Future<String> createComplaint({
    required String content,
    required String residentId,
    required String apartmentId,
  }) async {
    createCalls++;
    return 'created';
  }

  @override
  Future<void> respond({
    required String complaintId,
    required String response,
    required String respondedBy,
    ComplaintStatus status = ComplaintStatus.resolved,
  }) async {
    respondCalls++;
  }

  @override
  Future<void> markInReview(String complaintId) async {
    if (throwOnReview != null) throw throwOnReview!;
  }
}
