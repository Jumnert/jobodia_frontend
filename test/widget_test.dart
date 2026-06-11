import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/view/ai_chat_screen.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/cv_builder_screen.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/home/view/widgets/job_feed_card.dart';
import 'package:jobodia_frontend/features/pricing/view/pricing_screen.dart';
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

  test('HomeController filters by salary and exposes internship level', () {
    final controller = HomeController();

    expect(controller.levels, contains('Internship'));

    controller.updateSalaryRange(6000, 7200);

    expect(
      controller.filteredJobs.map((job) => job.title),
      contains('UX Researcher'),
    );
    expect(
      controller.filteredJobs.map((job) => job.title),
      isNot(contains('UI Designer - Fintech App')),
    );

    controller.onClose();
  });

  testWidgets('job feed card fits compact context menu preview height', (
    tester,
  ) async {
    final job = HomeController().jobs.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 246,
              child: JobFeedCard(job: job),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('AI chat sends message and shows mock reply', (tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: BindingsBuilder(() {
          Get.put(AiChatController());
        }),
        home: const AiChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jobodia Ai'), findsOneWidget);
    expect(find.text('Hi, Han!'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Send a message...'),
      'Can you review my CV?',
    );
    await tester.tap(find.byIcon(Icons.send_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Can you review my CV?'), findsOneWidget);
    expect(
      find.text(
        "Absolutely! Please upload your CV and I'll analyze it for you.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('AI chat plus button shows attachment popup on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: BindingsBuilder(() {
          Get.put(AiChatController());
        }),
        home: const AiChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Photo Library'), findsOneWidget);
    expect(find.text('File'), findsOneWidget);
    expect(find.text('NotebookLM'), findsOneWidget);
  });

  testWidgets('AI chat more button opens searchable history drawer', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: BindingsBuilder(() {
          Get.put(AiChatController());
        }),
        home: const AiChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Chat history'), findsOneWidget);
    expect(find.text('New chat'), findsOneWidget);
    expect(find.text('Review my product designer CV'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(find.text('Improve resume bullet points'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search chats'),
      'remote',
    );
    await tester.pumpAndSettle();

    expect(find.text('Find remote Flutter jobs'), findsOneWidget);
    expect(find.text('Review my product designer CV'), findsNothing);
  });

  testWidgets('AI chat new chat clears conversation from drawer', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialBinding: BindingsBuilder(() {
          Get.put(AiChatController());
        }),
        home: const AiChatScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final controller = Get.find<AiChatController>();

    controller.sendMessage('Can you review my CV?');
    await tester.pumpAndSettle();
    expect(find.text('Can you review my CV?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New chat'));
    await tester.pumpAndSettle();

    expect(find.text('Hi, Han!'), findsOneWidget);
    expect(find.text('Can you review my CV?'), findsNothing);
  });

  testWidgets('CV builder advances through steps and template selection', (
    tester,
  ) async {
    final cvController = Get.put(CvBuilderController());
    cvController.showGeneratedSnackBar = false;

    await tester.pumpWidget(const GetMaterialApp(home: CvBuilderScreen()));

    expect(find.text('Ready to make a CV?'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('Upload headshot'), findsOneWidget);

    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();

    expect(cvController.hasHeadshot.value, isTrue);
    expect(find.text('Headshot selected'), findsOneWidget);

    cvController.fullNameController.text = 'Han Jobodia';
    cvController.emailController.text = 'han@gmail.com';
    cvController.phoneController.text = '12345678';
    cvController.locationController.text = 'Phnom Penh';
    await tester.pump();
    cvController.nextStep();
    await tester.pumpAndSettle();

    expect(find.text('Tell us about your work'), findsOneWidget);
    expect(find.text('Work experience'), findsOneWidget);
    expect(find.text('Experience 1'), findsOneWidget);

    cvController.setWorkStartDate(
      cvController.workExperiences.first,
      DateTime(2023),
    );
    await tester.pumpAndSettle();
    expect(cvController.workExperiences.first.startController.text, 'Jan 2023');

    expect(find.text('Add work experience'), findsOneWidget);
    cvController.addWorkExperience();
    cvController.addWorkExperience();
    await tester.pumpAndSettle();

    expect(cvController.workExperiences.length, 3);
    expect(cvController.canAddWorkExperience, isFalse);

    await tester.scrollUntilVisible(
      find.text('Education 1'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Education 1'), findsOneWidget);
    expect(find.text('Add education'), findsOneWidget);
    cvController.addEducation();
    cvController.addEducation();
    await tester.pumpAndSettle();

    expect(cvController.educations.length, 3);
    expect(cvController.canAddEducation, isFalse);

    cvController.skillController.text = 'Flutter';
    cvController.addSkill();
    await tester.pumpAndSettle();

    expect(cvController.skills, contains('Flutter'));

    cvController.nextStep();
    await tester.pumpAndSettle();

    expect(find.text('Choose a template you like'), findsOneWidget);
    await tester.tap(find.text('Balanced'));
    await tester.pumpAndSettle();
    cvController.nextStep();
    await tester.pump();

    expect(cvController.isGenerated.value, isTrue);
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

  testWidgets('home chat nav opens AI chat screen', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    expect(find.text('Jobodia Ai'), findsOneWidget);
    expect(find.text('How can I help you today?'), findsOneWidget);
  });

  testWidgets('home notification bell opens notifications', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.notifications_none_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('New job match'), findsOneWidget);
    expect(find.text('AI CV update'), findsOneWidget);
  });

  testWidgets('home layers nav opens CV builder', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.layers_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Ready to make a CV?'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
  });

  testWidgets('settings pricing tile opens pricing plans', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pricing Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Pricing Plan'), findsOneWidget);
    expect(find.text('Access Premium\nFeatures on Every Plan'), findsOneWidget);
    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('home settings nav opens settings page', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Leave feedback'), findsOneWidget);
    expect(find.text('Terms and Conditions'), findsOneWidget);

    await tester.tap(
      find.byWidgetPredicate(
        (widget) => widget is Switch || widget is CupertinoSwitch,
      ),
    );
    await tester.pumpAndSettle();

    expect(Get.isDarkMode, isTrue);
    Get.changeThemeMode(ThemeMode.light);
  });

  testWidgets('pricing plan tabs and yearly toggle update prices', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: PricingScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Starter'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Pro'));
    await tester.pumpAndSettle();
    expect(find.text('Pro'), findsWidgets);
    expect(find.text('8'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Yearly'),
      find.byType(Scrollable).first,
      const Offset(0, -220),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    expect(find.text('79'), findsOneWidget);
  });

  testWidgets('home search filters jobs', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Search jobs'), 'UX');
    await tester.pump();

    expect(find.text('UX Researcher'), findsOneWidget);
    expect(find.text('Product Designer - SaaS'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search jobs'),
      'xyz',
    );
    await tester.pump();

    expect(find.text('No jobs match your search.'), findsOneWidget);
  });

  testWidgets('home filter filters jobs by location', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.filter_alt_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Internship'), findsOneWidget);
    expect(find.text('Salary range'), findsOneWidget);

    await tester.tap(find.text('Remote'));
    await tester.tap(find.widgetWithText(FilledButton, 'Show jobs'));
    await tester.pumpAndSettle();

    expect(find.text('Frontend Engineer'), findsOneWidget);
    expect(find.text('UX Researcher'), findsNothing);
  });

  testWidgets('job cards include context menu actions', (tester) async {
    await tester.pumpWidget(const JobodiaApp());
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test@gmail.com');
    await tester.enterText(fields.at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final contextMenu = tester.widget<CupertinoContextMenu>(
      find.byType(CupertinoContextMenu).first,
    );
    final labels = contextMenu.actions
        .map(
          (action) =>
              ((action as CupertinoContextMenuAction).child as Text).data,
        )
        .toList();

    expect(labels, containsAll(['Report', 'Fave', 'Share', 'Not interested']));
  });
}
