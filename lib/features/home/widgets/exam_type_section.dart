import 'package:flutter/material.dart';

import '../../../widgets/slide_up_route.dart';
import '../../exam/exam_detail_page.dart';
import '../../exam/exam_types.dart';

class ExamTypeSection extends StatelessWidget {
  const ExamTypeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exam Type', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: examTypes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final examType = examTypes[index];
              return _ExamTypeChip(examType: examType);
            },
          ),
        ),
      ],
    );
  }
}

class _ExamTypeChip extends StatelessWidget {
  const _ExamTypeChip({required this.examType});

  final ExamTypeInfo examType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          SlideUpRoute(
            builder: (_) => ExamDetailPage(examType: examType),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(examType.icon, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(height: 8),
            Text(
              examType.shortLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
