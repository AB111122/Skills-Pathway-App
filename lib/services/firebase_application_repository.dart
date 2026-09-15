import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/application_model.dart';
import '../models/notification_model.dart';
import 'application_repository.dart';
import 'firestore_serializers.dart';
import 'notification_service.dart';

class FirebaseApplicationRepository implements ApplicationRepository {
  FirebaseApplicationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection('applications');

  @override
  Future<ApplicationModel> create(ApplicationModel application) async {
    _requireSignedIn();
    final existing = await findForStudentAndOpportunity(
      application.studentId,
      application.opportunityId,
    );
    if (existing != null) return existing;
    final documentId = '${application.studentId}_${application.opportunityId}';
    final reference = _applications.doc(documentId);
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
  Future<List<ApplicationModel>> forOrganizationOpportunity(
    String organizationId,
    String opportunityId,
  ) async {
    _requireSignedIn();
    if (_auth.currentUser!.uid != organizationId) {
      throw StateError('You can only view your own applicants.');
    }
    final snapshot = await _applications
        .where('organizationId', isEqualTo: organizationId)
        .get();
    return snapshot.docs
        .map(_fromSnapshot)
        .where((application) => application.opportunityId == opportunityId)
        .toList();
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
      throw StateError(
        'You can only update applications for your own opportunities.',
      );
    }
    await reference.update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await NotificationService().createForUser(
      recipientId: application.studentId,
      title: 'Application status updated',
      message: '${application.opportunityTitle}: ${status.name}',
      type: NotificationType.application,
      opportunityId: application.opportunityId,
      applicationId: application.id,
    );
    return application.copyWith(status: status);
  }

  @override
  Future<ApplicationModel?> findForStudentAndOpportunity(
    String studentId,
    String opportunityId,
  ) async {
    _requireSignedIn();
    final path = 'applications/${studentId}_$opportunityId';
    debugPrint(
      '[FirebaseApplicationRepository] Querying application for: "$path" (Auth UID: ${_auth.currentUser?.uid})',
    );
    try {
      final snapshot = await _applications
          .where('studentId', isEqualTo: studentId)
          .where('opportunityId', isEqualTo: opportunityId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty
          ? _fromSnapshot(snapshot.docs.first)
          : null;
    } on FirebaseException catch (e, stackTrace) {
      debugPrint(
        '[FirebaseApplicationRepository] Error reading "$path" - ${e.code}: ${e.message}',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
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
