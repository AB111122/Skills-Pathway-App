import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';
import 'application_repository.dart';
import 'firestore_serializers.dart';

class FirebaseApplicationRepository implements ApplicationRepository {
  FirebaseApplicationRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  @override
  Future<ApplicationModel> create(ApplicationModel application) async {
    _requireSignedIn();
    final documentId = '${application.studentId}_${application.opportunityId}';
    final reference = _applications.doc(documentId);
    final existing = await reference.get();
    if (existing.exists) return _fromSnapshot(existing);
    await reference.set({
      ...FirestoreSerializers.applicationToMap(application),
      'id': documentId,
      'studentEmail': _auth.currentUser?.email,
    });
    return application.copyWith(status: ApplicationStatus.pending);
  }

  @override
  Future<List<ApplicationModel>> forOpportunity(String opportunityId) async {
    final snapshot = await _applications
        .where('opportunityId', isEqualTo: opportunityId)
        .get();
    return snapshot.docs.map(_fromSnapshot).toList();
  }

  @override
  Future<List<ApplicationModel>> forStudent(String studentId) async {
    _requireSignedIn();
    if (_auth.currentUser!.uid != studentId) {
      throw StateError('You can only view your own applications.');
    }
    final snapshot = await _applications
        .where('studentId', isEqualTo: studentId)
        .get();
    return snapshot.docs.map(_fromSnapshot).toList();
  }

  @override
  Future<ApplicationModel> updateStatus(
    String universityId,
    String applicationId,
    ApplicationStatus status,
  ) async {
    _requireSignedIn();
    final reference = _applications.doc(applicationId);
    final snapshot = await reference.get();
    if (!snapshot.exists) throw StateError('Application not found.');
    final application = _fromSnapshot(snapshot);
    if (application.universityId != universityId ||
        _auth.currentUser!.uid != universityId) {
      throw StateError('You can only update applications for your own opportunities.');
    }
    await reference.update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return application.copyWith(status: status);
  }

  @override
  Future<ApplicationModel?> findForStudentAndOpportunity(
    String studentId,
    String opportunityId,
  ) async {
    _requireSignedIn();
    final snapshot = await _applications
        .doc('${studentId}_$opportunityId')
        .get();
    return snapshot.exists ? _fromSnapshot(snapshot) : null;
  }

  void _requireSignedIn() {
    if (_auth.currentUser == null) throw StateError('Please sign in first.');
  }

  ApplicationModel _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return FirestoreSerializers.applicationFromMap(
      snapshot.data()!,
      id: snapshot.id,
    );
  }
}

