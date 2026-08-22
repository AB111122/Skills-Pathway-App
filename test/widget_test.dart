import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/core/constants/app_strings.dart';
import 'package:skills_pathway_app/main.dart';

void main() {
  testWidgets('SkillsPathwayApp loads splash screen and transitions to onboarding',
      (WidgetTester tester) async {
    // Build our app with ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: SkillsPathwayApp(),
      ),
    );

    // Initial frame renders splash screen elements
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Advance time past the splash timer (2.4s)
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    // Verify transition to Onboarding
    expect(find.text('Verified Scholarships & Internships'), findsOneWidget);
  });
}
