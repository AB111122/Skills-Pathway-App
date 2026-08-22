import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_state.dart';
import '../../data/mock_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return MockAuthService();
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  /// Sets whether the user has finished onboarding.
  void completeOnboarding() {
    state = state.copyWith(isFirstTime: false);
  }

  /// Sign In with Email & Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Quick Demo Sign-in for immediate review testing
  Future<bool> demoLoginAsStudent() async {
    return login(
      email: 'fatima.zahra@nust.edu.pk',
      password: 'Password123',
    );
  }

  /// Quick Demo Sign-in as Organization
  Future<bool> demoLoginAsOrg() async {
    return login(
      email: 'admissions@nust.edu.pk',
      password: 'Password123',
    );
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
      final user = await _authService.registerStudent(
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
      final studentProfile = await _authService.getStudentProfile(user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        studentProfile: studentProfile,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
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
      final user = await _authService.registerOrganization(
        orgName: orgName,
        orgType: orgType,
        officialEmail: officialEmail,
        password: password,
        website: website,
        city: city,
        registrationNumber: registrationNumber,
      );
      final orgProfile = await _authService.getOrganizationProfile(user.id);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        currentUser: user,
        organizationProfile: orgProfile,
        errorMessage: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}
