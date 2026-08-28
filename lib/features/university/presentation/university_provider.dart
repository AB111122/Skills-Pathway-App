import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../services/firebase_university_portal_repository.dart';
import '../../../services/university_portal_repository.dart';

final universityRepositoryProvider = Provider<UniversityPortalRepository>(
  (ref) => Firebase.apps.isEmpty
      ? MockUniversityPortalRepository()
      : FirebaseUniversityPortalRepository(),
);
