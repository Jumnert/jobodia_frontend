import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
      children: [
        Text(
          'Ready to make a CV?',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start with the basic details so the CV can match your profile.',
          style: TextStyle(
            fontSize: 15,
            color: palette.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.importResume,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandTeal.withAlpha(20),
              foregroundColor: AppColors.brandTeal,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.brandTeal, width: 1.5),
              ),
            ),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text(
              'Upload Resume to Auto-Fill',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const InfoIconLine(
          icon: Icons.person_rounded,
          text: 'Headshot, full name, email, phone number, and location',
        ),
        const SizedBox(height: 18),
        HeadshotUploadTile(controller: controller),
        const SizedBox(height: 18),
        CustomTextField(
          label: 'Full name',
          hintText: 'Your full name',
          controller: controller.fullNameController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: controller.emailController,
          prefixIcon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Phone number',
          hintText: '+855 12 345 678',
          controller: controller.phoneController,
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Location',
          hintText: 'City, Country',
          controller: controller.locationController,
          prefixIcon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 24),
        CustomButton(label: 'Continue', onPressed: controller.nextStep),
      ],
    );
  }
}
