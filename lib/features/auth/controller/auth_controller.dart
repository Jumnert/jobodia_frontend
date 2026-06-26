import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/model/user_model.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';

/// GetX Controller used as the ViewModel for authentication screens.
import 'package:jobodia_frontend/features/auth/controller/form_validation_mixin.dart';

class AuthController extends GetxController with FormValidationMixin {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final resetConfirmPasswordController = TextEditingController();

  // 0 = Login, 1 = Sign Up.
  final RxInt selectedAuthTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxBool isResetPasswordLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString resetPasswordErrorMessage = ''.obs;
  final RxString registeredEmail = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isResetConfirmPasswordVisible = false.obs;
  final currentUser = Rxn<UserModel>();

  /// Whether a user is currently authenticated.
  bool get isLoggedIn => currentUser.value != null;

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
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (!isValidEmail(email)) {
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

      // TODO: Replace with real user data from API response
      currentUser.value = UserModel(
        id: '1',
        name: 'User',
        email: emailController.text.trim(),
        role: 'Candidate',
        avatarUrl: null,
      );
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      _showErrorSnackBar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
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

    if (email.isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (!isValidEmail(email)) {
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
    } finally {
      isResendingOtp.value = false;
    }
  }

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = resetConfirmPasswordController.text;

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
      final isSuccess = await _authRepository.fakeResetPassword(newPassword);
      if (!isSuccess) {
        resetPasswordErrorMessage.value = 'Unable to reset password.';
        return;
      }

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
    } finally {
      isResetPasswordLoading.value = false;
    }
  }

  void clearResetPasswordForm() {
    newPasswordController.clear();
    resetConfirmPasswordController.clear();
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

  void logout() {
    currentUser.value = null;
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    otpController.clear();
    clearResetPasswordForm();
    registeredEmail.value = '';
    errorMessage.value = '';
    selectedAuthTab.value = 0;
    Get.offAllNamed(AppRoutes.login);
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
    super.onClose();
  }
}
