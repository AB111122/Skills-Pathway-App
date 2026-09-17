import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/core/constants/app_strings.dart';
import 'package:skills_pathway_app/features/home/presentation/screens/home_dashboard_screen.dart';

void main() {
  group('HomeDashboardScreen Responsive & Header Overflow Tests', () {
    final screenSizes = [
      {
        'name': 'Ultra-compact narrow device (320px)',
        'size': const Size(320, 568),
        'pixelRatio': 2.0,
      },
      {
        'name': 'Realme C25S / Compact phone (360px)',
        'size': const Size(360, 800),
        'pixelRatio': 2.0,
      },
      {
        'name': 'Mid-size standard phone (390px)',
        'size': const Size(390, 844),
        'pixelRatio': 3.0,
      },
      {
        'name': 'Redmi Note 13 Pro / Large phone (412px)',
        'size': const Size(412, 915),
        'pixelRatio': 2.75,
      },
    ];

    for (final config in screenSizes) {
      final name = config['name'] as String;
      final size = config['size'] as Size;
      final pixelRatio = config['pixelRatio'] as double;

      testWidgets('renders Market Pulse header and cards without overflow on $name',
          (tester) async {
        tester.view.physicalSize = Size(
          size.width * pixelRatio,
          size.height * pixelRatio,
        );
        tester.view.devicePixelRatio = pixelRatio;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: HomeDashboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Scroll to Market Pulse card
        final marketPulseTitle = find.text(AppStrings.marketPulse);
        await tester.scrollUntilVisible(
          marketPulseTitle,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        expect(marketPulseTitle, findsOneWidget);

        // 2. Verify 'Live Demand' badge is visible alongside the title
        final liveDemandBadge = find.text('Live Demand');
        expect(liveDemandBadge, findsOneWidget);

        // 3. Verify positions of title and badge are within screen bounds
        final titleRect = tester.getRect(marketPulseTitle);
        final badgeRect = tester.getRect(liveDemandBadge);

        expect(
          titleRect.left,
          greaterThanOrEqualTo(0.0),
          reason: 'Title left edge was out of bounds',
        );
        expect(
          badgeRect.right,
          lessThanOrEqualTo(size.width),
          reason: 'Live Demand badge right edge (${badgeRect.right}) exceeded screen width (${size.width})',
        );

        // 4. Scroll through remaining sections on the dashboard
        final scholarshipHeader = find.text(AppStrings.recommendedScholarships);
        await tester.scrollUntilVisible(
          scholarshipHeader,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        expect(scholarshipHeader, findsOneWidget);

        final internshipHeader = find.text(AppStrings.recommendedInternships);
        await tester.scrollUntilVisible(
          internshipHeader,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        expect(internshipHeader, findsOneWidget);

        final communityBuzz = find.text('Student Community Buzz');
        await tester.scrollUntilVisible(
          communityBuzz,
          100.0,
          scrollable: find.byType(Scrollable).first,
        );
        expect(communityBuzz, findsOneWidget);

        // 5. Verify no RenderFlex or layout exceptions occurred
        expect(tester.takeException(), isNull);
      });
    }
  });
}
