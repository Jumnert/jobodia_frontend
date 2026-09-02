import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/auth_scene.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/login_form.dart';

/// Dedicated sign-in route.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => const AuthScene(
    title: 'Welcome back',
    subtitle: 'Sign in to discover work that fits your skills and goals.',
    socialLabel: 'or continue with',
    form: LoginForm(),
  );
}
