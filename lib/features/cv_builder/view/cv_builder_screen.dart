import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/loading_overlay.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/basic_info_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/template_step.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/work_info_step.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_bottom_navigation_bar.dart';
import 'package:jobodia_frontend/features/home/view/widgets/app_navigation.dart';

class CvBuilderScreen extends GetView<CvBuilderController> {
  const CvBuilderScreen({super.key, this.showBottomNav = true});

  final bool? showBottomNav;

  bool _hasUnsavedChanges() {
    if (controller.stepIndex.value > 0) return true;
    return controller.fullNameController.text.trim().isNotEmpty ||
        controller.emailController.text.trim().isNotEmpty ||
        controller.phoneController.text.trim().isNotEmpty ||
        controller.titleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_hasUnsavedChanges()) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard draft?'),
            content: const Text('You have unsaved CV data. Leave anyway?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.palette.scaffold,
        extendBody: true,
        body: Obx(
          () => Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top,
                ),
                child: Column(
                  children: [
                    const _Header(),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          switch (controller.stepIndex.value) {
                            case 0:
                              return BasicInfoStep(controller: controller);
                            case 1:
                              return WorkInfoStep(controller: controller);
                            default:
                              return TemplateStep(controller: controller);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isParsing.value)
                Positioned.fill(
                  child: ColoredBox(
                    color: Colors.black.withAlpha(100),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: context.palette.surface, borderRadius: BorderRadius.circular(16)),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Parsing Resume...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: (showBottomNav ?? true)
            ? AppBottomNavigationBar(
                selectedIndex: 1,
                onDestinationSelected: (index) =>
                    navigateMainDestination(context, index, currentIndex: 1),
                onSearchPressed: () => Get.toNamed<void>(AppRoutes.search),
              )
            : null,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: Get.back,
                tooltip: 'Back',
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
              Expanded(
                child: Text(
                  'Create CV',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.palette.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final step = Get.find<CvBuilderController>().stepIndex.value;
            final palette = context.palette;
            return Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 10),
                    decoration: BoxDecoration(
                      color: index <= step
                          ? palette.textPrimary
                          : palette.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Obx(() {
            final step = Get.find<CvBuilderController>().stepIndex.value;
            return Text(
              'Step ${step + 1}',
              style: TextStyle(
                color: context.palette.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            );
          }),
        ],
      ),
    );
  }
}
