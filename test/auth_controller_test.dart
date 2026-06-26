import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';

import 'auth_controller_test.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockAuthRepository();
    // Ensure Flutter bindings are initialized for TextEditingController.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController', () {
    group('isValidEmail', () {
      test('returns true for valid email addresses', () {
        final c = AuthController(mockRepo);
        expect(c.isValidEmail('user@example.com'), isTrue);
        expect(c.isValidEmail('test.user+tag@domain.co'), isTrue);
        expect(c.isValidEmail('NAME@GMAIL.COM'), isTrue);
      });

      test('returns false for invalid email addresses', () {
        final c = AuthController(mockRepo);
        expect(c.isValidEmail(''), isFalse);
        expect(c.isValidEmail('notanemail'), isFalse);
        expect(c.isValidEmail('missing@domain'), isFalse);
        expect(c.isValidEmail('@nodomain.com'), isFalse);
      });
    });

    group('isValidUsername', () {
      test('returns true for valid usernames', () {
        final c = AuthController(mockRepo);
        expect(c.isValidUsername('JohnDoe'), isTrue);
        expect(c.isValidUsername('john doe'), isTrue);
        expect(c.isValidUsername('user-123'), isTrue);
      });

      test('returns false for invalid usernames', () {
        final c = AuthController(mockRepo);
        expect(c.isValidUsername(''), isFalse);
        expect(c.isValidUsername('user@name'), isFalse);
        expect(c.isValidUsername('user!'), isFalse);
      });
    });

    group('login', () {
      test('shows error when email is empty', () async {
        final c = AuthController(mockRepo);
        c.emailController.text = '';
        c.passwordController.text = 'Password1';

        await c.login();

        expect(c.errorMessage.value, 'Email is required.');
      });

      test('shows error when email is invalid', () async {
        final c = AuthController(mockRepo);
        c.emailController.text = 'invalid';
        c.passwordController.text = 'Password1';

        await c.login();

        expect(c.errorMessage.value, 'Please enter a valid email address');
      });

      test('shows error when password is empty', () async {
        final c = AuthController(mockRepo);
        c.emailController.text = 'user@example.com';
        c.passwordController.text = '';

        await c.login();

        expect(c.errorMessage.value, 'Password is required.');
      });

      test('shows error when password is too weak', () async {
        final c = AuthController(mockRepo);
        c.emailController.text = 'user@example.com';
        c.passwordController.text = 'weak';

        await c.login();

        expect(c.errorMessage.value, contains('at least 8 characters'));
      });

      test('calls repository on valid input', () async {
        when(mockRepo.fakeLogin(any, any)).thenAnswer((_) async => true);

        final c = AuthController(mockRepo);
        c.emailController.text = 'user@example.com';
        c.passwordController.text = 'Password1';

        await c.login();

        verify(mockRepo.fakeLogin('user@example.com', 'Password1')).called(1);
      });
    });
  });
}
