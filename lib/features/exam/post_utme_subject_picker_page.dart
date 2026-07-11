import 'dart:math';

import 'package:flutter/material.dart';

import '../../widgets/slide_up_route.dart';
import 'exam_detail_page.dart' show showTimeLimitNotice;
import 'exam_types.dart';
import 'post_jamb_schools.dart';
import 'quiz/question_bank/post_utme_school_subject_banks.dart';
import 'quiz/question_bank/question_bank_registry.dart';
import 'quiz/quiz_question.dart';
import 'quiz/quiz_session_page.dart';
import 'subjects.dart';

const _compulsorySubject = 'English Language';
const _electiveCount = 3;
const _questionsPerSubject = 10;
const _testDuration = Duration(minutes: 15);

/// Post-UTME subjects a student can pick from beyond English Language: the
/// same elective pool JAMB uses. General Knowledge is deliberately excluded
/// across every school on this picker (UI, OAU, UNIBEN, UNN, FUTA,
/// LAUTECH) — none of their actual screenings test it.
List<String> get _postUtmeElectives =>
    jambSubjects.where((subject) => subject != 'Use of English').toList();

/// Post-UTME (schools other than UNILAG/UNILORIN): English Language is
/// compulsory, then the student picks 3 more subjects — the same subjects
/// they'd have chosen for JAMB — before starting a single combined, timed
/// test. English, Mathematics, and General Knowledge are drawn from the
/// school's own curated bank; every other elective falls back to JAMB's
/// shared subject bank.
class PostUtmeSubjectPickerPage extends StatefulWidget {
  const PostUtmeSubjectPickerPage({super.key, required this.school, required this.subjectBank});

  final PostJambSchool school;
  final PostUtmeSchoolSubjectBank subjectBank;

  @override
  State<PostUtmeSubjectPickerPage> createState() => _PostUtmeSubjectPickerPageState();
}

class _PostUtmeSubjectPickerPageState extends State<PostUtmeSubjectPickerPage> {
  final Set<String> _selectedElectives = {};

  List<QuizQuestion> _sample(List<QuizQuestion> pool, int count) {
    final shuffled = List.of(pool)..shuffle(Random());
    return shuffled.take(count).toList();
  }

  List<QuizQuestion> _questionsFor(String subject) {
    switch (subject) {
      case 'English Language':
        return _sample(widget.subjectBank.englishLanguage(), _questionsPerSubject);
      case 'Mathematics':
        return _sample(widget.subjectBank.mathematics(), _questionsPerSubject);
      case 'General Knowledge':
        return _sample(widget.subjectBank.generalKnowledge(), _questionsPerSubject);
      default:
        final elective = widget.subjectBank.electives[subject];
        if (elective != null) {
          return _sample(elective(), _questionsPerSubject);
        }
        return questionsForSubject(
          subject,
          sampleSize: _questionsPerSubject,
          examCategory: ExamCategory.jamb,
        );
    }
  }

  Future<void> _startTest() async {
    final confirmed = await showTimeLimitNotice(
      context,
      subjectLabel: 'all 4 subjects',
      duration: _testDuration,
    );
    if (!confirmed || !mounted) return;

    final subjects = [_compulsorySubject, ..._selectedElectives];
    final questions = subjects.expand(_questionsFor).toList();

    Navigator.of(context).push(
      SlideUpRoute(
        builder: (_) => QuizSessionPage(
          title: 'Post-UTME · ${widget.school.shortName}',
          questions: questions,
          duration: _testDuration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final electives = _postUtmeElectives;
    final canStart = _selectedElectives.length == _electiveCount;

    return Scaffold(
      appBar: AppBar(title: Text('Post-UTME · ${widget.school.shortName}')),
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
                Text('Choose $_electiveCount more subjects', style: theme.textTheme.titleMedium),
                Text(
                  '${_selectedElectives.length}/$_electiveCount',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: electives.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = electives[index];
                final selected = _selectedElectives.contains(subject);
                final disabled = !selected && _selectedElectives.length >= _electiveCount;
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
