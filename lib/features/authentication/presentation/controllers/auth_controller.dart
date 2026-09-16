import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../models/organization_model.dart';
import '../../../../models/student_profile_model.dart';
import '../../../../models/user_model.dart';
import '../../domain/auth_state.dart';
import '../../data/firebase_auth_service.dart';
import '../../data/mock_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return Firebase.apps.isEmpty ? MockAuthService() : FirebaseAuthService();
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return AuthController(authService);
  },
);

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  int _sessionVersion = 0;

  AuthController(this._authService) : super(AuthState.loading()) {
    _authService.authStateChanges.listen(_restoreSession);
  }

  Future<void> _restoreSession(UserModel? user) async {
    final sessionVersion = ++_sessionVersion;
    if (user == null) {
      state = const AuthState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      isAuthenticated: true,
      currentUser: user,
      errorMessage: null,
    );

    final studentProfile = await _authService.getStudentProfile(user.id);
    final organizationProfile = await _authService.getOrganizationProfile(
      user.id,
    );

    if (sessionVersion != _sessionVersion) return;

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      currentUser: user,
      studentProfile: studentProfile,
      organizationProfile: organizationProfile,
      errorMessage: null,
    );
  }

  /// Sets whether the user has finished onboarding.
  void completeOnboarding() {
    state = state.copyWith(isFirstTime: false);
  }

  /// Sign In with Email & Password
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email: email, password: password);
      final studentProfile = await _authService.getStudentProfile(user.id);
      final orgProfile = await _authService.getOrganizationProfile(user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        studentProfile: studentProfile,
        organizationProfile: orgProfile,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  /// Quick Demo Sign-in for immediate review testing
  Future<bool> demoLoginAsStudent() async {
    return login(email: 'fatima.zahra@nust.edu.pk', password: 'Password123');
  }

  /// Quick Demo Sign-in as Organization
  Future<bool> demoLoginAsOrg() async {
    return login(email: 'admissions@nust.edu.pk', password: 'Password123');
  }

  /// Register as a Student
  Future<bool> registerStudent({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.registerStudent(
        fullName: fullName,
        email: email,
        password: password,
        city: city,
        educationLevel: educationLevel,
        degree: degree,
        fieldOfStudy: fieldOfStudy,
        university: university,
        skills: skills,
        careerInterests: careerInterests,
      );
      await _authService.logout();

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        currentUser: null,
        studentProfile: null,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<bool> updateStudentSkills(List<String> skills) async {
    final userId = state.currentUser?.id;
    if (userId == null || state.studentProfile == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _authService.updateStudentSkills(userId, skills);
      state = state.copyWith(
        isLoading: false,
        studentProfile: profile,
        errorMessage: null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  /// Register as an Organization
  Future<bool> registerOrganization({
    required String orgName,
    required String orgType,
    required String officialEmail,
    required String password,
    required String website,
    required String city,
    required String registrationNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.registerOrganization(
        orgName: orgName,
        orgType: orgType,
        officialEmail: officialEmail,
        password: password,
        website: website,
        city: city,
        registrationNumber: registrationNumber,
      );
      await _authService.logout();

      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        currentUser: null,
        organizationProfile: null,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  /// Send Forgot Password Reset
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  Future<bool> updateStudentProfile(StudentProfileModel profile) async {
    final userId = state.currentUser?.id;
    if (userId == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _authService.updateStudentProfile(userId, profile);
      state = state.copyWith(
        isLoading: false,
        studentProfile: updated,
        currentUser: state.currentUser?.copyWith(name: updated.fullName),
        errorMessage: null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<bool> updateOrganizationProfile(OrganizationModel profile) async {
    final userId = state.currentUser?.id;
    if (userId == null) return false;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _authService.updateOrganizationProfile(userId, profile);
      state = state.copyWith(
        isLoading: false,
        organizationProfile: updated,
        currentUser: state.currentUser?.copyWith(name: updated.orgName),
        errorMessage: null,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  /// Delete Account
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.deleteAccount();
      _sessionVersion++;
      state = const AuthState();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _friendlyError(e));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _sessionVersion++;
    await _authService.logout();
    state = const AuthState();
  }

  String _friendlyError(Object error) =>
      error.toString().replaceFirst(RegExp(r'^(Exception|StateError): '), '');
}
