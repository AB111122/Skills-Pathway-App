import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skills_pathway_app/features/home/presentation/screens/main_scaffold_screen.dart';

void main() {
  group('MainScaffoldScreen Bottom Navigation Bar Responsive Tests', () {
    final testViewports = [
      {
        'name': 'Ultra-compact narrow device (320px)',
        'size': const Size(320, 568),
      },
      {
        'name': 'Realme C25s / Compact phone (360px)',
        'size': const Size(360, 800),
      },
      {
        'name': 'Mid-size standard phone (390px)',
        'size': const Size(390, 844),
      },
      {
        'name': 'Redmi Note 13 Pro / Large phone (412px)',
        'size': const Size(412, 915),
      },
      {
        'name': 'Pro Max / Extra-wide phone (430px)',
        'size': const Size(430, 932),
      },
      {
        'name': 'Tablet device (800px)',
        'size': const Size(800, 1280),
      },
    ];

    GoRouter createTestRouter() {
      return GoRouter(
        initialLocation: '/home',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainScaffoldScreen(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) =>
                      const Center(child: Text('Home Screen')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/opps',
                  builder: (context, state) =>
                      const Center(child: Text('Opportunities Screen')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/community',
                  builder: (context, state) =>
                      const Center(child: Text('Community Screen')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/ai-guide',
                  builder: (context, state) =>
                      const Center(child: Text('AI Guide Screen')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) =>
                      const Center(child: Text('Profile Screen')),
                ),
              ]),
            ],
          ),
        ],
      );
    }

    for (final viewport in testViewports) {
      final name = viewport['name'] as String;
      final size = viewport['size'] as Size;

      testWidgets('renders all 5 tabs without overflow on $name (${size.width}w)',
          (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final router = createTestRouter();

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Check all 5 labels are present in the widget tree
        final homeFinder = find.text('Home');
        final oppsFinder = find.text('Opportunities');
        final commFinder = find.text('Community');
        final aiFinder = find.text('AI Guide');
        final profileFinder = find.text('Profile');

        expect(homeFinder, findsOneWidget);
        expect(oppsFinder, findsOneWidget);
        expect(commFinder, findsOneWidget);
        expect(aiFinder, findsOneWidget);
        expect(profileFinder, findsOneWidget);

        // 2. Verify all tabs are strictly within the horizontal screen width
        final profileRect = tester.getRect(profileFinder);
        expect(
          profileRect.right,
          lessThanOrEqualTo(size.width),
          reason: 'Profile tab text right edge (${profileRect.right}) exceeded screen width (${size.width})',
        );
        expect(
          profileRect.left,
          greaterThanOrEqualTo(0.0),
          reason: 'Profile tab left edge (${profileRect.left}) is out of bounds',
        );

        final homeRect = tester.getRect(homeFinder);
        expect(homeRect.left, greaterThanOrEqualTo(0.0));
        expect(homeRect.right, lessThanOrEqualTo(size.width));

        // 3. Verify no exceptions (e.g. RenderFlex overflow)
        expect(tester.takeException(), isNull);

        // 4. Verify tapping the last tab ("Profile") functions properly
        await tester.tap(profileFinder);
        await tester.pumpAndSettle();
        expect(find.text('Profile Screen'), findsOneWidget);

        // 5. Verify tapping "Opportunities" functions properly
        await tester.tap(oppsFinder);
        await tester.pumpAndSettle();
        expect(find.text('Opportunities Screen'), findsOneWidget);
      });
    }
  });
}
