import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:jobodia_frontend/features/job_post/controller/job_post_controller.dart';
import 'package:jobodia_frontend/core/widgets/passcode_screen.dart';

class JobPostScreen extends GetView<JobPostController> {
  const JobPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      child: SafeArea(
        bottom: false,
        child: Obx(() {
          final view = controller.currentView.value;
          return Stack(
            children: [
              Positioned.fill(
                child: switch (view) {
                  JobPostView.dashboard => _EmployerJobsDashboard(
                    controller: controller,
                    onPostJob: () => _choosePostMethod(context),
                  ),
                  JobPostView.editor => _JobEditor(controller: controller),
                  JobPostView.success => _PublishedState(
                    onCreateAnother: controller.startAnotherPost,
                  ),
                },
              ),
              if (controller.isGeneratingAi.value)
                const Positioned.fill(child: _AiGenerationOverlay()),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _choosePostMethod(BuildContext context) async {
    await showFDialog<void>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        clipBehavior: Clip.antiAlias,
        semanticsLabel: 'Create a job listing',
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'How would you like to start?',
                style: FTheme.of(
                  dialogContext,
                ).typography.display.lg.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Fill the listing yourself or let Jobodia AI prepare a draft.',
                style: FTheme.of(dialogContext).typography.body.sm.copyWith(
                  color: FTheme.of(dialogContext).colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 18),
              FTileGroup(
                children: [
                  FTile(
                    prefix: const Icon(FLucideIcons.filePenLine),
                    title: const Text('Fill manually'),
                    subtitle: const Text('Complete each section yourself.'),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      Navigator.of(dialogContext).pop();
                      controller.startManualPost();
                    },
                  ),
                  FTile(
                    prefix: const Icon(FLucideIcons.sparkles),
                    title: const Text('Draft with Jobodia AI'),
                    subtitle: const Text('Answer five quick fields first.'),
                    suffix: const Icon(FLucideIcons.chevronRight),
                    onPress: () {
                      Navigator.of(dialogContext).pop();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) _showAiBrief(context);
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAiBrief(BuildContext context) {
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.9,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (sheetContext) => _AiJobBriefSheet(
        onGenerate: (brief) {
          Navigator.of(sheetContext).pop();
          unawaited(_generateFromBrief(brief));
        },
      ),
    );
  }

  Future<void> _generateFromBrief(_AiJobBrief brief) async {
    final success = await controller.generateAiDraft(
      title: brief.title,
      salary: brief.salary,
      startDate: brief.startDate,
      endDate: brief.endDate,
      experienceLevel: brief.level,
    );
    if (!success) {
      Get.snackbar(
        'Could not create draft',
        controller.aiError.value,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

class _EmployerJobsDashboard extends StatelessWidget {
  const _EmployerJobsDashboard({
    required this.controller,
    required this.onPostJob,
  });

  final JobPostController controller;
  final VoidCallback onPostJob;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final jobs = controller.publishedJobs;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 140),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your job listings',
                    style: theme.typography.display.sm.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage current roles and create new opportunities.',
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (controller.hasSavedDraft.value) ...[
          const SizedBox(height: 20),
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.filePenLine),
                title: const Text('Continue saved draft'),
                subtitle: Text(
                  controller.draft.title.isEmpty
                      ? 'Unfinished job listing'
                      : controller.draft.title,
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: controller.openSavedDraft,
              ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        if (jobs.isEmpty)
          _NoJobListings(onPostJob: onPostJob)
        else ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  '${jobs.length} active ${jobs.length == 1 ? 'listing' : 'listings'}',
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FButton(
                onPress: onPostJob,
                prefix: const Icon(FLucideIcons.plus, size: 17),
                child: const Text('Post a job'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FTileGroup(
            children: [
              for (final job in jobs)
                FTile(
                  prefix: const Icon(FLucideIcons.briefcaseBusiness),
                  title: Text(job.title),
                  subtitle: Text('${job.location} · ${job.employmentType}'),
                  details: FBadge(child: const Text('Active')),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _NoJobListings extends StatelessWidget {
  const _NoJobListings({required this.onPostJob});

  final VoidCallback onPostJob;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FLucideIcons.briefcaseBusiness,
              color: theme.colors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'You do not have any job listings yet',
            textAlign: TextAlign.center,
            style: theme.typography.display.xs.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Create your first listing when you are ready to hire.',
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 22),
          FButton(
            onPress: onPostJob,
            prefix: const Icon(FLucideIcons.plus, size: 17),
            child: const Text('Post a job'),
          ),
        ],
      ),
    );
  }
}

class _JobEditor extends StatelessWidget {
  const _JobEditor({required this.controller});

  final JobPostController controller;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 20, 8),
          child: Row(
            children: [
              FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: controller.showDashboard,
                child: const Icon(FLucideIcons.arrowLeft),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post a job',
                      style: theme.typography.display.sm.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Step ${controller.step.value + 1} of 4',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: () => controller.saveDraft(notify: true),
                child: const Text('Save draft'),
              ),
            ],
          ),
        ),
        _StepIndicator(current: controller.step.value),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 140),
            children: [
              switch (controller.step.value) {
                0 => _BasicsStep(controller: controller),
                1 => _EmploymentStep(controller: controller),
                2 => _DescriptionStep(controller: controller),
                _ => _ReviewStep(controller: controller),
              },
              const SizedBox(height: 28),
              Row(
                children: [
                  if (controller.step.value > 0) ...[
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: controller.previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: controller.step.value > 0 ? 1 : 2,
                    child: FButton(
                      onPress: controller.step.value == 3
                          ? () async {
                              final authenticated = await requestAppAuthentication(
                                context,
                                reason:
                                    'Confirm your identity to publish this job.',
                              );
                              if (authenticated) controller.publishJob();
                            }
                          : controller.nextStep,
                      child: Text(
                        controller.step.value == 3 ? 'Publish job' : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AiJobBrief {
  const _AiJobBrief({
    required this.title,
    required this.salary,
    required this.startDate,
    required this.endDate,
    required this.level,
  });

  final String title;
  final String salary;
  final String startDate;
  final String endDate;
  final String level;
}

class _AiJobBriefSheet extends StatefulWidget {
  const _AiJobBriefSheet({required this.onGenerate});

  final ValueChanged<_AiJobBrief> onGenerate;

  @override
  State<_AiJobBriefSheet> createState() => _AiJobBriefSheetState();
}

class _AiJobBriefSheetState extends State<_AiJobBriefSheet> {
  final _title = TextEditingController();
  final _salary = TextEditingController();
  final _startDate = TextEditingController();
  final _endDate = TextEditingController();
  String _level = 'Mid-level';
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _salary.dispose();
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  void _submit() {
    if ([
      _title,
      _salary,
      _startDate,
      _endDate,
    ].any((controller) => controller.text.trim().isEmpty)) {
      setState(() => _error = 'Complete all five fields to continue.');
      return;
    }
    widget.onGenerate(
      _AiJobBrief(
        title: _title.text.trim(),
        salary: _salary.text.trim(),
        startDate: _startDate.text.trim(),
        endDate: _endDate.text.trim(),
        level: _level,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      child: ColoredBox(
        color: theme.colors.background,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FLucideIcons.sparkles,
                      color: theme.colors.primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell AI the essentials',
                          style: theme.typography.display.xs.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'You can edit everything before publishing.',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FTextField(
                control: FTextFieldControl.managed(controller: _title),
                label: const Text('Job title'),
                hint: 'Senior Flutter Developer',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              FTextField(
                control: FTextFieldControl.managed(controller: _salary),
                label: const Text('Salary range'),
                hint: '\$1,500 – \$2,500 per month',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FTextField(
                      control: FTextFieldControl.managed(
                        controller: _startDate,
                      ),
                      label: const Text('Start date'),
                      hint: '2026-08-15',
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FTextField(
                      control: FTextFieldControl.managed(controller: _endDate),
                      label: const Text('End date'),
                      hint: '2026-09-15',
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ChoiceField(
                label: 'Experience level',
                values: const ['Entry-level', 'Mid-level', 'Senior', 'Expert'],
                selected: _level,
                onSelected: (value) => setState(() => _level = value),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.destructive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FButton(
                onPress: _submit,
                prefix: const Icon(FLucideIcons.sparkles, size: 17),
                child: const Text('Create AI draft'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiGenerationOverlay extends StatelessWidget {
  const _AiGenerationOverlay();

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ColoredBox(
          color: theme.colors.background.withValues(alpha: 0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  'assets/animations/nav_icons/Sparkles Loop Loader ai.json',
                  width: 118,
                  height: 118,
                  repeat: true,
                  renderCache: RenderCache.raster,
                ),
                const SizedBox(height: 12),
                Text(
                  'Jobodia AI is drafting your listing',
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Writing the description, requirements, and skills…',
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(
          4,
          (index) => Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 4,
              margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
              decoration: BoxDecoration(
                color: index <= current
                    ? theme.colors.primary
                    : theme.colors.secondary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BasicsStep extends StatelessWidget {
  const _BasicsStep({required this.controller});

  final JobPostController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepHeading(
        title: 'Job basics',
        subtitle: 'Start with the role and where the work happens.',
      ),
      const SizedBox(height: 18),
      FTextField(
        control: FTextFieldControl.managed(
          controller: controller.titleController,
        ),
        label: const Text('Job title'),
        hint: 'Senior Flutter Developer',
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      FTextField(
        control: FTextFieldControl.managed(
          controller: controller.companyController,
        ),
        label: const Text('Company'),
        hint: 'Company name',
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 14),
      FTextField(
        control: FTextFieldControl.managed(
          controller: controller.locationController,
        ),
        label: const Text('Location'),
        hint: 'Phnom Penh, Cambodia',
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: 18),
      Obx(
        () => _ChoiceField(
          label: 'Work arrangement',
          values: const ['On-site', 'Hybrid', 'Remote'],
          selected: controller.workArrangement.value,
          onSelected: controller.chooseWorkArrangement,
        ),
      ),
    ],
  );
}

class _EmploymentStep extends StatelessWidget {
  const _EmploymentStep({required this.controller});

  final JobPostController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepHeading(
        title: 'Employment details',
        subtitle: 'Set expectations before candidates apply.',
      ),
      const SizedBox(height: 18),
      Obx(
        () => _ChoiceField(
          label: 'Employment type',
          values: const ['Full-time', 'Part-time', 'Contract', 'Internship'],
          selected: controller.employmentType.value,
          onSelected: controller.chooseEmploymentType,
        ),
      ),
      const SizedBox(height: 18),
      Obx(
        () => _ChoiceField(
          label: 'Experience level',
          values: const ['Entry-level', 'Mid-level', 'Senior', 'Expert'],
          selected: controller.experienceLevel.value,
          onSelected: controller.chooseExperienceLevel,
        ),
      ),
      const SizedBox(height: 18),
      FTextField(
        control: FTextFieldControl.managed(
          controller: controller.salaryController,
        ),
        label: const Text('Salary range'),
        description: const Text('Include the currency and payment period.'),
        hint: '\$1,500 – \$2,500 per month',
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: controller.applicationStartController,
              ),
              label: const Text('Application start'),
              hint: '2026-08-15',
              keyboardType: TextInputType.datetime,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: controller.applicationEndController,
              ),
              label: const Text('Application end'),
              hint: '2026-09-15',
              keyboardType: TextInputType.datetime,
            ),
          ),
        ],
      ),
    ],
  );
}

class _DescriptionStep extends StatelessWidget {
  const _DescriptionStep({required this.controller});

  final JobPostController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _StepHeading(
        title: 'Describe the opportunity',
        subtitle: 'Be clear about the work and what success looks like.',
      ),
      const SizedBox(height: 18),
      FTextField.multiline(
        control: FTextFieldControl.managed(
          controller: controller.descriptionController,
        ),
        label: const Text('Full job description'),
        hint: 'Describe the team, role, and day-to-day work...',
        minLines: 6,
        maxLines: 10,
        maxLength: 4000,
      ),
      const SizedBox(height: 14),
      FTextField.multiline(
        control: FTextFieldControl.managed(
          controller: controller.requirementsController,
        ),
        label: const Text('Requirements'),
        hint: 'Add one requirement per line...',
        minLines: 5,
        maxLines: 8,
        maxLength: 2500,
      ),
      const SizedBox(height: 14),
      FTextField(
        control: FTextFieldControl.managed(
          controller: controller.tagsController,
        ),
        label: const Text('Skills'),
        description: const Text('Separate skills with commas.'),
        hint: 'Flutter, Dart, Firebase',
      ),
    ],
  );
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.controller});

  final JobPostController controller;

  @override
  Widget build(BuildContext context) {
    final draft = controller.draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _StepHeading(
          title: 'Review your job',
          subtitle: 'Check the details before publishing.',
        ),
        const SizedBox(height: 18),
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.briefcaseBusiness),
              title: Text(draft.title),
              subtitle: Text(draft.company),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.mapPin),
              title: Text(draft.location),
              subtitle: Text(draft.workArrangement),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.clock3),
              title: Text(draft.employmentType),
              subtitle: Text(draft.experienceLevel),
            ),
            FTile(
              prefix: const Icon(FLucideIcons.banknote),
              title: Text(draft.salary),
              subtitle: const Text('Salary range'),
            ),
            if (draft.applicationStartDate.isNotEmpty ||
                draft.applicationEndDate.isNotEmpty)
              FTile(
                prefix: const Icon(FLucideIcons.calendarDays),
                title: Text(
                  '${draft.applicationStartDate} – ${draft.applicationEndDate}',
                ),
                subtitle: const Text('Application period'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Description',
          style: FTheme.of(
            context,
          ).typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          draft.description,
          style: FTheme.of(context).typography.body.sm.copyWith(
            color: FTheme.of(context).colors.mutedForeground,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: FTheme.of(
          context,
        ).typography.body.sm.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            FButton(
              variant: value == selected
                  ? FButtonVariant.primary
                  : FButtonVariant.outline,
              onPress: () => onSelected(value),
              child: Text(value),
            ),
        ],
      ),
    ],
  );
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.display.xs.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _PublishedState extends StatelessWidget {
  const _PublishedState({required this.onCreateAnother});

  final VoidCallback onCreateAnother;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 132,
              height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/nav_icons/Sparkles Loop Loader ai.json',
                    repeat: false,
                    width: 132,
                    height: 110,
                    renderCache: RenderCache.raster,
                  ),
                  Icon(
                    FLucideIcons.circleCheckBig,
                    size: 46,
                    color: theme.colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Job published',
              style: theme.typography.display.sm.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'Your listing is now active and appears in your job listings.',
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            FButton(
              onPress: onCreateAnother,
              child: const Text('View job listings'),
            ),
          ],
        ),
      ),
    );
  }
}
