import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/features/authentication/data/mock_auth_service.dart';
import 'package:skills_pathway_app/features/authentication/domain/auth_state.dart';
import 'package:skills_pathway_app/models/user_model.dart';

void main() {
  group('Authentication & Session Role Restoration Suite', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('Student login correctly resolves UserRole.student and profile', () async {
      final user = await authService.login(
        email: 'student@example.com',
        password: 'Password123',
      );

      expect(user.role, UserRole.student);
      expect(user.isStudent, isTrue);
      expect(user.isOrganization, isFalse);

      final profile = await authService.getStudentProfile(user.id);
      expect(profile, isNotNull);
      expect(profile?.fullName.isNotEmpty, isTrue);
      expect(profile?.educationLevel.isNotEmpty, isTrue);
    });

    test('University login correctly resolves UserRole.organization and profile', () async {
      final user = await authService.login(
        email: 'admissions@nust.edu.pk',
        password: 'Password123',
      );

      expect(user.role, UserRole.organization);
      expect(user.isOrganization, isTrue);
      expect(user.isStudent, isFalse);

      final profile = await authService.getOrganizationProfile(user.id);
      expect(profile, isNotNull);
      expect(profile?.orgName.isNotEmpty, isTrue);
      expect(profile?.orgType.isNotEmpty, isTrue);
    });

    test('Student registration creates full student profile and emits stream update', () async {
      final emittedUsers = <UserModel?>[];
      final sub = authService.authStateChanges.listen(emittedUsers.add);

      final newUser = await authService.registerStudent(
        fullName: 'Ali Khan',
        email: 'ali.khan@example.com',
        password: 'SecurePassword123',
        city: 'Islamabad',
        educationLevel: 'Undergraduate',
        degree: 'BS Artificial Intelligence',
        fieldOfStudy: 'Computer Science',
        university: 'FAST NUCES',
        skills: ['Flutter', 'Python', 'Dart'],
        careerInterests: ['AI Engineering', 'Mobile Development'],
      );

      await Future<void>.delayed(Duration.zero);

      expect(newUser.role, UserRole.student);
      expect(newUser.email, 'ali.khan@example.com');
      expect(emittedUsers.last?.id, newUser.id);

      final studentProfile = await authService.getStudentProfile(newUser.id);
      expect(studentProfile?.fullName, 'Ali Khan');
      expect(studentProfile?.skills, contains('Flutter'));
      expect(studentProfile?.city, 'Islamabad');

      await sub.cancel();
    });

    test('Organization registration creates unverified profile and correct role', () async {
      final orgUser = await authService.registerOrganization(
        orgName: 'Lahore University of Management Sciences',
        orgType: 'University / Higher Education',
        officialEmail: 'admissions@lums.edu.pk',
        password: 'UniversityPassword123',
        website: 'https://lums.edu.pk',
        city: 'Lahore',
        registrationNumber: 'HEC-LUMS-001',
      );

      expect(orgUser.role, UserRole.organization);
      expect(orgUser.isOrganization, isTrue);

      final orgProfile = await authService.getOrganizationProfile(orgUser.id);
      expect(orgProfile?.orgName, 'Lahore University of Management Sciences');
      expect(orgProfile?.isVerified, isFalse);
      expect(orgProfile?.website, 'https://lums.edu.pk');
    });

    test('Logout clears session completely and emits null on stream', () async {
      final emittedUsers = <UserModel?>[];
      final sub = authService.authStateChanges.listen(emittedUsers.add);

      final loggedIn = await authService.login(
        email: 'student@example.com',
        password: 'Password123',
      );
      await Future<void>.delayed(Duration.zero);
      expect(emittedUsers.last?.id, loggedIn.id);

      await authService.logout();
      await Future<void>.delayed(Duration.zero);
      expect(emittedUsers.last, isNull);

      await sub.cancel();
    });

    test('AuthState does not default organization user to student during resolution', () {
      final state = AuthState.initial().copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: UserModel(
          id: 'org_nust_99',
          name: 'NUST Admissions',
          email: 'admissions@nust.edu.pk',
          role: UserRole.organization,
          createdAt: DateTime.now(),
        ),
      );

      expect(state.isOrganization, isTrue);
      expect(state.isStudent, isFalse);
      expect(state.currentUser?.role, UserRole.organization);
    });
  });
}
