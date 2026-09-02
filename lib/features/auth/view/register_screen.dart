import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/auth_scene.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/signup_form.dart';

/// Dedicated account-creation route.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => const AuthScene(
    title: 'Create your account',
    subtitle:
        'Build your Jobodia profile and take the next step in your career.',
    socialLabel: 'or sign up with',
    form: SignUpForm(),
  );
}
