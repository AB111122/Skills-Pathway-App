import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/application_model.dart';
import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';
import 'application_repository.dart';
import 'firebase_application_repository.dart';
import 'firestore_serializers.dart';
import 'opportunity_service.dart';

class FirebaseOpportunityService implements OpportunityService {
  FirebaseOpportunityService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ApplicationRepository? applications,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _applications = applications ?? FirebaseApplicationRepository();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final ApplicationRepository _applications;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection('opportunities');

  @override
  Future<List<OpportunityModel>> getOpportunities({
    OpportunityFilterModel? filter,
  }) async {
    final snapshot = await _opportunities
        .where('status', isNotEqualTo: OpportunityStatus.closed.name)
        .get();
    final items = <OpportunityModel>[];
    for (final document in snapshot.docs) {
      final opportunity = _fromSnapshot(document);
      if (opportunity.deadline.isBefore(DateTime.now())) continue;
      items.add(await _withStudentState(opportunity));
    }
    return _applyFilter(items, filter);
  }

  @override
  Future<OpportunityModel?> getOpportunityById(String id) async {
    final snapshot = await _opportunities.doc(id).get();
    if (!snapshot.exists) return null;
    return _withStudentState(_fromSnapshot(snapshot));
  }

  @override
  Future<bool> toggleSaveOpportunity(String id) async {
    final user = _requireStudent();
    final reference = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedOpportunities')
        .doc(id);
    final existing = await reference.get();
    if (existing.exists) {
      await reference.delete();
      return false;
    }
    await reference.set({'opportunityId': id, 'savedAt': FieldValue.serverTimestamp()});
    return true;
  }

  @override
  Future<bool> markAsApplied(String id) async {
    final user = _requireStudent();
    final opportunity = await getOpportunityById(id);
    if (opportunity == null ||
        opportunity.isClosed ||
        opportunity.deadline.isBefore(DateTime.now())) {
      return false;
    }
    if (await _applications.findForStudentAndOpportunity(user.uid, id) != null) {
      return false;
    }
    final profile = await _firestore.collection('users').doc(user.uid).get();
    final data = profile.data() ?? const <String, dynamic>{};
    await _applications.create(ApplicationModel(
      id: '${user.uid}_$id',
      studentId: user.uid,
      studentName: data['name'] as String? ?? user.displayName ?? '',
      opportunityId: id,
      opportunityTitle: opportunity.title,
      universityId: opportunity.organizationId ?? '',
      universityName: opportunity.organizationName,
      applicationDate: DateTime.now(),
    ));
    await _opportunities.doc(id).update({'applicationCount': FieldValue.increment(1)});
    return true;
  }

  @override
  Future<bool> toggleDeadlineReminder(String id) async {
    final user = _requireStudent();
    final reference = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('deadlineReminders')
        .doc(id);
    final existing = await reference.get();
    if (existing.exists) {
      await reference.delete();
      return false;
    }
    await reference.set({'opportunityId': id, 'createdAt': FieldValue.serverTimestamp()});
    return true;
  }

  @override
  Future<List<OpportunityModel>> getSavedOpportunities() async {
    final user = _requireStudent();
    final saved = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('savedOpportunities')
        .get();
    final items = <OpportunityModel>[];
    for (final item in saved.docs) {
      final opportunity = await getOpportunityById(item.id);
      if (opportunity != null) items.add(opportunity.copyWith(isSaved: true));
    }
    return items;
  }

  @override
  Future<List<OpportunityModel>> getAppliedOpportunities() async {
    final user = _requireStudent();
    final applications = await _applications.forStudent(user.uid);
    final items = <OpportunityModel>[];
    for (final application in applications) {
      final opportunity = await getOpportunityById(application.opportunityId);
      if (opportunity != null) {
        items.add(opportunity.copyWith(
          isApplied: true,
          appliedAt: application.applicationDate,
        ));
      }
    }
    return items;
  }

