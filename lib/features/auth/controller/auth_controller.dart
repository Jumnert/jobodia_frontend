import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/services/app_security_service.dart';
import 'package:jobodia_frontend/core/utils/input_sanitizer.dart';
import 'package:jobodia_frontend/features/auth/model/user_model.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';
import 'package:jobodia_frontend/services/push_notification_service.dart';

/// GetX Controller used as the ViewModel for authentication screens.
import 'package:jobodia_frontend/features/auth/controller/form_validation_mixin.dart';

class AuthController extends GetxController with FormValidationMixin {
  AuthController(this._authRepository);

  static const authTokenStorageKey = 'jobodiaAuthToken';
  static const oauthSetupTokenStorageKey = 'jobodiaOAuthSetupToken';

  final AuthRepository _authRepository;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();
  final resetEmailController = TextEditingController();
  final resetOtpController = TextEditingController();

  // 0 = Login, 1 = Sign Up.
  final RxInt selectedAuthTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxBool isResetPasswordLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString resetPasswordErrorMessage = ''.obs;
  final RxString registeredEmail = ''.obs;
  final RxString pendingOAuthSetupToken = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isResetConfirmPasswordVisible = false.obs;
  final currentUser = Rxn<UserModel>();

  /// Whether a user is currently authenticated.
  bool get isLoggedIn => currentUser.value != null;
  bool get hasPendingOAuthSignup => pendingOAuthSetupToken.value.isNotEmpty;

  Future<void> loginWithOAuth(OAuthProvider provider) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final result = await _authRepository.loginWithOAuth(provider);
      registeredEmail.value = result.email;

      if (result.requiresRoleSelection) {
        pendingOAuthSetupToken.value = result.setupToken!;
        await SecureStorageService.to.writeSecure(
          oauthSetupTokenStorageKey,
          result.setupToken!,
        );
        Get.offAllNamed<void>(AppRoutes.selectRole);
        return;
      }

