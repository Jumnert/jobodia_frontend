import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/main.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(Get.reset);

  testWidgets('shows login screen', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    expect(find.text('Jobodia'), findsOneWidget);
    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Or Log in with'), findsOneWidget);
  });

  testWidgets('login validates empty email', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Email is required.'), findsOneWidget);
  });

  testWidgets('login validates Gmail format', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@yahoo.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Please enter a valid Gmail address'), findsOneWidget);
  });

  testWidgets('switches to sign-up form', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('or Sign up with'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsNothing);
  });

  testWidgets('reset password mismatch stays on reset screen', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'password');
    await tester.enterText(fields.at(1), 'different');
    await tester.tap(find.widgetWithText(FilledButton, 'Reset Password'));
    await tester.pump();

    expect(find.text('Reset Your Password'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsOneWidget);

    Get.back<void>();
    await tester.pumpAndSettle();

    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.text('Passwords do not match.'), findsNothing);
  });

  testWidgets('matching reset passwords return to login', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'new-password');
    await tester.enterText(fields.at(1), 'new-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Reset Password'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });

  test('AuthController validates username and Gmail values', () {
    final controller = AuthController(const AuthRepository());

    expect(controller.isValidGmail('test@gmail.com'), isTrue);
    expect(controller.isValidGmail('muharen123@gmail.com'), isTrue);
    expect(controller.isValidGmail('test@yahoo.com'), isFalse);
    expect(controller.isValidGmail('test@gmail'), isFalse);
    expect(controller.isValidUsername('Muharen'), isTrue);
    expect(controller.isValidUsername('SOKHA'), isTrue);
    expect(controller.isValidUsername('Muharen123'), isFalse);
    expect(controller.isValidUsername('Muharen Dev'), isFalse);

    controller.onClose();
  });

  testWidgets('sign-up username field allows letters only', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Muharen123_ Dev');
    await tester.pump();

    final usernameField = tester.widget<EditableText>(
      find.byType(EditableText).at(0),
    );
    expect(usernameField.controller.text, 'MuharenDev');
  });

  testWidgets('sign-up validates Gmail format', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Muharen');
    await tester.enterText(fields.at(1), 'test@hotmail.com');
    await tester.enterText(fields.at(2), 'password');
    await tester.enterText(fields.at(3), 'password');
    final signUpButton = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.text('Please enter a valid Gmail address'), findsOneWidget);
  });

  testWidgets('sign-up validates matching passwords', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New User');
    await tester.enterText(fields.at(1), 'new@gmail.com');
    await tester.enterText(fields.at(2), 'password');
    await tester.enterText(fields.at(3), 'different');
    final signUpButton = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.text('Passwords do not match.'), findsOneWidget);
  });

  Future<void> signUpAndOpenOtp(WidgetTester tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New User');
    await tester.enterText(fields.at(1), 'new@gmail.com');
    await tester.enterText(fields.at(2), 'password');
    await tester.enterText(fields.at(3), 'password');
    final signUpButton = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUpButton);
    await tester.tap(signUpButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  Future<void> fillOtp(WidgetTester tester, String otp) async {
    final otpFields = find.byType(TextField);
    for (var index = 0; index < otp.length; index++) {
      await tester.enterText(otpFields.at(index), otp[index]);
    }
    await tester.pump();
  }

  testWidgets('sign-up opens OTP screen', (tester) async {
    await signUpAndOpenOtp(tester);

    expect(find.text('Verify Gmail'), findsOneWidget);
    expect(find.text('new@gmail.com'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('OTP boxes combine digits into controller text', (tester) async {
    await signUpAndOpenOtp(tester);

    await fillOtp(tester, '123456');

    expect(Get.find<AuthController>().otpController.text, '123456');
  });

  testWidgets('OTP validates empty and short values', (tester) async {
    await signUpAndOpenOtp(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();
    expect(find.text('OTP is required.'), findsOneWidget);

    await fillOtp(tester, '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();
    expect(find.text('Please enter 6 digits.'), findsOneWidget);
  });

  testWidgets('correct OTP returns to login tab', (tester) async {
    await signUpAndOpenOtp(tester);

    await fillOtp(tester, '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
  });

  testWidgets('wrong credentials show error', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'wrong@gmail.com');
    await tester.enterText(fields.at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsWidgets);
  });

  testWidgets('fake login navigates home', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Test User'), findsOneWidget);
    expect(find.text('test@gmail.com'), findsOneWidget);
    expect(find.text('Candidate'), findsOneWidget);
  });
}
