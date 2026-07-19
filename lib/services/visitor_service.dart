import 'base_firestore_service.dart';
import '../utils/constants.dart';

class VisitorService extends BaseFirestoreService {
  VisitorService({super.firestore});

  @override
  String get collectionPath => AppCollections.visitors;
}
