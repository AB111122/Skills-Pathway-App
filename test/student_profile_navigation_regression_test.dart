import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skills_pathway_app/core/routing/route_names.dart';
import 'package:skills_pathway_app/features/opportunities/presentation/controllers/opportunity_controller.dart';
import 'package:skills_pathway_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/models/opportunity_filter_model.dart';
import 'package:skills_pathway_app/services/opportunity_service.dart';

class _ProfileOpportunityService implements OpportunityService {
  final OpportunityModel opportunity;

  _ProfileOpportunityService(this.opportunity);

  @override
  Future<List<OpportunityModel>> getOpportunities({
    OpportunityFilterModel? filter,
  }) async => [opportunity];

  @override
  Future<OpportunityModel?> getOpportunityById(String id) async =>
      id == opportunity.id ? opportunity : null;

  @override
  Future<bool> toggleSaveOpportunity(String id) async => true;

  @override
  Future<bool> markAsApplied(String id) async => true;

  @override
  Future<bool> toggleDeadlineReminder(String id) async => true;

  @override
  Future<List<OpportunityModel>> getSavedOpportunities() async => [opportunity];

  @override
  Future<List<OpportunityModel>> getAppliedOpportunities() async => [
    opportunity,
  ];
}

void main() {
  testWidgets(
    'student profile displays a published university opportunity from the public provider',
    (tester) async {
      final opportunity = OpportunityModel(
        id: 'profile-ui-opportunity',
        organizationId: 'org_profile_ui',
        organizationName: 'Profile UI University',
        title: 'Profile UI Opportunity',
        type: OpportunityType.internship,
        location: 'Remote',
        deadline: DateTime.now().add(const Duration(days: 30)),
        isVerified: false,
        stipendOrFunding: 'See opportunity details',
        shortDescription: 'Visible to students from the profile.',
        fullDescription: 'Visible to students from the profile.',
        officialUrl: 'https://example.edu/apply',
        requiredSkills: const [],
        eligibleFields: const [],
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            opportunityServiceProvider.overrideWithValue(
              _ProfileOpportunityService(opportunity),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Available Opportunities'), findsOneWidget);
      expect(find.text('Profile UI Opportunity'), findsOneWidget);
      expect(find.text('Profile UI University'), findsOneWidget);
    },
  );

  testWidgets(
    'applications is a profile-shell child and back returns to profile',
    (tester) async {
      final router = GoRouter(
        initialLocation: RouteNames.profile,
        routes: [
          ShellRoute(
            builder: (context, state, child) => child,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (_, _) => const Text('Profile'),
                routes: [
                  GoRoute(
                    path: 'applications',
                    builder: (_, _) => const Text('Applications'),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      router.push(RouteNames.applications);
      await tester.pumpAndSettle();
      expect(find.text('Applications'), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      router.dispose();
    },
  );
}
