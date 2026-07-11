import 'package:flutter/material.dart';

import '../../widgets/slide_up_route.dart';
import 'exam_detail_page.dart';
import 'exam_types.dart';

class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: examTypes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final examType = examTypes[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(child: Icon(examType.icon)),
              title: Text(examType.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  SlideUpRoute(
                    builder: (_) => ExamDetailPage(examType: examType),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
