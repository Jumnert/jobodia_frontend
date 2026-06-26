import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import '../edit_profile_screen.dart'; // To access EditField, SectionLabel, PortfolioControllers, PortfolioCard

class BasicInfoSection extends StatelessWidget {
  const BasicInfoSection({
    required this.nameCtrl,
    required this.roleCtrl,
    required this.aboutCtrl,
    super.key,
  });

  final TextEditingController nameCtrl;
  final TextEditingController roleCtrl;
  final TextEditingController aboutCtrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Basic Info'),
        const SizedBox(height: 12),
        EditField(
          label: 'Name',
          controller: nameCtrl,
          hint: 'Your full name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        EditField(
          label: 'Role',
          controller: roleCtrl,
          hint: 'e.g. Frontend Developer',
          icon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: 14),
        EditField(
          label: 'About',
          controller: aboutCtrl,
          hint: 'Write a short bio...',
          icon: Icons.notes_rounded,
          minLines: 4,
          maxLines: 8,
        ),
      ],
    );
  }
}

class LinksSection extends StatelessWidget {
  const LinksSection({
    required this.portfolioControllers,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  final List<PortfolioControllers> portfolioControllers;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel('Portfolio'),
        const SizedBox(height: 12),
        ...List.generate(portfolioControllers.length, (i) {
          return PortfolioCard(
            index: i,
            controllers: portfolioControllers[i],
            onRemove: () => onRemove(i),
          );
        }),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: const StadiumBorder(),
            minimumSize: const Size.fromHeight(44),
          ),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Link'),
        ),
      ],
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return CustomButton(label: 'Save Changes', onPressed: onSave);
  }
}
