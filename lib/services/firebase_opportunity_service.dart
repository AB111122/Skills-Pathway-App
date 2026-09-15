import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/application_model.dart';
import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';
import 'application_repository.dart';
import 'firebase_application_repository.dart';
import 'firestore_serializers.dart';
import 'opportunity_service.dart';
import 'mock_opportunity_service.dart';

class FirebaseOpportunityService implements OpportunityService {
  FirebaseOpportunityService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    ApplicationRepository? applications,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
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
    final currentUid = _auth.currentUser?.uid;
    debugPrint(
      '[FirebaseOpportunityService] Executing query on collection path: "/opportunities" (flat collection, no where/orderBy clauses). Current FirebaseAuth UID: $currentUid',
    );
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      // Read the public collection without a compound/index-sensitive query;
      // publication, deadline, and filters are enforced below in Dart.
      snapshot = await _opportunities.get();
      debugPrint(
        '[FirebaseOpportunityService] Successfully fetched ${snapshot.docs.length} documents from "/opportunities"',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('[FirebaseOpportunityService] Primary query failed - ${error.code}: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
    Set<String> savedOpportunityIds = {};
    Map<String, DateTime?> appliedOpportunityDates = {};
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final savedSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('savedOpportunities')
            .get();
        savedOpportunityIds = savedSnapshot.docs.map((doc) => doc.id).toSet();
      } catch (e) {
        debugPrint(
          '[FirebaseOpportunityService] Error fetching saved opportunities: $e',
        );
      }

      try {
        final applications = await _applications.forStudent(user.uid);
        for (final app in applications) {
          appliedOpportunityDates[app.opportunityId] = app.applicationDate;
        }
      } catch (e) {
        debugPrint(
          '[FirebaseOpportunityService] Error fetching student applications: $e',
        );
      }
    }

