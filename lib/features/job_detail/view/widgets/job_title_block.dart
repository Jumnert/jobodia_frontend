import 'package:flutter/material.dart';
import 'package:jobodia_frontend/features/job_detail/model/job_detail_model.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/company_logo.dart';
import 'package:jobodia_frontend/features/job_detail/view/widgets/job_chip.dart';

class JobTitleBlock extends StatelessWidget {
  const JobTitleBlock({required this.job, super.key});

  final JobDetailModel job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Text(
                job.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              JobChip(label: job.workMode, isDark: true),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Posted on ${job.postedDate}',
            style: const TextStyle(color: Color(0xFF999999), fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const CompanyLogo(
                size: 32,
                hasBorder: false,
                hasShadow: false,
                borderRadius: 5,
              ),
              const SizedBox(width: 10),
              Text(
                job.companyName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.tags.map((tag) => JobChip(label: tag)).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
