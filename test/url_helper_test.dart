import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/core/utils/url_helper.dart';
import 'package:skills_pathway_app/features/opportunities/presentation/widgets/apply_confirmation_dialog.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';

void main() {
  group('UrlHelper.normalizeUrl Tests', () {
    test('prepends https:// to schemeless domain (Bahria University Bukc.edu.pk)', () {
      final normalized = UrlHelper.normalizeUrl('Bukc.edu.pk');
      expect(normalized, 'https://Bukc.edu.pk');
    });

    test('trims whitespace and prepends https:// to schemeless URL', () {
      final normalized = UrlHelper.normalizeUrl('   Bukc.edu.pk/admissions  ');
      expect(normalized, 'https://Bukc.edu.pk/admissions');
    });

    test('preserves existing https:// URL untouched', () {
      const fullUrl = 'https://hec.gov.pk/english/scholarships/indigenous';
      final normalized = UrlHelper.normalizeUrl(fullUrl);
      expect(normalized, fullUrl);
    });

    test('preserves existing http:// URL untouched', () {
      const httpUrl = 'http://nust.edu.pk/admissions';
      final normalized = UrlHelper.normalizeUrl(httpUrl);
      expect(normalized, httpUrl);
    });

    test('handles case-insensitive scheme prefixes', () {
      const upperUrl = 'HTTPS://BAHRIA.EDU.PK';
      final normalized = UrlHelper.normalizeUrl(upperUrl);
      expect(normalized, upperUrl);
    });

    test('returns empty string for empty or whitespace-only input', () {
      expect(UrlHelper.normalizeUrl(''), '');
      expect(UrlHelper.normalizeUrl('   '), '');
    });
  });

  group('ApplyConfirmationDialog Widget & URL Launch Tests', () {
    final bahriaOpp = OpportunityModel(
      id: 'opp_bahria_01',
      title: 'Bahria University Merit Scholarship',
      organizationName: 'Bahria University',
      type: OpportunityType.scholarship,
      location: 'Karachi, PK',
      deadline: DateTime.now().add(const Duration(days: 30)),
      isVerified: false,
      stipendOrFunding: '50% Tuition Fee Waiver',
      shortDescription: 'Merit scholarship for undergraduate students.',
      fullDescription: 'Bahria University offers merit scholarship for outstanding students.',
      officialUrl: 'Bukc.edu.pk',
      requiredSkills: const ['Academic Excellence'],
      eligibleFields: const ['Computer Science'],
      createdAt: DateTime.now(),
      status: OpportunityStatus.published,
    );

    final jazzOpp = OpportunityModel(
      id: 'opp_jazz_02',
      title: 'Jazz Summer Xplore Internship Program 2026',
      organizationName: 'Jazz',
      type: OpportunityType.internship,
      location: 'Islamabad, PK',
      deadline: DateTime.now().add(const Duration(days: 14)),
      isVerified: true,
      isPaid: true,
      stipendOrFunding: 'PKR 45,000 / month',
      shortDescription: 'Corporate internship program.',
      fullDescription: '8-week hands-on tech and product immersion.',
      officialUrl: 'https://jazz.com.pk/careers/summer-xplore',
      requiredSkills: const ['Flutter', 'Python'],
      eligibleFields: const ['Software Engineering'],
      createdAt: DateTime.now(),
      status: OpportunityStatus.published,
    );

    testWidgets('renders ApplyConfirmationDialog with schemeless Bahria University URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplyConfirmationDialog(
              opportunity: bahriaOpp,
              onApplied: () {},
            ),
          ),
        ),
      );

      expect(find.text('One-Tap Official Apply'), findsOneWidget);
      expect(find.text('Bahria University Merit Scholarship'), findsOneWidget);
      expect(find.text('Bukc.edu.pk'), findsOneWidget);
      expect(find.text('Proceed to Official Site'), findsOneWidget);

      // Tap Proceed - verify no crash occurs on schemeless URL
      await tester.tap(find.text('Proceed to Official Site'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('renders ApplyConfirmationDialog with full https:// URL', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ApplyConfirmationDialog(
              opportunity: jazzOpp,
              onApplied: () {},
            ),
          ),
        ),
      );

      expect(find.text('One-Tap Official Apply'), findsOneWidget);
      expect(find.text('Jazz Summer Xplore Internship Program 2026'), findsOneWidget);
      expect(find.text('https://jazz.com.pk/careers/summer-xplore'), findsOneWidget);
      expect(find.text('Proceed to Official Site'), findsOneWidget);

      // Tap Proceed
      await tester.tap(find.text('Proceed to Official Site'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
