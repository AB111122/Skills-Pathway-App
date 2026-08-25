import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/route_names.dart';

class UniversityScaffold extends StatelessWidget {
  final Widget child;
  const UniversityScaffold({super.key, required this.child});
  int _index(String location) => location.startsWith(RouteNames.universityOpportunities) ? 1 : location.startsWith(RouteNames.universityPosts) ? 2 : location.startsWith(RouteNames.universityProfile) ? 3 : 0;
  @override Widget build(BuildContext context) { final index = _index(GoRouterState.of(context).uri.path); return Scaffold(body: child, bottomNavigationBar: NavigationBar(selectedIndex: index, onDestinationSelected: (value) => context.go([RouteNames.universityDashboard, RouteNames.universityOpportunities, RouteNames.universityPosts, RouteNames.universityProfile][value]), destinations: const [NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'), NavigationDestination(icon: Icon(Icons.work_outline), label: 'Opportunities'), NavigationDestination(icon: Icon(Icons.campaign_outlined), label: 'Posts'), NavigationDestination(icon: Icon(Icons.business_outlined), label: 'Profile')])); }
}
