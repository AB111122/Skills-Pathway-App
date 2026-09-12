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
import '../../features/chatbot/presentation/screens/ai_chat_screen.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/home/presentation/screens/main_scaffold_screen.dart';
import '../../features/network/presentation/screens/community_screen.dart';
import '../../features/opportunities/presentation/screens/opportunities_screen.dart';
import '../../features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/student_applications_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/network/presentation/screens/create_post_screen.dart';
import '../../features/network/presentation/screens/post_details_screen.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../models/opportunity_model.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/authentication/domain/auth_state.dart';
import '../../features/university/presentation/university_scaffold.dart';
import '../../features/university/presentation/screens/university_dashboard_screen.dart';
import '../../features/university/presentation/screens/university_opportunities_screen.dart';
import '../../features/university/presentation/screens/create_opportunity_screen.dart';
import '../../features/university/presentation/screens/university_create_post_screen.dart';
import '../../features/university/presentation/screens/university_profile_screen.dart';
import '../../features/university/presentation/screens/university_applications_screen.dart';
import '../../features/university/presentation/screens/university_posts_screen.dart';
import '../../features/university/presentation/screens/edit_university_post_screen.dart';
import 'route_names.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorOppKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellOpportunities',
);
final _shellNavigatorNetKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellNetwork',
);
final _shellNavigatorChatKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellChat',
);
final _shellNavigatorProfKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellProfile',
);

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AuthState>(authControllerProvider, (_, _) {
    refreshNotifier.refresh();
  });
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: refreshNotifier,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    redirect: (_, state) {
      final auth = ref.read(authControllerProvider);
      final path = state.uri.path;
      if (auth.isLoading) return null;

      final authPaths = {
        RouteNames.login,
        RouteNames.roleSelection,
        RouteNames.onboarding,
        RouteNames.registerStudent,
        RouteNames.registerOrganization,
        RouteNames.forgotPassword,
      };

      if (!auth.isAuthenticated) {
        if (path == RouteNames.splash || authPaths.contains(path)) {
          return null;
        }
        return RouteNames.login;
      }

      // Authenticated users
      if (path == RouteNames.splash || authPaths.contains(path)) {
        return auth.isOrganization
            ? RouteNames.universityDashboard
            : RouteNames.home;
      }

      final isUniversityRoute = path.startsWith('/university/');
      final isStudentRoute =
          path == RouteNames.home ||
          path == RouteNames.opportunities ||
          path == RouteNames.network ||
          path == RouteNames.chatbot ||
          path == RouteNames.profile ||
          path == RouteNames.applications;

      if (auth.isOrganization && isStudentRoute) {
        return RouteNames.universityDashboard;
      }
      if (auth.isStudent && isUniversityRoute) {
        return RouteNames.home;
      }
      return null;
    },
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
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/network/create',
        builder: (context, state) => const CreatePostScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/network/post/:id',
        builder: (context, state) =>
            PostDetailsScreen(post: state.extra as PostModel),
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/chatbot/conversation',
        builder: (context, state) =>
            AiChatScreen(starter: state.extra as String?),
      ),

      ShellRoute(
        builder: (context, state, child) => UniversityScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.universityDashboard,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityDashboardScreen(),
          ),
          GoRoute(
            path: RouteNames.universityOpportunities,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityOpportunitiesScreen(),
          ),
          GoRoute(
            path: RouteNames.universityCreateOpportunity,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, state) => CreateOpportunityScreen(
              opportunity: state.extra as OpportunityModel?,
            ),
          ),
          GoRoute(
            path: '/university/opportunities/:id/edit',
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, state) => CreateOpportunityScreen(
              opportunity: state.extra as OpportunityModel?,
            ),
          ),
          GoRoute(
            path: RouteNames.universityCreatePost,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityCreatePostScreen(),
          ),
          GoRoute(
            path: RouteNames.universityPosts,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityPostsScreen(),
          ),
          GoRoute(
            path: '/university/posts/:id/edit',
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, state) =>
                EditUniversityPostScreen(post: state.extra as PostModel),
          ),
          GoRoute(
            path: RouteNames.universityProfile,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityProfileScreen(),
          ),
          GoRoute(
            path: RouteNames.universityApplications,
            redirect: (_, _) => ref.read(authControllerProvider).isOrganization
                ? null
                : RouteNames.home,
            builder: (_, _) => const UniversityApplicationsScreen(),
          ),
        ],
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
                routes: [
                  GoRoute(
                    path: 'applications',
                    builder: (_, _) => const StudentApplicationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
