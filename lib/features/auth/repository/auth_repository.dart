/// Authentication repository.
///
/// All methods are stubs — replace with real Spring Boot API calls.
class AuthRepository {
  const AuthRepository();

  static void _validateCredentials(String email, String password) {
    if (email.isEmpty || !email.contains('@')) {
      throw ArgumentError('Invalid email address');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters');
    }
  }

  Future<bool> fakeLogin(String email, String password) async {
    _validateCredentials(email, password);
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> fakeSignUp(
    String username,
    String email,
    String password,
  ) async {
    _validateCredentials(email, password);
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> fakeVerifyOtp(String email, String otp) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> fakeResendOtp(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }

  Future<bool> fakeResetPassword(String newPassword) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return true;
  }
}
