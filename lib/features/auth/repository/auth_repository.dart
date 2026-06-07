/// Owns authentication data logic.
///
/// Replace these fake methods with Spring Boot API calls later.
class AuthRepository {
  const AuthRepository();

  static const fakeEmail = 'test@gmail.com';
  static const fakePassword = '123456';
  static const fakeOtp = '123456';

  Future<bool> fakeLogin(String email, String password) async {
    // Simulates the time a real Spring Boot request would take.
    await Future<void>.delayed(const Duration(seconds: 1));

    return email == fakeEmail && password == fakePassword;
  }

  /// Simulates a future Spring Boot registration endpoint.
  Future<bool> fakeSignUp(
    String username,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return username.isNotEmpty && email.isNotEmpty && password.isNotEmpty;
  }

  /// Simulates a future Spring Boot OTP verification endpoint.
  Future<bool> fakeVerifyOtp(String email, String otp) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return email.isNotEmpty && otp == fakeOtp;
  }

  /// Simulates asking the backend to send another OTP email.
  Future<bool> fakeResendOtp(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    return email.isNotEmpty;
  }
}