  Future<List<OpportunityModel>> getManagedOpportunities(String organizationId) async {
    _requireOrganization(organizationId);
    final snapshot = await _opportunities
        .where('organizationId', isEqualTo: organizationId)
        .get();
    return snapshot.docs.map(_fromSnapshot).toList();
  }

  Future<OpportunityModel> createUniversityOpportunity({
    required String organizationId,
    required String organizationName,
    required String title,
    required String description,
    required OpportunityType type,
    required DateTime deadline,
    required String location,
    required String applicationUrl,
  }) async {
    _requireOrganization(organizationId);
    final reference = _opportunities.doc();
    final item = OpportunityModel(
      id: reference.id,
      title: title,
      organizationName: organizationName,
      organizationId: organizationId,
      createdBy: organizationId,
      type: type,
      location: location,
      deadline: deadline,
      isVerified: false,
      isPaid: type == OpportunityType.internship,
      stipendOrFunding: 'See opportunity details',
      shortDescription: description,
      fullDescription: description,
      officialUrl: applicationUrl,
      requiredSkills: const [],
      eligibleFields: const [],
      createdAt: DateTime.now(),
    );
    await reference.set(_toFirestore(item));
    return item;
  }

  Future<void> updateUniversityOpportunity(
    String organizationId,
    OpportunityModel updated,
  ) async {
    _requireOrganization(organizationId);
    await _opportunities.doc(updated.id).update(_toFirestore(updated));
  }

  Future<void> closeUniversityOpportunity(String organizationId, String id) async {
    _requireOrganization(organizationId);
    await _opportunities.doc(id).update({
      'status': OpportunityStatus.closed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUniversityOpportunity(String organizationId, String id) async {
    _requireOrganization(organizationId);
    await _opportunities.doc(id).delete();
  }

  User _requireStudent() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in first.');
    return user;
  }

  void _requireOrganization(String organizationId) {
    final user = _requireStudent();
    if (user.uid != organizationId) {
      throw StateError('You can only manage your own opportunities.');
    }
  }

  OpportunityModel _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return FirestoreSerializers.opportunityFromMap(
      snapshot.data() ?? {},
      id: snapshot.id,
    );
  }

  Map<String, dynamic> _toFirestore(OpportunityModel item) {
    return FirestoreSerializers.opportunityToMap(item);
  }

  Future<OpportunityModel> _withStudentState(OpportunityModel item) async {
    final user = _auth.currentUser;
    if (user == null) return item;
    final saved = await _firestore.collection('users').doc(user.uid)
        .collection('savedOpportunities').doc(item.id).get();
    final application = await _applications.findForStudentAndOpportunity(user.uid, item.id);
    return item.copyWith(
      isSaved: saved.exists,
      isApplied: application != null,
      appliedAt: application?.applicationDate,
    );
  }

  List<OpportunityModel> _applyFilter(
    List<OpportunityModel> items,
    OpportunityFilterModel? filter,
  ) {
    if (filter == null) return items;
    return items.where((opp) {
      final query = filter.searchQuery.toLowerCase().trim();
      if (query.isNotEmpty &&
          !('${opp.title} ${opp.organizationName} ${opp.shortDescription} ${opp.requiredSkills.join(' ')} ${opp.eligibleFields.join(' ')}'.toLowerCase().contains(query))) return false;
      if (filter.opportunityType != null && opp.type != filter.opportunityType) return false;
      if (filter.location != null && filter.location != 'All' && !opp.location.toLowerCase().contains(filter.location!.toLowerCase())) return false;
      if (filter.field != null && filter.field != 'All' && !opp.eligibleFields.any((value) => value.toLowerCase().contains(filter.field!.toLowerCase()))) return false;
      if (filter.degreeLevel != null && filter.degreeLevel != 'All' && !(opp.degreeLevel ?? '').toLowerCase().contains(filter.degreeLevel!.toLowerCase())) return false;
      if (filter.isPaidOnly && (!opp.isInternship || !opp.isPaid)) return false;
      if (filter.isVerifiedOnly && !opp.isVerified) return false;
      return true;
    }).toList();
  }
}