      await _finishOAuthLogin(result);
      Get.offAllNamed<void>(AppRoutes.home);
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Login failed', error.message);
    } on Object {
      _showErrorSnackBar(
        'Login cancelled',
        'Google or GitHub login did not finish. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> completePendingOAuthSignup(UserRole role) async {
    var setupToken = pendingOAuthSetupToken.value;
    setupToken = setupToken.isNotEmpty
        ? setupToken
        : await SecureStorageService.to.readSecure(oauthSetupTokenStorageKey) ??
              '';
    if (setupToken.isEmpty) return true;

    if (isLoading.value) return false;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _authRepository.completeOAuthSignup(
        setupToken: setupToken,
        role: role == UserRole.employer ? 'EMPLOYER' : 'SEEKER',
        email: registeredEmail.value,
      );
      await _finishOAuthLogin(result);
      pendingOAuthSetupToken.value = '';
      await SecureStorageService.to.deleteSecure(oauthSetupTokenStorageKey);
      return true;
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Account setup failed', error.message);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _finishOAuthLogin(OAuthLoginResult result) async {
    final token = result.token;
    if (token == null || token.isEmpty) {
      throw const AuthRepositoryException(
        'The backend did not return a token.',
      );
    }

    await SecureStorageService.to.writeSecure(authTokenStorageKey, token);
    if (Get.isRegistered<PushNotificationService>()) {
      await Get.find<PushNotificationService>().registerAuthenticatedDevice(
        token,
      );
    }
    final backendRole = result.role?.toUpperCase() ?? 'SEEKER';
    if (Get.isRegistered<RoleController>()) {
      Get.find<RoleController>().selectRole(
        backendRole == 'EMPLOYER' ? UserRole.employer : UserRole.jobSeeker,
      );
    }
    final email = result.email;
    currentUser.value = UserModel(
      id: email,
      name: email.isEmpty ? 'User' : email.split('@').first,
      email: email,
      role: backendRole,
      avatarUrl: null,
    );
  }

  void changeAuthTab(int index) {
    if (isLoading.value || selectedAuthTab.value == index) return;
    selectedAuthTab.value = index;
    errorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.toggle();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.toggle();
  }

  void toggleResetConfirmPasswordVisibility() {
    isResetConfirmPasswordVisible.toggle();
  }

  Future<void> login() async {
    final email = InputSanitizer.normalizeEmail(emailController.text) ?? '';
    final password = passwordController.text;

    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (email.isEmpty || !isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required.';
      return;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errorMessage.value = passwordError;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final isSuccess = await _authRepository.fakeLogin(email, password);
      if (!isSuccess) {
        _showErrorSnackBar('Login failed', 'Invalid email or password.');
        return;
      }

      final loginResult = _authRepository.lastPasswordLoginResult;
      if (loginResult != null) {
        await SecureStorageService.to.writeSecure(
          authTokenStorageKey,
          loginResult.token,
        );
        if (Get.isRegistered<PushNotificationService>()) {
          await Get.find<PushNotificationService>().registerAuthenticatedDevice(
            loginResult.token,
          );
        }
        final backendRole = loginResult.role.toUpperCase();
        currentUser.value = UserModel(
          id: loginResult.email,
          name: loginResult.email.split('@').first,
          email: loginResult.email,
          role: backendRole,
          avatarUrl: null,
        );
        if (Get.isRegistered<RoleController>()) {
          Get.find<RoleController>().selectRole(
            backendRole == 'EMPLOYER' ? UserRole.employer : UserRole.jobSeeker,
          );
        }
      } else {
        currentUser.value = UserModel(
          id: '1',
          name: 'User',
          email: email,
          role: 'Candidate',
          avatarUrl: null,
        );
      }
      // First-time users pick a role (Job Seeker / Employer) before entering.
      final hasRole = Get.isRegistered<RoleController>()
          ? Get.find<RoleController>().hasRole
          : false;
      Get.offAllNamed(hasRole ? AppRoutes.home : AppRoutes.selectRole);
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Login failed', error.message);
    } on Object {
      _showErrorSnackBar('Login failed', 'Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    final username = InputSanitizer.sanitizeText(usernameController.text);
    final email = InputSanitizer.normalizeEmail(emailController.text) ?? '';
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty) {
      errorMessage.value = 'Username is required.';
      return;
    }

    if (!isValidUsername(username)) {
      errorMessage.value =
          'Username can only contain letters, digits, spaces, and hyphens';
      return;
    }

    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (email.isEmpty || !isValidEmail(email)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required.';
      return;
    }

    final passwordError = validatePassword(password);
    if (passwordError != null) {
      errorMessage.value = passwordError;
      return;
    }

    if (confirmPassword.isEmpty) {
      errorMessage.value = 'Confirm password is required.';
      return;
    }

    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final isSuccess = await _authRepository.fakeSignUp(
        username,
        email,
        password,
      );
      if (!isSuccess) {
        _showErrorSnackBar('Sign up failed', 'Please check your information.');
        return;
      }

      registeredEmail.value = email;
      otpController.clear();
      Get.toNamed(AppRoutes.otpVerification);
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Sign up failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      errorMessage.value = 'OTP is required.';
      return;
    }

    if (otp.length < 6) {
      errorMessage.value = 'Please enter 6 digits.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final isSuccess = await _authRepository.fakeVerifyOtp(
        registeredEmail.value,
        otp,
      );
      if (!isSuccess) {
        _showErrorSnackBar('Verification failed', 'Invalid OTP code.');
        return;
      }

      Get.snackbar(
        'Success',
        'Email verified successfully. Please log in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      goBackToLogin();
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Verification failed', error.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (isResendingOtp.value) return;

    isResendingOtp.value = true;
    errorMessage.value = '';

    try {
      final isSuccess = await _authRepository.fakeResendOtp(
        registeredEmail.value,
      );
      if (isSuccess) {
        Get.snackbar(
          'Resend OTP',
          'OTP sent again',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      } else {
        _showErrorSnackBar('Resend failed', 'Email is missing.');
      }
    } on AuthRepositoryException catch (error) {
      _showErrorSnackBar('Resend failed', error.message);
    } finally {
      isResendingOtp.value = false;
    }
  }

  Future<void> resetPassword() async {
    final email =
        InputSanitizer.normalizeEmail(resetEmailController.text) ?? '';
    final otp = resetOtpController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = resetConfirmPasswordController.text;

    if (!isValidEmail(email)) {
      resetPasswordErrorMessage.value = 'Enter a valid account email.';
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      resetPasswordErrorMessage.value =
          'Enter the 6-digit code from your email.';
      return;
    }

    if (newPassword.isEmpty) {
      resetPasswordErrorMessage.value = 'New password is required.';
      return;
    }

    final passwordError = validatePassword(newPassword);
    if (passwordError != null) {
      resetPasswordErrorMessage.value = passwordError;
      return;
    }

    if (confirmPassword.isEmpty) {
      resetPasswordErrorMessage.value = 'Confirm password is required.';
      return;
    }

    if (newPassword != confirmPassword) {
      resetPasswordErrorMessage.value = 'Passwords do not match.';
      return;
    }

    isResetPasswordLoading.value = true;
    resetPasswordErrorMessage.value = '';
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await _authRepository.resetPassword(
        email: email,
        otp: otp,
        password: newPassword,
      );

      Get.snackbar(
        'Success',
        'Password reset successfully. Please log in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      clearResetPasswordForm();
      Get.offAllNamed(AppRoutes.login);
    } on AuthRepositoryException catch (error) {
      resetPasswordErrorMessage.value = error.message;
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  Future<void> sendResetOtp() async {
    final email =
        InputSanitizer.normalizeEmail(resetEmailController.text) ?? '';
    if (!isValidEmail(email)) {
      resetPasswordErrorMessage.value = 'Enter a valid account email.';
      return;
    }
    if (isResendingOtp.value) return;
    isResendingOtp.value = true;
    resetPasswordErrorMessage.value = '';
    try {
      await _authRepository.sendResetOtp(email);
      Get.snackbar(
        'Reset code sent',
        'Check your email for the 6-digit code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } on AuthRepositoryException catch (error) {
      resetPasswordErrorMessage.value = error.message;
    } finally {
      isResendingOtp.value = false;
    }
  }

  void clearResetPasswordForm() {
    newPasswordController.clear();
    resetConfirmPasswordController.clear();
    resetEmailController.clear();
    resetOtpController.clear();
    resetPasswordErrorMessage.value = '';
    isNewPasswordVisible.value = false;
    isResetConfirmPasswordVisible.value = false;
  }

  void goBackToLogin() {
    selectedAuthTab.value = 0;
    usernameController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    errorMessage.value = '';
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> logout() async {
    if (Get.isRegistered<AppSecurityService>()) {
      await Get.find<AppSecurityService>().clearPasscode();
    }
    final authToken = await SecureStorageService.to.readSecure(
      authTokenStorageKey,
    );
    if (authToken != null && Get.isRegistered<PushNotificationService>()) {
      await Get.find<PushNotificationService>().unregisterAuthenticatedDevice(
        authToken,
      );
    }
    currentUser.value = null;
    await SecureStorageService.to.deleteSecure(authTokenStorageKey);
    await SecureStorageService.to.deleteSecure(oauthSetupTokenStorageKey);
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    clearResetPasswordForm();
    registeredEmail.value = '';
    pendingOAuthSetupToken.value = '';
    errorMessage.value = '';
    selectedAuthTab.value = 0;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Skip login for demo purposes - creates a guest user session.
  void skipLogin() {
    currentUser.value = UserModel(
      id: 'guest',
      name: 'Guest User',
      email: 'guest@jobodia.demo',
      role: 'Candidate',
      avatarUrl: null,
    );
    Get.offAllNamed(AppRoutes.selectRole);
  }

  void _showErrorSnackBar(String title, String message) {
    errorMessage.value = message;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    resetEmailController.dispose();
    resetOtpController.dispose();
    super.onClose();
  }
}
