import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/theory_service.dart';

String _describeError(Object error) {
  if (error is FirebaseFunctionsException) {
    return error.message ?? 'Something went wrong (${error.code}). Try again shortly.';
  }
  return "Couldn't reach the server. Check your connection and try again.";
}

enum _Stage { loadingQuestion, answering, grading, result, error }

/// WAEC Theory mode for a single subject: shows one theory question (from
/// a ready-made bank when available, otherwise AI-generated on demand),
/// lets the student answer by typing or by photographing their handwritten
/// working, then shows detailed feedback — a full step-by-step, "teach a
/// child" explanation when the answer is wrong.
class TheorySessionPage extends StatefulWidget {
  const TheorySessionPage({super.key, required this.subject});

  final String subject;

  @override
  State<TheorySessionPage> createState() => _TheorySessionPageState();
}

class _TheorySessionPageState extends State<TheorySessionPage> {
  final _picker = ImagePicker();
  final _answerController = TextEditingController();

  _Stage _stage = _Stage.loadingQuestion;
  String? _question;
  XFile? _pendingImage;
  TheoryGradeResult? _result;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _stage = _Stage.loadingQuestion;
      _errorMessage = null;
    });
    try {
      final question = await TheoryService.instance.generateQuestion(widget.subject);
      if (!mounted) return;
      setState(() {
        _question = question;
        _stage = _Stage.answering;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _describeError(e);
        _stage = _Stage.error;
      });
    }
  }

  String _mimeTypeFor(XFile file) {
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source, maxWidth: 1280, imageQuality: 70);
    if (file != null) setState(() => _pendingImage = file);
  }

  Future<void> _submit() async {
    final question = _question;
    if (question == null) return;
    final answerText = _answerController.text.trim();
    final image = _pendingImage;
    if (answerText.isEmpty && image == null) return;

    setState(() => _stage = _Stage.grading);
    try {
      String? imageBase64;
      String? mimeType;
      if (image != null) {
        imageBase64 = base64Encode(await image.readAsBytes());
        mimeType = _mimeTypeFor(image);
      }

      final result = await TheoryService.instance.gradeAnswer(
        subject: widget.subject,
        question: question,
        answerText: answerText.isEmpty ? null : answerText,
        answerImageBase64: imageBase64,
        mimeType: mimeType,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _stage = _Stage.result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _describeError(e);
        _stage = _Stage.error;
      });
    }
  }

  void _tryAnotherQuestion() {
    setState(() {
      _answerController.clear();
      _pendingImage = null;
      _result = null;
      _question = null;
    });
    _loadQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.subject} · Theory')),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_stage) {
      case _Stage.loadingQuestion:
        return const Center(child: CircularProgressIndicator());
      case _Stage.error:
        return _ErrorView(message: _errorMessage!, onRetry: _loadQuestion);
      case _Stage.answering:
      case _Stage.grading:
        return _AnsweringView(
          question: _question!,
          answerController: _answerController,
          pendingImage: _pendingImage,
          grading: _stage == _Stage.grading,
          onPickCamera: () => _pickImage(ImageSource.camera),
          onPickGallery: () => _pickImage(ImageSource.gallery),
          onClearImage: () => setState(() => _pendingImage = null),
          onSubmit: _submit,
        );
      case _Stage.result:
        return _ResultView(
          question: _question!,
          result: _result!,
          onNextQuestion: _tryAnotherQuestion,
        );
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

class _AnsweringView extends StatelessWidget {
  const _AnsweringView({
    required this.question,
    required this.answerController,
    required this.pendingImage,
    required this.grading,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onClearImage,
    required this.onSubmit,
  });

  final String question;
  final TextEditingController answerController;
  final XFile? pendingImage;
  final bool grading;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onClearImage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 8),
                      Text(question, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Type your answer', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              TextField(
                controller: answerController,
                enabled: !grading,
                minLines: 3,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Write your answer or working here…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text('Or snap a photo of your working', style: theme.textTheme.titleSmall)),
                ],
              ),
              const SizedBox(height: 8),
              if (pendingImage != null)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FutureBuilder<List<int>>(
                        future: pendingImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(height: 160);
                          return Image.memory(
                            Uint8List.fromList(snapshot.data!),
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: IconButton.filledTonal(
                        icon: const Icon(Icons.close),
                        onPressed: grading ? null : onClearImage,
                        tooltip: 'Remove photo',
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: grading ? null : onPickCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Camera'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: grading ? null : onPickGallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ],
                ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: grading ? null : onSubmit,
            child: grading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Answer'),
          ),
        ),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.question, required this.result, required this.onNextQuestion});

  final String question;
  final TheoryGradeResult result;
  final VoidCallback onNextQuestion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = result.correct ? Colors.green : theme.colorScheme.error;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(result.correct ? Icons.check_circle : Icons.cancel, color: color, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    result.correct ? 'Well done!' : "Let's go through it",
                    style: theme.textTheme.titleLarge?.copyWith(color: color),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Question', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 8),
                      Text(question, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explanation', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
                      const SizedBox(height: 8),
                      Text(result.feedback, style: theme.textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: FilledButton(
            onPressed: onNextQuestion,
            child: const Text('Try Another Question'),
          ),
        ),
      ],
    );
  }
}
