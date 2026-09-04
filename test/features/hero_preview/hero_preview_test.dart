import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:self_improvement_app/features/hero_preview/hero_preview_view.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_1.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_2.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_3.dart';
import 'package:self_improvement_app/features/hero_preview/widgets/login_form_widget.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

void main() {
  final tokens = StyleTokens(
    profile: AppProfile.profileA,
    brightness: Brightness.light,
  );

  group('Hero Preview Feature Tests', () {
    testWidgets('HeroVariant1 renders telemetry and command login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroVariant1(tokens: tokens),
          ),
        ),
      );

      expect(find.text('ERP SYSTEM // STORE #1 ONLINE'), findsOneWidget);
      expect(find.text('Mission-Critical Operations for Highway Travel Plazas'), findsOneWidget);
      expect(find.text('Fleet Command Login'), findsOneWidget);
      expect(find.text('Automatic Tank Gauging'), findsOneWidget);
    });

    testWidgets('HeroVariant2 renders Route 66 heritage and stationmaster portal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroVariant2(tokens: tokens),
          ),
        ),
      );

      expect(find.text('INTERSTATE ROUTE 66 • STORE 1'), findsOneWidget);
      expect(find.text('The All-American Travel Plaza System'), findsOneWidget);
      expect(find.text('Stationmaster Portal'), findsOneWidget);
      expect(find.text('High-Flow Diesel Island'), findsOneWidget);
    });

    testWidgets('HeroVariant3 renders modern SaaS headline and interactive tour', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroVariant3(tokens: tokens),
          ),
        ),
      );

      expect(find.text('ERP 2.0 Cloud Architecture • Live & Synchronized'), findsOneWidget);
      expect(find.text('The Modern Operating System for Independent Truck Stops'), findsOneWidget);
      expect(find.text('Enterprise Operator Portal'), findsOneWidget);
      expect(find.text('Explore ERP Subsystems'), findsOneWidget);
    });

    testWidgets('HeroPreviewView switcher functions properly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeroPreviewView(tokens: tokens),
          ),
        ),
      );

      // Verify header lab badge exists
      expect(find.text('HERO LAB (Credentials: Admin / Admin)'), findsOneWidget);

      // Default is Variant 1
      expect(find.text('Fleet Command Login'), findsOneWidget);

      // Tap Variant 2 tab
      await tester.ensureVisible(find.text('Variant 2: Route 66 Americana'));
      await tester.tap(find.text('Variant 2: Route 66 Americana'));
      await tester.pumpAndSettle();
      expect(find.text('Stationmaster Portal'), findsOneWidget);

      // Tap Variant 3 tab
      await tester.ensureVisible(find.text('Variant 3: Modern Enterprise SaaS'));
      await tester.tap(find.text('Variant 3: Modern Enterprise SaaS'));
      await tester.pumpAndSettle();
      expect(find.text('Enterprise Operator Portal'), findsOneWidget);
    });

    testWidgets('LoginFormWidget validates Admin / Admin and Quick Fill', (WidgetTester tester) async {
      bool loginSuccessCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LoginFormWidget(
                tokens: tokens,
                onLoginSuccess: () => loginSuccessCalled = true,
              ),
            ),
          ),
        ),
      );

      // 1. Try wrong credentials
      await tester.enterText(find.byType(TextField).first, 'WrongUser');
      await tester.enterText(find.byType(TextField).last, 'WrongPass');
      await tester.tap(find.text('Sign In to ERP Portal'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials. Use username "Admin" and password "Admin".'), findsOneWidget);
      expect(loginSuccessCalled, isFalse);

      // 2. Test Quick Fill button
      await tester.tap(find.text('Quick Fill Demo (Admin / Admin)'));
      await tester.pumpAndSettle();

      // Submit valid credentials
      await tester.tap(find.text('Sign In to ERP Portal'));
      await tester.pumpAndSettle();

      expect(find.text('Authentication Verified'), findsOneWidget);
      expect(loginSuccessCalled, isTrue);
    });
  });
}
