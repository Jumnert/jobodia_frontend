import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/custom_text_field.dart';
import 'package:jobodia_frontend/features/career_goals/controller/career_goals_controller.dart';
import 'package:jobodia_frontend/features/career_goals/model/career_models.dart';
import 'package:intl/intl.dart';

class CareerGoalsScreen extends StatefulWidget {
  const CareerGoalsScreen({super.key});

  @override
  State<CareerGoalsScreen> createState() => _CareerGoalsScreenState();
}

class _CareerGoalsScreenState extends State<CareerGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ctrl = Get.put(CareerGoalsController());

    return Scaffold(
      backgroundColor: palette.scaffold,
      appBar: AppBar(
        backgroundColor: palette.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: palette.iconPrimary,
            size: 30,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          'Career Journey',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.brandTeal,
          labelColor: AppColors.brandTeal,
          unselectedLabelColor: palette.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Goals'),
            Tab(text: 'Timeline'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _GoalsTab(ctrl: ctrl, palette: palette),
          _TimelineTab(ctrl: ctrl, palette: palette),
        ],
      ),
      floatingActionButton: Obx(() {
        if (ctrl.goals.isEmpty)
          return const SizedBox.shrink(); // to avoid flutter issue with obs
        return FloatingActionButton.extended(
          onPressed: () => _showAddGoalSheet(context, ctrl),
          backgroundColor: AppColors.brandTeal,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Add Goal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      }),
    );
  }

  void _showAddGoalSheet(BuildContext context, CareerGoalsController ctrl) {
    final titleCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final currentCtrl = TextEditingController();
    String selectedType = 'targetRole';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.palette.scaffold,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final palette = context.palette;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Career Goal',
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                StatefulBuilder(
                  builder: (context, setState) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TypeChip(
                        label: 'Role',
                        value: 'targetRole',
                        groupValue: selectedType,
                        onSelected: (v) => setState(() => selectedType = v),
                      ),
                      _TypeChip(
                        label: 'Salary',
                        value: 'targetSalary',
                        groupValue: selectedType,
                        onSelected: (v) => setState(() => selectedType = v),
                      ),
                      _TypeChip(
                        label: 'Skill',
                        value: 'skillToLearn',
                        groupValue: selectedType,
                        onSelected: (v) => setState(() => selectedType = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Goal Title',
                  hintText: 'e.g., Become a Tech Lead',
                  prefixIcon: Icons.title,
                  controller: titleCtrl,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Current Status',
                        hintText: 'e.g., Senior Dev',
                        prefixIcon: Icons.flag_rounded,
                        controller: currentCtrl,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Target',
                        hintText: 'e.g., Tech Lead',
                        prefixIcon: Icons.track_changes_rounded,
                        controller: targetCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Save Goal',
                  onPressed: () {
                    if (titleCtrl.text.isEmpty || targetCtrl.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please fill in title and target.',
                        backgroundColor: AppColors.error,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    ctrl.addGoal(
                      type: selectedType,
                      title: titleCtrl.text,
                      targetValue: targetCtrl.text,
                      currentValue: currentCtrl.text,
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(value),
      selectedColor: AppColors.brandTeal.withAlpha(30),
      backgroundColor: palette.surface,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.brandTeal : palette.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.brandTeal : palette.border,
      ),
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab({required this.ctrl, required this.palette});
  final CareerGoalsController ctrl;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.goals.isEmpty) {
        return Center(
          child: Text(
            'No goals set yet.',
            style: TextStyle(color: palette.textSecondary),
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(20).copyWith(bottom: 100),
        itemCount: ctrl.goals.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final g = ctrl.goals[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: g.isCompleted
                            ? AppColors.success.withAlpha(20)
                            : AppColors.brandTeal.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        g.isCompleted ? 'COMPLETED' : 'IN PROGRESS',
                        style: TextStyle(
                          color: g.isCompleted
                              ? AppColors.success
                              : AppColors.brandTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!g.isCompleted)
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline_rounded,
                          color: palette.iconMuted,
                        ),
                        onPressed: () => ctrl.completeGoal(g.id),
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  g.title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g.currentValue.isEmpty
                              ? 'Not started'
                              : g.currentValue,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_right_alt_rounded,
                      color: AppColors.brandTeal,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Target',
                          style: TextStyle(
                            color: palette.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g.targetValue,
                          style: TextStyle(
                            color: palette.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.ctrl, required this.palette});
  final CareerGoalsController ctrl;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final milestones = ctrl.milestones;
      if (milestones.isEmpty) {
        return Center(
          child: Text(
            'No milestones yet.',
            style: TextStyle(color: palette.textSecondary),
          ),
        );
      }

      return CustomPaint(
        painter: _TimelinePainter(
          itemCount: milestones.length,
          lineColor: palette.border,
          dotColor: AppColors.brandTeal,
        ),
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final m = milestones[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 48, right: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                m.icon,
                                color: _getColorForCategory(m.category),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  m.title,
                                  style: TextStyle(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat.MMMd().format(m.achievedAt),
                                style: TextStyle(
                                  color: palette.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            m.description,
                            style: TextStyle(
                              color: palette.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20, // startX (24) - dotRadius (4)
                    top: 20,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getColorForCategory(m.category),
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.scaffold, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'application':
        return AppColors.brandTeal;
      case 'interview':
        return AppColors.warning;
      case 'offer':
        return AppColors.success;
      case 'certification':
        return const Color(0xFF8B5CF6); // purple
      default:
        return AppColors.info;
    }
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.itemCount,
    required this.lineColor,
    required this.dotColor,
  });
  final int itemCount;
  final Color lineColor;
  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    const startX = 24.0;

    // Draw vertical line
    canvas.drawLine(
      const Offset(startX, 0),
      Offset(startX, size.height),
      linePaint,
    );

    // Draw dots (approximate positions for mock, real timeline would need sliver/layout data)
    // We're drawing the line behind the list, but we can't easily sync the dots to list items
    // precisely in a pure CustomPainter without layout info.
    // Instead, a better approach for Timeline is a widget-based approach or CustomPaint per item.
    // I will let the list view handle its layout and we just draw the line.
    // For simplicity, we just draw the continuous line here. The dots will be drawn in the items if needed.
    // Wait, the prompt says "vertical timeline with connected dots and cards. Each milestone is a dot on the left... Use CustomPainter for the connecting line."
    // It's easier to just use CustomPainter for the connecting line and place a Container for the dot in the widget tree.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
