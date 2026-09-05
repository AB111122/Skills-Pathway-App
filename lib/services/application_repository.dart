import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/application_model.dart';
import 'firebase_application_repository.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => Firebase.apps.isEmpty
      ? MockApplicationRepository.instance
      : FirebaseApplicationRepository(),
);

abstract class ApplicationRepository {
  Future<ApplicationModel> create(ApplicationModel application);
  Future<List<ApplicationModel>> forOpportunity(String opportunityId);
  Future<List<ApplicationModel>> forOrganizationOpportunity(
    String organizationId,
    String opportunityId,
  );
  Future<List<ApplicationModel>> forStudent(String studentId);
  Future<ApplicationModel> updateStatus(
    String universityId,
    String applicationId,
    ApplicationStatus status,
  );
  Future<ApplicationModel?> findForStudentAndOpportunity(
    String studentId,
    String opportunityId,
  );
}

class MockApplicationRepository implements ApplicationRepository {
  static final MockApplicationRepository instance =
      MockApplicationRepository._();
  MockApplicationRepository._();
  final List<ApplicationModel> _applications = [];

  @override
  Future<ApplicationModel> create(ApplicationModel application) async {
    final existing = _applications.where(
      (item) =>
          item.studentId == application.studentId &&
          item.opportunityId == application.opportunityId,
    );
    if (existing.isNotEmpty) return existing.first;
    _applications.add(application);
    return application;
  }

  @override
  Future<List<ApplicationModel>> forOpportunity(String opportunityId) async =>
      _applications
          .where((item) => item.opportunityId == opportunityId)
          .toList();

  @override
  Future<List<ApplicationModel>> forOrganizationOpportunity(
    String organizationId,
    String opportunityId,
  ) async => _applications
      .where(
        (item) =>
            item.universityId == organizationId &&
            item.opportunityId == opportunityId,
      )
      .toList();

  @override
  Future<List<ApplicationModel>> forStudent(String studentId) async =>
      _applications.where((item) => item.studentId == studentId).toList();

  @override
  Future<ApplicationModel> updateStatus(
    String universityId,
    String applicationId,
    ApplicationStatus status,
  ) async {
    final index = _applications.indexWhere((item) => item.id == applicationId);
    if (index < 0 || _applications[index].universityId != universityId) {
      throw StateError(
        'You can only update applicants for your own university.',
      );
    }
    _applications[index] = _applications[index].copyWith(status: status);
    return _applications[index];
  }

  @override
  Future<ApplicationModel?> findForStudentAndOpportunity(
    String studentId,
    String opportunityId,
  ) async {
    for (final application in _applications) {
      if (application.studentId == studentId &&
          application.opportunityId == opportunityId) {
        return application;
      }
    }
    return null;
  }
}
