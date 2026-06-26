// ignore_for_file: deprecated_member_use, avoid_print, curly_braces_in_flow_control_structures, unused_import, unnecessary_underscores, unused_field, unused_local_variable, use_build_context_synchronously, duplicate_ignore
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';
import 'package:jobodia_frontend/features/cv_builder/service/cv_pdf_builder.dart';
import 'package:printing/printing.dart';

/// Accent color per template index, matched to the PDF accents.
const _accents = <Color>[
  Color(0xFF0EA5A4), // Classic — teal
  Color(0xFF2B5DF0), // Balanced — blue
  Color(0xFF202428), // Modern — near-black band
];

Color _accentFor(int index) => _accents[index.clamp(0, _accents.length - 1)];

class CvPreviewScreen extends GetView<CvBuilderController> {
  const CvPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.scaffold,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: Get.back,
          icon: const Icon(Icons.chevron_left_rounded, size: 30),
        ),
        title: const Text(
          'Your CV',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final cv = controller.generatedCv.value;
        if (cv == null) {
          return Center(
            child: Text(
              'No CV generated yet.',
              style: TextStyle(color: palette.textSecondary),
            ),
          );
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _CvTemplate(cv: cv),
                ),
              ),
            ),
            _ActionBar(cv: cv),
          ],
        );
      }),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.cv});

  final CvData cv;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _exportPdf(context, share: false),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.textPrimary),
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download PDF'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _exportPdf(context, share: true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Share'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context, {required bool share}) async {
    try {
      final bytes = await buildCvPdf(cv);
      final safeName = cv.fullName.trim().isEmpty
          ? 'cv'
          : cv.fullName.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
      final filename = '${safeName}_cv.pdf';
      if (share) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Share CV'),
            content: const Text(
              'Your CV contains personal information (name, email, phone, photo). '
              'This will be shared via your device\'s share sheet. Continue?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Share'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        await Printing.sharePdf(bytes: bytes, filename: filename);
      } else {
        await Printing.layoutPdf(onLayout: (_) async => bytes, name: filename);
      }
    } on Object {
      Get.snackbar(
        'Export failed',
        'Could not generate the PDF. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

class _CvTemplate extends StatelessWidget {
  const _CvTemplate({required this.cv});

  final CvData cv;

  @override
  Widget build(BuildContext context) {
    switch (cv.templateIndex) {
      case 1:
        return _BalancedTemplate(cv: cv);
      case 2:
        return _ModernTemplate(cv: cv);
      default:
        return _ClassicTemplate(cv: cv);
    }
  }
}

String _contactLine(CvData cv) =>
    [cv.email, cv.phone, cv.location].where((e) => e.isNotEmpty).join('  •  ');

Widget _headshotCircle(CvData cv, double radius, {Color? border}) {
  return Container(
    width: radius * 2,
    height: radius * 2,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFE0E0E0),
      border: border == null ? null : Border.all(color: border, width: 2),
      image: cv.hasHeadshot
          ? DecorationImage(
              image: MemoryImage(cv.headshotBytes!),
              fit: BoxFit.cover,
            )
          : null,
    ),
    child: cv.hasHeadshot
        ? null
        : const Icon(Icons.person, color: Colors.white, size: 28),
  );
}

// ---------------------------------------------------------------------------
// Classic — single column, centered header, teal underlined sections.
// ---------------------------------------------------------------------------
class _ClassicTemplate extends StatelessWidget {
  const _ClassicTemplate({required this.cv});

  final CvData cv;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(cv.templateIndex);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (cv.hasHeadshot) ...[
            _headshotCircle(cv, 40),
            const SizedBox(height: 12),
          ],
          Text(
            cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          if (cv.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                cv.title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _contactLine(cv),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          if (cv.summary.isNotEmpty) ...[
            _ClassicSection(label: 'Profile', accent: accent),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                cv.summary,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (cv.workExperiences.isNotEmpty) ...[
            _ClassicSection(label: 'Experience', accent: accent),
            ...cv.workExperiences.map(
              (w) => _EntryBlock(
                title: w.role,
                subtitle: w.company,
                dates: w.dateRange,
                description: w.description,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (cv.educations.isNotEmpty) ...[
            _ClassicSection(label: 'Education', accent: accent),
            ...cv.educations.map(
              (e) => _EntryBlock(
                title: e.degree,
                subtitle: e.school,
                dates: e.dateRange,
                description: e.description,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (cv.skills.isNotEmpty) ...[
            _ClassicSection(label: 'Skills', accent: accent),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cv.skills
                    .map((s) => _SkillChip(label: s, accent: accent))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ClassicSection extends StatelessWidget {
  const _ClassicSection({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent, width: 1.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Balanced — tinted sidebar (contact + skills) and main content column.
// ---------------------------------------------------------------------------
class _BalancedTemplate extends StatelessWidget {
  const _BalancedTemplate({required this.cv});

  final CvData cv;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(cv.templateIndex);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 130,
            color: const Color(0xFFF1F5FB),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cv.hasHeadshot) ...[
                  Center(child: _headshotCircle(cv, 42, border: accent)),
                  const SizedBox(height: 16),
                ],
                _SidebarHeading(label: 'Contact', accent: accent),
                if (cv.email.isNotEmpty) _SidebarText(cv.email),
                if (cv.phone.isNotEmpty) _SidebarText(cv.phone),
                if (cv.location.isNotEmpty) _SidebarText(cv.location),
                if (cv.skills.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _SidebarHeading(label: 'Skills', accent: accent),
                  ...cv.skills.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 5, right: 6),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  if (cv.title.isNotEmpty)
                    Text(
                      cv.title,
                      style: TextStyle(fontSize: 13, color: accent),
                    ),
                  const SizedBox(height: 16),
                  if (cv.summary.isNotEmpty) ...[
                    _MainHeading(label: 'Profile', accent: accent),
                    Text(
                      cv.summary,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (cv.workExperiences.isNotEmpty) ...[
                    _MainHeading(label: 'Experience', accent: accent),
                    ...cv.workExperiences.map(
                      (w) => _EntryBlock(
                        title: w.role,
                        subtitle: w.company,
                        dates: w.dateRange,
                        description: w.description,
                      ),
                    ),
                  ],
                  if (cv.educations.isNotEmpty) ...[
                    _MainHeading(label: 'Education', accent: accent),
                    ...cv.educations.map(
                      (e) => _EntryBlock(
                        title: e.degree,
                        subtitle: e.school,
                        dates: e.dateRange,
                        description: e.description,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHeading extends StatelessWidget {
  const _SidebarHeading({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

class _SidebarText extends StatelessWidget {
  const _SidebarText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9.5, color: Colors.black87),
      ),
    );
  }
}

class _MainHeading extends StatelessWidget {
  const _MainHeading({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 16, height: 3, color: accent),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modern — full-width dark header band, compact body.
// ---------------------------------------------------------------------------
class _ModernTemplate extends StatelessWidget {
  const _ModernTemplate({required this.cv});

  final CvData cv;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(cv.templateIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: accent,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              if (cv.hasHeadshot) ...[
                _headshotCircle(cv, 36, border: Colors.white),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (cv.title.isNotEmpty)
                      Text(
                        cv.title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      _contactLine(cv),
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cv.summary.isNotEmpty) ...[
                _ModernHeading(label: 'Profile', accent: accent),
                Text(
                  cv.summary,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 14),
              ],
              if (cv.skills.isNotEmpty) ...[
                _ModernHeading(label: 'Skills', accent: accent),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: cv.skills
                      .map((s) => _SkillChip(label: s, accent: accent))
                      .toList(),
                ),
                const SizedBox(height: 14),
              ],
              if (cv.workExperiences.isNotEmpty) ...[
                _ModernHeading(label: 'Experience', accent: accent),
                ...cv.workExperiences.map(
                  (w) => _EntryBlock(
                    title: w.role,
                    subtitle: w.company,
                    dates: w.dateRange,
                    description: w.description,
                  ),
                ),
              ],
              if (cv.educations.isNotEmpty) ...[
                _ModernHeading(label: 'Education', accent: accent),
                ...cv.educations.map(
                  (e) => _EntryBlock(
                    title: e.degree,
                    subtitle: e.school,
                    dates: e.dateRange,
                    description: e.description,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ModernHeading extends StatelessWidget {
  const _ModernHeading({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared entry + chip widgets.
// ---------------------------------------------------------------------------
class _EntryBlock extends StatelessWidget {
  const _EntryBlock({
    required this.title,
    required this.subtitle,
    required this.dates,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String dates;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              if (dates.isNotEmpty)
                Text(
                  dates,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF777777)),
                ),
            ],
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF555555),
              ),
            ),
          if (description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(fontSize: 9.5, color: accent)),
    );
  }
}
