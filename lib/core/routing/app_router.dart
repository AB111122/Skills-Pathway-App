import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/register_organization_screen.dart';
import '../../features/authentication/presentation/screens/register_student_screen.dart';
import '../../features/authentication/presentation/screens/role_selection_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/chatbot/presentation/screens/chatbot_home_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/home/presentation/screens/main_scaffold_screen.dart';
import '../../features/network/presentation/screens/community_screen.dart';
import '../../features/opportunities/presentation/screens/opportunities_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../models/user_model.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final _shellNavigatorOppKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellOpportunities');
final _shellNavigatorNetKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellNetwork');
final _shellNavigatorChatKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellChat');
final _shellNavigatorProfKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding Screen
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Role Selection
      GoRoute(
        path: RouteNames.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // Login
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) {
          final roleParam = state.uri.queryParameters['role'];
          final initialRole = roleParam == 'organization'
              ? UserRole.organization
              : UserRole.student;
          return LoginScreen(initialRole: initialRole);
        },
      ),

      // Student Registration
      GoRoute(
        path: RouteNames.registerStudent,
        builder: (context, state) => const RegisterStudentScreen(),
      ),

      // Organization Registration
      GoRoute(
        path: RouteNames.registerOrganization,
        builder: (context, state) => const RegisterOrganizationScreen(),
      ),

      // Forgot Password
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Opportunity Detail (Full screen overlay with parentNavigatorKey)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/opportunities/:id',
        builder: (context, state) {
          final oppId = state.pathParameters['id'] ?? '';
          return OpportunityDetailScreen(opportunityId: oppId);
        },
      ),

      // Shell Route for persistent Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home Dashboard
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Opportunities Discovery
          StatefulShellBranch(
            navigatorKey: _shellNavigatorOppKey,
            routes: [
              GoRoute(
                path: RouteNames.opportunities,
                builder: (context, state) => const OpportunitiesScreen(),
              ),
            ],
          ),

          // Branch 2: Community Network
          StatefulShellBranch(
            navigatorKey: _shellNavigatorNetKey,
            routes: [
              GoRoute(
                path: RouteNames.network,
                builder: (context, state) => const CommunityScreen(),
              ),
            ],
          ),

          // Branch 3: AI Chatbot Assistant
          StatefulShellBranch(
            navigatorKey: _shellNavigatorChatKey,
            routes: [
              GoRoute(
                path: RouteNames.chatbot,
                builder: (context, state) => const ChatbotHomeScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfKey,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
