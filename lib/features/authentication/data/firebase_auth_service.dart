import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../models/organization_model.dart';
import '../../../models/student_profile_model.dart';
import '../../../models/user_model.dart';
import 'mock_auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Stream<UserModel?> get authStateChanges async* {
    await for (final firebaseUser in _auth.authStateChanges()) {
      if (firebaseUser == null) {
        yield null;
        continue;
      }
      try {
        yield await _loadUser(firebaseUser);
      } catch (error, stackTrace) {
        debugPrint(
          '[FirebaseAuthService] profile restore failed code=${error is FirebaseException ? error.code : 'unknown'} message=$error',
        );
        debugPrintStack(stackTrace: stackTrace);
        yield null;
      }
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Unable to sign in.');
      return await _loadUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw Exception(_friendlyAuthMessage(error.code));
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Unable to create account.');
      final now = FieldValue.serverTimestamp();
      await _users.doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'id': firebaseUser.uid,
        'email': email.trim(),
        'name': fullName.trim(),
        'role': UserRole.student.name,
        'createdAt': now,
        'updatedAt': now,
        'studentProfile': {
          'id': firebaseUser.uid,
          'userId': firebaseUser.uid,
          'fullName': fullName.trim(),
          'educationLevel': educationLevel,
          'degree': degree,
          'fieldOfStudy': fieldOfStudy,
          'universityOrCollege': university,
          'city': city,
          'skills': skills,
          'careerInterests': careerInterests,
          'completionPercentage': 0.75,
        },
      });
      return await _loadUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw Exception(_friendlyAuthMessage(error.code));
    }
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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: officialEmail.trim(),
        password: password,
      );
      final firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('Unable to create account.');
      final now = FieldValue.serverTimestamp();
      await _users.doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'id': firebaseUser.uid,
        'email': officialEmail.trim(),
        'name': orgName.trim(),
        'role': UserRole.organization.name,
        'createdAt': now,
        'updatedAt': now,
        'organizationProfile': {
          'id': firebaseUser.uid,
          'userId': firebaseUser.uid,
          'orgName': orgName.trim(),
          'orgType': orgType,
          'website': website.trim(),
          'officialEmail': officialEmail.trim(),
          'city': city.trim(),
          'registrationNumber': registrationNumber.trim(),
          'isVerified': false,
        },
      });
      return await _loadUser(firebaseUser);
    } on FirebaseAuthException catch (error) {
      throw Exception(_friendlyAuthMessage(error.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw Exception(_friendlyAuthMessage(error.code));
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<StudentProfileModel?> getStudentProfile(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    final profile = data?['studentProfile'];
    if (profile is! Map) return null;
    return _studentProfileFromMap(Map<String, dynamic>.from(profile));
  }

  @override
  Future<OrganizationModel?> getOrganizationProfile(String userId) async {
    final snapshot = await _users.doc(userId).get();
    final data = snapshot.data();
    final profile = data?['organizationProfile'];
    if (profile is! Map) return null;
    return _organizationProfileFromMap(Map<String, dynamic>.from(profile));
  }

  Future<UserModel> _loadUser(User firebaseUser) async {
    final snapshot = await _users.doc(firebaseUser.uid).get();
    final data = snapshot.data() ?? <String, dynamic>{};
    return UserModel(
      id: firebaseUser.uid,
      name: data['name'] as String? ?? firebaseUser.displayName ?? '',
      email: firebaseUser.email ?? data['email'] as String? ?? '',
      role: _roleFromValue(data['role']),
      avatarUrl: data['avatarUrl'] as String?,
      createdAt: _dateFromValue(data['createdAt']) ?? DateTime.now(),
    );
  }

  UserRole _roleFromValue(Object? value) => UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => throw StateError('User profile has no valid role.'),
  );

  DateTime? _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  StudentProfileModel _studentProfileFromMap(Map<String, dynamic> data) {
    return StudentProfileModel(
      id: data['id'] as String? ?? data['userId'] as String,
      userId: data['userId'] as String,
      fullName: data['fullName'] as String? ?? '',
      educationLevel: data['educationLevel'] as String? ?? '',
      degree: data['degree'] as String? ?? '',
      fieldOfStudy: data['fieldOfStudy'] as String? ?? '',
      universityOrCollege: data['universityOrCollege'] as String? ?? '',
      gpa: (data['gpa'] as num?)?.toDouble(),
      graduationYear: data['graduationYear'] as int?,
      skills: List<String>.from(data['skills'] ?? const []),
      careerInterests: List<String>.from(data['careerInterests'] ?? const []),
      city: data['city'] as String? ?? '',
      resumeUrl: data['resumeUrl'] as String?,
      completionPercentage:
          (data['completionPercentage'] as num?)?.toDouble() ?? 0.7,
    );
  }

  OrganizationModel _organizationProfileFromMap(Map<String, dynamic> data) {
    return OrganizationModel(
      id: data['id'] as String? ?? data['userId'] as String,
      userId: data['userId'] as String,
      orgName: data['orgName'] as String? ?? '',
      orgType: data['orgType'] as String? ?? '',
      website: data['website'] as String? ?? '',
      officialEmail: data['officialEmail'] as String? ?? '',
      contactPerson: data['contactPerson'] as String?,
      phone: data['phone'] as String?,
      address: data['address'] as String?,
      city: data['city'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
      registrationNumber: data['registrationNumber'] as String?,
    );
  }

  String _friendlyAuthMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'The email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
