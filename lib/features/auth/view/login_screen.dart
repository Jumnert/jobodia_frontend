import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/auth/controller/auth_controller.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/login_form.dart';
import 'package:jobodia_frontend/features/auth/view/widgets/signup_form.dart';

/// Shared authentication screen for Login and Register.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.scaffold,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const headerHeight = 225.0;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    physics: keyboardVisible
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        children: [
                          const _AuthHeader(height: headerHeight),
                          Container(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - headerHeight,
                            ),
                            decoration: BoxDecoration(
                              color: palette.scaffold,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                18,
                                25,
                                18,
                                MediaQuery.paddingOf(context).bottom + 24,
                              ),
                              child: const _AuthContent(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthContent extends GetView<AuthController> {
  const _AuthContent();

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Obx(
        () => FTabs(
          control: FTabControl.lifted(
            index: controller.selectedAuthTab.value,
            onChange: (index) {
              HapticFeedback.selectionClick();
              controller.changeAuthTab(index);
            },
          ),
          style: const FTabsStyleDelta.delta(spacing: 22),
          children: const [
            FTabEntry(
              label: Text('Log in'),
              child: LoginForm(key: ValueKey('login_form')),
            ),
            FTabEntry(
              label: Text('Sign up'),
              child: SignUpForm(key: ValueKey('signup_form')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.headerStart, AppColors.headerEnd],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 13, 25, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jobodia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Start Your Journey',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Log in to find jobs that match your skills and build\n'
                    'your CV with AI.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
