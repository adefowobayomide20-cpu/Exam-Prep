import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:exam_prep/app.dart';
import 'package:exam_prep/data/auth_service.dart';

void main() {
  testWidgets('Signed-in user who has completed onboarding sees the exam prep sections',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    AuthService.instance = AuthService(MockFirebaseAuth(signedIn: true));

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ExamCoachApp());
    await tester.pumpAndSettle();

    expect(find.text('Exam Coach'), findsOneWidget);
    expect(find.text('Continue where you left off'), findsOneWidget);
    expect(find.text('Performance Track Record'), findsOneWidget);
    expect(find.text('Invite a friend to a Duel Quiz'), findsOneWidget);
    expect(find.text('Exam Type'), findsOneWidget);
    expect(find.text('Latest News Update'), findsOneWidget);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Exam'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('New install with no signed-in user is signed in anonymously and sees home',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    AuthService.instance = AuthService(MockFirebaseAuth(signedIn: false));

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ExamCoachApp());
    await tester.pumpAndSettle();

    expect(find.text('Exam Coach'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('First-ever launch shows onboarding, then home after Get started',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    AuthService.instance = AuthService(MockFirebaseAuth(signedIn: true));

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ExamCoachApp());
    await tester.pumpAndSettle();

    expect(find.text('Practice smarter'), findsOneWidget);
    expect(find.text('Home'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Know your weak spots'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Duel a friend'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Continue where you left off'), findsOneWidget);
  });
}
