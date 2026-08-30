import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/core/widgets/verified_badge.dart';
import 'package:skills_pathway_app/features/opportunities/presentation/screens/opportunities_screen.dart';
import 'package:skills_pathway_app/features/opportunities/presentation/screens/opportunity_detail_screen.dart';
import 'package:skills_pathway_app/models/opportunity_filter_model.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';

void main() {
  group('MockOpportunityService Tests', () {
    late MockOpportunityService service;

    setUp(() {
      service = MockOpportunityService();
    });

    test('Loads all opportunities without filters', () async {
      final items = await service.getOpportunities();
      expect(items.isNotEmpty, true);
      expect(items.length, greaterThanOrEqualTo(10));
    });

    test('Filters strictly by search query', () async {
      final items = await service.getOpportunities(
        filter: const OpportunityFilterModel(searchQuery: 'Jazz'),
      );
      expect(items.length, 1);
      expect(items.first.title.contains('Jazz'), true);
    });

    test('Strict verified filter only returns verified listings', () async {
      final items = await service.getOpportunities(
        filter: const OpportunityFilterModel(isVerifiedOnly: true),
      );
      for (final opp in items) {
        expect(opp.isVerified, true);
      }
    });

    test('Filters paid internships only', () async {
      final items = await service.getOpportunities(
        filter: const OpportunityFilterModel(isPaidOnly: true),
      );
      for (final opp in items) {
        expect(opp.isInternship, true);
        expect(opp.isPaid, true);
      }
    });

    test('Toggles save/bookmark state properly', () async {
      final opps = await service.getOpportunities();
      final targetId = opps.first.id;
      final initialSaved = opps.first.isSaved;

      final updatedStatus = await service.toggleSaveOpportunity(targetId);
      expect(updatedStatus, !initialSaved);
    });

    test('Marks opportunity as applied with timestamp', () async {
      final opps = await service.getOpportunities();
      final targetId = opps.first.id;

      final success = await service.markAsApplied(targetId);
      expect(success, true);

      final updatedOpp = await service.getOpportunityById(targetId);
      expect(updatedOpp?.isApplied, true);
      expect(updatedOpp?.appliedAt, isNotNull);
    });
  });

  group('Strict VerifiedBadge Widget Tests', () {
    testWidgets('VerifiedBadge renders when isVerified is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(isVerified: true),
          ),
        ),
      );

      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('VerifiedBadge NEVER renders when isVerified is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedBadge(isVerified: false),
          ),
        ),
      );

      expect(find.text('Verified'), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
    });
  });

  group('Opportunities Screen Widget Tests', () {
    testWidgets('OpportunitiesScreen renders tabs and search input',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OpportunitiesScreen(),
          ),
        ),
      );

      // Initial frame
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Verified Opportunities'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Scholarships'), findsOneWidget);
      expect(find.text('Internships'), findsOneWidget);
    });

    testWidgets('OpportunityDetailScreen renders comprehensive criteria',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OpportunityDetailScreen(opportunityId: 'opp_jazz_02'),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Internship Details'), findsOneWidget);
      expect(find.text('Program Overview'), findsOneWidget);
      expect(find.text('Funding & Benefits'), findsOneWidget);
      expect(find.text('Eligibility Requirements'), findsOneWidget);
      expect(find.text('One-Tap Apply'), findsOneWidget);
    });
  });
}
