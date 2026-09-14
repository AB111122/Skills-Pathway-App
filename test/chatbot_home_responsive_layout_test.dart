import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/features/authentication/domain/auth_state.dart';
import 'package:skills_pathway_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:skills_pathway_app/features/chatbot/presentation/screens/chatbot_home_screen.dart';
import 'package:skills_pathway_app/features/university/presentation/screens/university_dashboard_screen.dart';
import 'package:skills_pathway_app/features/university/presentation/screens/university_profile_screen.dart';
import 'package:skills_pathway_app/models/organization_model.dart';
import 'package:skills_pathway_app/models/user_model.dart';

void main() {
  group('AI Guide & Grid Screens Responsive Layout Tests', () {
    final screenSizes = [
      {
        'name': 'Small Compact Phone (e.g. Pixel 4a / iPhone SE)',
        'size': const Size(360, 640),
        'pixelRatio': 2.75,
      },
      {
        'name': 'Ultra-compact Narrow Phone (320px width)',
        'size': const Size(320, 568),
        'pixelRatio': 2.0,
      },
      {
        'name': 'Large Phone (e.g. Pixel 7 Pro / iPhone 15 Pro Max)',
        'size': const Size(412, 892),
        'pixelRatio': 3.5,
      },
      {
        'name': 'Tablet Screen (800px width)',
        'size': const Size(800, 1280),
        'pixelRatio': 2.0,
      },
    ];

    final mockOrgUser = UserModel(
      id: 'org-test-1',
      name: 'NUST University',
      email: 'admissions@nust.edu.pk',
      role: UserRole.organization,
      createdAt: DateTime.utc(2026, 1, 1),
    );

    final mockOrgProfile = OrganizationModel(
      id: 'org-test-1',
      userId: 'org-test-1',
      orgName: 'National University of Sciences & Technology',
      orgType: 'University',
      city: 'Islamabad',
      isVerified: true,
      website: 'https://nust.edu.pk',
      officialEmail: 'admissions@nust.edu.pk',
      registrationNumber: 'HEC-2026-NUST',
    );

    for (final config in screenSizes) {
      final name = config['name'] as String;
      final size = config['size'] as Size;
      final pixelRatio = config['pixelRatio'] as double;

      testWidgets('ChatbotHomeScreen renders without overflow on $name', (
        tester,
      ) async {
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
              home: ChatbotHomeScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all 6 AI prompt option cards are present and discoverable
        final titles = [
          'Career Guidance',
          'Find Internships',
          'Resume Help',
          'Scholarships',
          'Market Insights',
          'Ask Me Anything',
        ];

        for (final title in titles) {
          final itemFinder = find.text(title);
          await tester.scrollUntilVisible(
            itemFinder,
            50.0,
            scrollable: find.byType(Scrollable).first,
          );
          expect(itemFinder, findsOneWidget);
        }

        // Verify no overflow exception was thrown
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'UniversityDashboardScreen grids render without overflow on $name',
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
            ProviderScope(
              overrides: [
                authControllerProvider.overrideWith(
                  (ref) => FakeAuthController(
                    AuthState(
                      isAuthenticated: true,
                      currentUser: mockOrgUser,
                      organizationProfile: mockOrgProfile,
                    ),
                  ),
                ),
              ],
              child: const MaterialApp(
                home: UniversityDashboardScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final scrollableFinder = find.byType(Scrollable).first;

          final elements = [
            find.text('Overview & Metrics'),
            find.text('Active Opportunities'),
            find.text('Quick Actions'),
            find.text('Create Opportunity'),
          ];

          for (final finder in elements) {
            await tester.scrollUntilVisible(
              finder,
              50.0,
              scrollable: scrollableFinder,
            );
            expect(finder, findsOneWidget);
          }

          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'UniversityProfileScreen stats grid renders without overflow on $name',
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
            ProviderScope(
              overrides: [
                authControllerProvider.overrideWith(
                  (ref) => FakeAuthController(
                    AuthState(
                      isAuthenticated: true,
                      currentUser: mockOrgUser,
                      organizationProfile: mockOrgProfile,
                    ),
                  ),
                ),
              ],
              child: const MaterialApp(
                home: UniversityProfileScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final scrollableFinder = find.byType(Scrollable).first;

          final elements = [
            find.text('Activity & Statistics'),
            find.text('Opportunities'),
            find.text('Applications'),
            find.text('Posts'),
          ];

          for (final finder in elements) {
            await tester.scrollUntilVisible(
              finder,
              50.0,
              scrollable: scrollableFinder,
            );
            expect(finder, findsOneWidget);
          }

          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}

class FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  FakeAuthController(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