    final items = <OpportunityModel>[];
    for (final document in snapshot.docs) {
      try {
        final opportunity = _fromSnapshot(document);
        if (opportunity.status != OpportunityStatus.published) {
          continue;
        }
        if (opportunity.deadline.isBefore(DateTime.now())) {
          continue;
        }
        final isSaved = savedOpportunityIds.contains(opportunity.id);
        final isApplied = appliedOpportunityDates.containsKey(opportunity.id);
        final appliedAt = appliedOpportunityDates[opportunity.id];
        items.add(
          opportunity.copyWith(
            isSaved: isSaved,
            isApplied: isApplied,
            appliedAt: appliedAt,
          ),
        );
      } catch (e, stackTrace) {
        debugPrint(
          '[FirebaseOpportunityService] Failed processing doc ${document.id}: $e',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    if (!items.any((item) => item.isScholarship)) {
      final fallbackScholarships = await MockOpportunityService()
          .getOpportunities(
            filter: const OpportunityFilterModel(
              opportunityType: OpportunityType.scholarship,
            ),
          );
      final existingIds = items.map((item) => item.id).toSet();
      items.addAll(
        fallbackScholarships.where((item) => !existingIds.contains(item.id)),
      );
    }
    return _applyFilter(items, filter);
  }

  @override
  Future<OpportunityModel?> getOpportunityById(String id) async {
    final snapshot = await _opportunities.doc(id).get();
    if (!snapshot.exists) return null;
    final opportunity = _fromSnapshot(snapshot);
    if (opportunity.status != OpportunityStatus.published ||
        opportunity.deadline.isBefore(DateTime.now())) {
      return null;
    }
    return _withStudentState(opportunity);
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
    await reference.set({
      'opportunityId': id,
      'savedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Future<bool> markAsApplied(String id) async {
    final user = _requireStudent();
    final opportunity = await getOpportunityById(id);
    if (opportunity == null ||
        opportunity.status != OpportunityStatus.published ||
        opportunity.isClosed ||
        opportunity.deadline.isBefore(DateTime.now())) {
      return false;
    }
    if (await _applications.findForStudentAndOpportunity(user.uid, id) !=
        null) {
      return false;
    }
    final profile = await _firestore.collection('users').doc(user.uid).get();
    final data = profile.data() ?? const <String, dynamic>{};
    await _applications.create(
      ApplicationModel(
        id: '${user.uid}_$id',
        studentId: user.uid,
        studentName: data['name'] as String? ?? user.displayName ?? '',
        opportunityId: id,
        opportunityTitle: opportunity.title,
        universityId: opportunity.organizationId ?? '',
        universityName: opportunity.organizationName,
        applicationDate: DateTime.now(),
      ),
    );
    await _opportunities.doc(id).update({
      'applicationCount': FieldValue.increment(1),
    });
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
    await reference.set({
      'opportunityId': id,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
        items.add(
          opportunity.copyWith(
            isApplied: true,
            appliedAt: application.applicationDate,
          ),
        );
      }
    }
    return items;
  }

  Future<List<OpportunityModel>> getManagedOpportunities(
    String organizationId,
  ) async {
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
    String category = 'General',
    String eligibility = '',
    String contactEmail = '',
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
      category: category,
      isVerified: false,
      isPaid: type == OpportunityType.internship,
      stipendOrFunding: 'See opportunity details',
      shortDescription: description,
      fullDescription: description,
      officialUrl: applicationUrl,
      requiredSkills: const [],
      eligibleFields: const [],
      eligibilityCriteria: eligibility.isEmpty ? const [] : [eligibility],
      status: OpportunityStatus.published,
      createdAt: DateTime.now(),
    );
    await reference.set({
      ..._toFirestore(item),
      'contactEmail': contactEmail,
      'applicationCount': 0,
    });
    return item;
  }

  Future<void> updateUniversityOpportunity(
    String organizationId,
    OpportunityModel updated,
  ) async {
    _requireOrganization(organizationId);
    await _opportunities.doc(updated.id).update(_toFirestore(updated));
  }

  Future<void> closeUniversityOpportunity(
    String organizationId,
    String id,
  ) async {
    _requireOrganization(organizationId);
    await _opportunities.doc(id).update({
      'status': OpportunityStatus.closed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUniversityOpportunity(
    String organizationId,
    String id,
  ) async {
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

  OpportunityModel _fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
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
    if (user == null) {
      debugPrint(
        '[FirebaseOpportunityService] _withStudentState(${item.id}): No user authenticated, skipping secondary reads.',
      );
      return item;
    }
    debugPrint(
      '[FirebaseOpportunityService] _withStudentState(${item.id}): Starting secondary reads for user=${user.uid}',
    );

    bool isSaved = false;
    try {
      final saved = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('savedOpportunities')
          .doc(item.id)
          .get();
      isSaved = saved.exists;
    } catch (e) {
      debugPrint(
        '[FirebaseOpportunityService] [Secondary Read 1] Failed reading savedOpportunities/${item.id}: $e',
      );
    }

    ApplicationModel? application;
    try {
      application = await _applications.findForStudentAndOpportunity(
        user.uid,
        item.id,
      );
    } catch (e) {
      debugPrint(
        '[FirebaseOpportunityService] [Secondary Read 2] Failed reading application for ${item.id}: $e',
      );
    }

    return item.copyWith(
      isSaved: isSaved,
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
          !('${opp.title} ${opp.organizationName} ${opp.shortDescription} ${opp.requiredSkills.join(' ')} ${opp.eligibleFields.join(' ')}'
              .toLowerCase()
              .contains(query))) {
        return false;
      }
      if (filter.opportunityType != null &&
          opp.type != filter.opportunityType) {
        return false;
      }
      if (filter.location != null &&
          filter.location != 'All' &&
          !opp.location.toLowerCase().contains(
            filter.location!.toLowerCase(),
          )) {
        return false;
      }
      if (filter.field != null &&
          filter.field != 'All' &&
          !opp.eligibleFields.any(
            (value) =>
                value.toLowerCase().contains(filter.field!.toLowerCase()),
          )) {
        return false;
      }
      if (filter.degreeLevel != null &&
          filter.degreeLevel != 'All' &&
          !(opp.degreeLevel ?? '').toLowerCase().contains(
            filter.degreeLevel!.toLowerCase(),
          )) {
        return false;
      }
      if (filter.isPaidOnly && (!opp.isInternship || !opp.isPaid)) return false;
      if (filter.isVerifiedOnly && !opp.isVerified) return false;
      return true;
    }).toList();
  }
}
