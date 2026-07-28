import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// Shown after sign up (and re-openable from Settings) so the user picks
/// whether they use Jobodia as a Job Seeker or an Employer.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, this.preview = false});

  /// When true the screen was opened from Settings to change an existing role,
  /// so it pops back instead of continuing into the app.
  final bool preview;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RoleController>();
    final theme = FTheme.of(context);

    return FScaffold(
      header: preview
          ? BlurredHeader(
              child: FHeader.nested(
                title: const Text('Your role'),
                prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
              ),
            )
          : null,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          FLucideIcons.users,
                          size: 48,
                          color: theme.colors.primary,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select Your Role',
                          textAlign: TextAlign.center,
                          style: theme.typography.body.xl2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colors.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Choose how you'd like to use Jobodia.",
                          textAlign: TextAlign.center,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Obx(
                          () => _RoleCard(
                            icon: FLucideIcons.userSearch,
                            role: UserRole.jobSeeker,
                            selected:
                                controller.role.value == UserRole.jobSeeker,
                            onTap: () =>
                                _choose(controller, UserRole.jobSeeker),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Obx(
                          () => _RoleCard(
                            icon: FLucideIcons.building2,
                            role: UserRole.employer,
                            selected:
                                controller.role.value == UserRole.employer,
                            onTap: () => _choose(controller, UserRole.employer),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text.rich(
                          TextSpan(
                            text: 'You can switch roles anytime in ',
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                            children: [
                              TextSpan(
                                text: 'settings.',
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _choose(RoleController controller, UserRole role) {
    HapticFeedback.selectionClick();
    controller.selectRole(role);
    if (preview) {
      Get.back<void>();
    } else {
      Get.offAllNamed<void>(AppRoutes.home);
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final colors = theme.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: colors.foreground),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    role.headline,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.foreground,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    FLucideIcons.circleCheck,
                    size: 20,
                    color: colors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              role.description,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
