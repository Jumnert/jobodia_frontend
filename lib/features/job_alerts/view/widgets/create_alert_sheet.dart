import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/home/controller/home_controller.dart';
import 'package:jobodia_frontend/features/job_alerts/controller/job_alert_controller.dart';

class CreateAlertSheet extends StatefulWidget {
  const CreateAlertSheet({super.key, this.initialKeyword});
  final String? initialKeyword;

  @override
  State<CreateAlertSheet> createState() => _CreateAlertSheetState();
}

class _CreateAlertSheetState extends State<CreateAlertSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();

  final List<String> _keywords = [];
  String? _selectedLocation;
  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
      _keywords.add(widget.initialKeyword!);
      _nameCtrl.text = 'Alert for \${widget.initialKeyword}';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _keywordCtrl.dispose();
    super.dispose();
  }

  void _addKeyword() {
    final kw = _keywordCtrl.text.trim();
    if (kw.isNotEmpty && !_keywords.contains(kw)) {
      setState(() {
        _keywords.add(kw);
        _keywordCtrl.clear();
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_keywords.isEmpty) {
      Get.snackbar('Error', 'Please add at least one keyword.');
      return;
    }

    final ctrl = Get.find<JobAlertController>();
    ctrl.createAlert(
      name: _nameCtrl.text.trim(),
      keywords: _keywords,
      location: _selectedLocation,
      level: _selectedLevel,
    );

    Get.back();
    Get.snackbar(
      'Alert Created',
      'You will be notified of new jobs matching these criteria.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final homeCtrl = Get.find<HomeController>();

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: palette.scaffold,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Job Alert',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Alert Name',
                hintText: 'e.g. Remote Flutter Developer',
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),
              Text(
                'Keywords',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _keywordCtrl,
                      label: 'Add Keyword',
                      hintText: 'e.g. Flutter, Dart',
                      prefixIcon: Icons.tag,
                      onSubmitted: (_) => _addKeyword(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addKeyword,
                    icon: const Icon(
                      Icons.add_circle,
                      color: AppColors.brandTeal,
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (_keywords.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _keywords.map((kw) {
                    return Chip(
                      label: Text(
                        kw,
                        style: TextStyle(
                          color: palette.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                      backgroundColor: palette.surfaceMuted,
                      deleteIconColor: palette.iconMuted,
                      onDeleted: () {
                        setState(() => _keywords.remove(kw));
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Location (Optional)',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    isExpanded: true,
                    hint: Text(
                      'Any location',
                      style: TextStyle(color: palette.textSecondary),
                    ),
                    dropdownColor: palette.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: palette.iconMuted,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any location'),
                      ),
                      ...homeCtrl.locations
                          .where((l) => l != 'All')
                          .map(
                            (l) => DropdownMenuItem(
                              value: l,
                              child: Text(
                                l,
                                style: TextStyle(color: palette.textPrimary),
                              ),
                            ),
                          ),
                    ],
                    onChanged: (val) => setState(() => _selectedLocation = val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Level (Optional)',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLevel,
                    isExpanded: true,
                    hint: Text(
                      'Any level',
                      style: TextStyle(color: palette.textSecondary),
                    ),
                    dropdownColor: palette.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: palette.iconMuted,
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Any level'),
                      ),
                      ...homeCtrl.levels
                          .where((l) => l != 'All')
                          .map(
                            (l) => DropdownMenuItem(
                              value: l,
                              child: Text(
                                l,
                                style: TextStyle(color: palette.textPrimary),
                              ),
                            ),
                          ),
                    ],
                    onChanged: (val) => setState(() => _selectedLevel = val),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(label: 'Save Alert', onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
