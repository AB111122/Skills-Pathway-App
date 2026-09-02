import '../../../models/organization_model.dart';
import '../../../models/student_profile_model.dart';
import '../../../models/user_model.dart';

/// Immutable authentication and user session state.
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserModel? currentUser;
  final StudentProfileModel? studentProfile;
  final OrganizationModel? organizationProfile;
  final String? errorMessage;
  final bool isFirstTime;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.currentUser,
    this.studentProfile,
    this.organizationProfile,
    this.errorMessage,
    this.isFirstTime = true,
  });

  bool get hasRole => currentUser != null;

  bool get isStudent => currentUser?.role == UserRole.student;
  bool get isOrganization => currentUser?.role == UserRole.organization;

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserModel? currentUser,
    StudentProfileModel? studentProfile,
    OrganizationModel? organizationProfile,
    String? errorMessage,
    bool? isFirstTime,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      studentProfile: studentProfile ?? this.studentProfile,
      organizationProfile: organizationProfile ?? this.organizationProfile,
      errorMessage: errorMessage,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  factory AuthState.initial() => const AuthState();
  factory AuthState.loading() => const AuthState(isLoading: true);
}
