import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:exam_prep/app.dart';
import 'package:exam_prep/data/auth_service.dart';

void main() {
  testWidgets('Signed-in user sees the exam prep sections', (WidgetTester tester) async {
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

  testWidgets('Signed-out user sees the login page', (WidgetTester tester) async {
    AuthService.instance = AuthService(MockFirebaseAuth(signedIn: false));

    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ExamCoachApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign In'), findsOneWidget);
  });
}
