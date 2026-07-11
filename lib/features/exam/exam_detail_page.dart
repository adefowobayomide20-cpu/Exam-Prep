import 'package:flutter/material.dart';

import '../../widgets/slide_up_route.dart';
import 'exam_types.dart';
import 'post_jamb_school_detail_page.dart';
import 'post_jamb_schools.dart';
import 'quiz/question_bank/question_bank_registry.dart';
import 'quiz/quiz_session_page.dart';
import 'subjects.dart';
import 'theory/theory_session_page.dart';

enum _WaecTestMode { objective, theory }

/// Only WAEC offers a Theory mode choice; NECO keeps its existing
/// straight-into-the-objective-test flow untouched. Returns null if the
/// student backs out of the dialog.
Future<_WaecTestMode?> _chooseWaecTestMode(BuildContext context) {
  return showDialog<_WaecTestMode>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.quiz_outlined),
      title: const Text('Choose Test Type'),
      content: const Text('Would you like to practice with objective (multiple choice) or theory questions?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(_WaecTestMode.theory),
          child: const Text('Theory'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(_WaecTestMode.objective),
          child: const Text('Objective'),
        ),
      ],
    ),
  );
}

const _waecNecoTestDuration = Duration(minutes: 15);
const _jambTestDuration = Duration(minutes: 60);
const _jambElectiveCount = 3;
const _questionsPerSubject = 20;

/// Tells the student how long they have before the timed test begins.
/// Returns true if they chose to start, false if they backed out.
Future<bool> showTimeLimitNotice(
  BuildContext context, {
  required String subjectLabel,
  required Duration duration,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.timer_outlined),
      title: const Text('Time Limit'),
      content: Text(
        'You have ${duration.inMinutes} minutes to answer the questions for $subjectLabel.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Start Test'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

class ExamDetailPage extends StatelessWidget {
  const ExamDetailPage({super.key, required this.examType});

  final ExamTypeInfo examType;

  @override
  Widget build(BuildContext context) {
    switch (examType.category) {
      case ExamCategory.waec:
      case ExamCategory.neco:
        return _SubjectTestListPage(examType: examType);
      case ExamCategory.jamb:
        return _JambSubjectPickerPage(examType: examType);
      case ExamCategory.postJamb:
        return _PostJambSchoolListPage(examType: examType);
    }
  }
}

/// WAEC / NECO: search and pick a subject, go straight into a timed question test.
class _SubjectTestListPage extends StatefulWidget {
  const _SubjectTestListPage({required this.examType});

  final ExamTypeInfo examType;

  @override
  State<_SubjectTestListPage> createState() => _SubjectTestListPageState();
}

class _SubjectTestListPageState extends State<_SubjectTestListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startWaecNecoTest(BuildContext context, String subject) async {
    // Only WAEC offers Theory mode; NECO keeps the existing objective-only
    // flow (and its timing) exactly as it was.
    var mode = _WaecTestMode.objective;
    if (widget.examType.category == ExamCategory.waec) {
      final chosen = await _chooseWaecTestMode(context);
      if (chosen == null || !context.mounted) return;
      mode = chosen;
    }

    if (mode == _WaecTestMode.theory) {
      Navigator.of(context).push(
        SlideUpRoute(builder: (_) => TheorySessionPage(subject: subject)),
      );
      return;
    }

    final confirmed = await showTimeLimitNotice(
      context,
      subjectLabel: subject,
      duration: _waecNecoTestDuration,
    );
    if (confirmed && context.mounted) {
      Navigator.of(context).push(
        SlideUpRoute(
          builder: (_) => QuizSessionPage(
            title: '${widget.examType.shortLabel} · $subject',
            questions: questionsForSubject(
              subject,
              sampleSize: _questionsPerSubject,
              examCategory: widget.examType.category,
            ),
            duration: _waecNecoTestDuration,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = waecNecoSubjects
        .where((subject) => subject.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.examType.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search subjects',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _query = '';
                        }),
                      ),
              ),
            ),
          ),
          Expanded(
            child: filteredSubjects.isEmpty
                ? Center(
                    child: Text(
                      'No subjects match "$_query"',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredSubjects.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final subject = filteredSubjects[index];
                      return Card(
                        child: ListTile(
                          title: Text(subject),
                          trailing: FilledButton.tonal(
                            onPressed: () => _startWaecNecoTest(context, subject),
                            child: const Text('Take Test'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// JAMB: Use of English is compulsory, then pick 3 more subjects before
/// starting a single combined, timed test.
class _JambSubjectPickerPage extends StatefulWidget {
  const _JambSubjectPickerPage({required this.examType});

  final ExamTypeInfo examType;

  @override
  State<_JambSubjectPickerPage> createState() => _JambSubjectPickerPageState();
}

class _JambSubjectPickerPageState extends State<_JambSubjectPickerPage> {
  static const _compulsorySubject = 'Use of English';
  final Set<String> _selectedElectives = {};

  List<String> get _electives => jambSubjects.where((s) => s != _compulsorySubject).toList();

  Future<void> _startTest() async {
    final confirmed = await showTimeLimitNotice(
      context,
      subjectLabel: 'all 4 subjects',
      duration: _jambTestDuration,
    );
    if (!confirmed || !mounted) return;

    final subjects = [_compulsorySubject, ..._selectedElectives];
    final questions = subjects
        .expand((subject) => questionsForSubject(
              subject,
              sampleSize: _questionsPerSubject,
              examCategory: widget.examType.category,
            ))
        .toList();

    Navigator.of(context).push(
      SlideUpRoute(
        builder: (_) => QuizSessionPage(
          title: widget.examType.name,
          questions: questions,
          duration: _jambTestDuration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canStart = _selectedElectives.length == _jambElectiveCount;

    return Scaffold(
      appBar: AppBar(title: Text(widget.examType.name)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                title: const Text(_compulsorySubject),
                subtitle: const Text('Compulsory'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Choose $_jambElectiveCount more subjects', style: theme.textTheme.titleMedium),
                Text(
                  '${_selectedElectives.length}/$_jambElectiveCount',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _electives.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = _electives[index];
                final selected = _selectedElectives.contains(subject);
                final disabled = !selected && _selectedElectives.length >= _jambElectiveCount;
                return Card(
                  child: CheckboxListTile(
                    value: selected,
                    title: Text(subject),
                    onChanged: disabled
                        ? null
                        : (value) => setState(() {
                              if (value == true) {
                                _selectedElectives.add(subject);
                              } else {
                                _selectedElectives.remove(subject);
                              }
                            }),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilledButton(
              onPressed: canStart ? _startTest : null,
              child: const Text('Start Test'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Post-JAMB: pick the institution to see its screening requirements.
class _PostJambSchoolListPage extends StatelessWidget {
  const _PostJambSchoolListPage({required this.examType});

  final ExamTypeInfo examType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(examType.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: postJambSchools.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final school = postJambSchools[index];
          return Card(
            child: ListTile(
              leading: Icon(Icons.school_outlined, color: theme.colorScheme.primary),
              title: Text(school.name),
              subtitle: Text(school.shortName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  SlideUpRoute(builder: (_) => PostJambSchoolDetailPage(school: school)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
