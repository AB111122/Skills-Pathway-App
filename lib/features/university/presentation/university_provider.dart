import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/university_portal_repository.dart';

final universityRepositoryProvider = Provider<UniversityPortalRepository>((ref) => MockUniversityPortalRepository());
