/// Named route paths for GoRouter navigation.
class RouteNames {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String registerStudent = '/register-student';
  static const String registerOrganization = '/register-organization';
  static const String forgotPassword = '/forgot-password';

  // Shell Tabs
  static const String home = '/home';
  static const String opportunities = '/opportunities';
  static const String network = '/network';
  static const String chatbot = '/chatbot';
  static const String profile = '/profile';
  static const String applications = '/profile/applications';

  // University Portal
  static const String universityDashboard = '/university/dashboard';
  static const String universityOpportunities = '/university/opportunities';
  static const String universityCreateOpportunity =
      '/university/opportunities/create';
  static const String universityApplications = '/university/applications';
  static const String universityCreatePost = '/university/posts/create';
  static const String universityPosts = '/university/posts';
  static const String universityProfile = '/university/profile';

  // Detail Sub-routes
  static const String opportunityDetail = '/opportunities/:id';
  static const String roadmap = '/roadmap';
  static const String marketInsights = '/market-insights';
  static const String createPost = '/network/create';
  static const String submitListing = '/listings/submit';
  static const String notifications = '/notifications';
}
