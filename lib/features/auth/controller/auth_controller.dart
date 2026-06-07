import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/model/user_model.dart';
import 'package:jobodia_frontend/features/auth/repository/auth_repository.dart';

/// GetX Controller used as the ViewModel for authentication screens.
class AuthController extends GetxController {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final otpController = TextEditingController();

  // 0 = Login, 1 = Sign Up.
  final RxInt selectedAuthTab = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isResendingOtp = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString registeredEmail = ''.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final currentUser = Rxn<UserModel>();

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

  bool isValidGmail(String email) {
    final gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return gmailRegex.hasMatch(email.trim());
  }

  bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z]+$');
    return usernameRegex.hasMatch(username.trim());
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (!isValidGmail(email)) {
      errorMessage.value = 'Please enter a valid Gmail address';
      return;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required.';
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

      currentUser.value = const UserModel(
        id: '1',
        name: 'Test User',
        email: AuthRepository.fakeEmail,
        role: 'Candidate',
      );
      Get.offAllNamed(AppRoutes.home);
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
      errorMessage.value = 'Username must contain only letters';
      return;
    }

    if (email.isEmpty) {
      errorMessage.value = 'Email is required.';
      return;
    }

    if (!isValidGmail(email)) {
      errorMessage.value = 'Please enter a valid Gmail address';
      return;
    }

    if (password.isEmpty) {
      errorMessage.value = 'Password is required.';
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
    super.onClose();
  }
}
