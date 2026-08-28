import '../../../models/organization_model.dart';
import '../../../models/student_profile_model.dart';
import '../../../models/user_model.dart';

import 'dart:async';

/// Service abstraction for Authentication.
/// Can be replaced with a real Firebase / REST API Auth implementation in Phase 9.
abstract class AuthService {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String educationLevel,
    required String degree,
    required String fieldOfStudy,
    required String university,
    required List<String> skills,
    required List<String> careerInterests,
  });
  Future<UserModel> registerOrganization({
    required String orgName,
    required String orgType,
    required String officialEmail,
    required String password,
    required String website,
    required String city,
    required String registrationNumber,
  });
  Future<void> sendPasswordReset(String email);
  Future<void> logout();
  Future<StudentProfileModel?> getStudentProfile(String userId);
  Future<OrganizationModel?> getOrganizationProfile(String userId);
}

/// [MOCK IMPLEMENTATION]
/// Provides mock authentication logic and pre-seeded Pakistan student & university accounts.
class MockAuthService implements AuthService {
  // Pre-seeded Mock Student
  static final UserModel _mockStudentUser = UserModel(
    id: 'usr_student_01',
    name: 'Fatima Zahra',
    email: 'fatima.zahra@nust.edu.pk',
    role: UserRole.student,
    avatarUrl: null,
    createdAt: DateTime.now().subtract(const Duration(days: 90)),
  );

  static final StudentProfileModel _mockStudentProfile = StudentProfileModel(
    id: 'prof_student_01',
    userId: 'usr_student_01',
    fullName: 'Fatima Zahra',
    educationLevel: 'Undergraduate',
    degree: 'BS Computer Science',
    fieldOfStudy: 'Computer Science & AI',
    universityOrCollege: 'National University of Sciences & Technology (NUST)',
    gpa: 3.82,
    graduationYear: 2026,
    skills: [
      'Flutter',
      'Python',
      'Machine Learning',
      'Data Structures',
      'SQL',
      'FastAPI',
    ],
    careerInterests: [
      'AI Engineer',
      'Mobile App Developer',
      'Tech Entrepreneurship',
    ],
    city: 'Islamabad, Pakistan',
    completionPercentage: 0.85,
  );

  // Pre-seeded Mock Organization
  static final UserModel _mockOrgUser = UserModel(
    id: 'usr_org_01',
    name: 'National University of Sciences & Technology (NUST)',
    email: 'admissions@nust.edu.pk',
    role: UserRole.organization,
    avatarUrl: null,
    createdAt: DateTime.now().subtract(const Duration(days: 180)),
  );

  static const OrganizationModel _mockOrgProfile = OrganizationModel(
    id: 'prof_org_01',
    userId: 'usr_org_01',
    orgName: 'National University of Sciences & Technology (NUST)',
    orgType: 'University / Higher Education',
    website: 'https://nust.edu.pk',
    officialEmail: 'admissions@nust.edu.pk',
    contactPerson: 'Director Admissions',
    city: 'Islamabad',
    isVerified: true, // Verified by HEC
    registrationNumber: 'HEC-PK-NUST-001',
  );

  UserModel? _currentUser;
  StudentProfileModel? _currentStudentProfile;
  OrganizationModel? _currentOrgProfile;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.contains('org') ||
        normalizedEmail.contains('nust.edu.pk') &&
            normalizedEmail.startsWith('admissions')) {
      _currentUser = _mockOrgUser;
      _currentOrgProfile = _mockOrgProfile;
      _authStateController.add(_currentUser);
      return _mockOrgUser;
    } else {
      // Default to student login
      _currentUser = _mockStudentUser.copyWith(
        email: email,
        name: normalizedEmail.startsWith('fatima')
            ? 'Fatima Zahra'
            : 'Ali Khan',
      );
      _currentStudentProfile = _mockStudentProfile.copyWith(
        fullName: _currentUser!.name,
      );
      _authStateController.add(_currentUser);
      return _currentUser!;
    }
  }

  @override
  Future<UserModel> registerStudent({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String educationLevel,
    required String degree,
    required String fieldOfStudy,
    required String university,
    required List<String> skills,
    required List<String> careerInterests,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: fullName,
      email: email,
      role: UserRole.student,
      createdAt: DateTime.now(),
    );

    final newProfile = StudentProfileModel(
      id: 'prof_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      fullName: fullName,
      educationLevel: educationLevel,
      degree: degree,
      fieldOfStudy: fieldOfStudy,
      universityOrCollege: university,
      skills: skills,
      careerInterests: careerInterests,
      city: city,
      completionPercentage: 0.75,
    );

    _currentUser = newUser;
    _currentStudentProfile = newProfile;
    _authStateController.add(newUser);
    return newUser;
  }

  @override
  Future<UserModel> registerOrganization({
    required String orgName,
    required String orgType,
    required String officialEmail,
    required String password,
    required String website,
    required String city,
    required String registrationNumber,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final newUser = UserModel(
      id: 'usr_org_${DateTime.now().millisecondsSinceEpoch}',
      name: orgName,
      email: officialEmail,
      role: UserRole.organization,
      createdAt: DateTime.now(),
    );

    final newOrg = OrganizationModel(
      id: 'org_${DateTime.now().millisecondsSinceEpoch}',
      userId: newUser.id,
      orgName: orgName,
      orgType: orgType,
      website: website,
      officialEmail: officialEmail,
      city: city,
      registrationNumber: registrationNumber,
      isVerified: false, // New submissions require manual verification review
    );

    _currentUser = newUser;
    _currentOrgProfile = newOrg;
    _authStateController.add(newUser);
    return newUser;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Simulation: successfully sent reset instructions
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _currentStudentProfile = null;
    _currentOrgProfile = null;
    _authStateController.add(null);
  }

  @override
  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    return _currentStudentProfile ?? _mockStudentProfile;
  }

  @override
  Future<OrganizationModel?> getOrganizationProfile(String userId) async {
    return _currentOrgProfile ?? _mockOrgProfile;
  }
}
