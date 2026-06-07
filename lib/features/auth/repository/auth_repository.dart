/// Fake authentication repository.
///
/// Later, replace these fake methods with Spring Boot API calls.
class AuthRepository {
  const AuthRepository();

  static const fakeEmail = 'test@gmail.com';
  static const fakePassword = '123456';
  static const fakeOtp = '123456';

  Future<bool> fakeLogin(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return email == fakeEmail && password == fakePassword;
  }

  Future<bool> fakeSignUp(
    String username,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return username.isNotEmpty && email.isNotEmpty && password.isNotEmpty;
  }

  Future<bool> fakeVerifyOtp(String email, String otp) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && otp == fakeOtp;
  }

  Future<bool> fakeResendOtp(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return email.isNotEmpty;
  }
}
