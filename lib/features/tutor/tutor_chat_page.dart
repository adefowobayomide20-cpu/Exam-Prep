import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/tutor_message.dart';
import '../../data/tutor_chat_store.dart';

class TutorChatPage extends StatefulWidget {
  const TutorChatPage({super.key});

  @override
  State<TutorChatPage> createState() => _TutorChatPageState();
}

class _TutorChatPageState extends State<TutorChatPage> {
  final _picker = ImagePicker();
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  XFile? _pendingImage;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _mimeTypeFor(XFile file) {
    final name = file.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 70,
    );
    if (file != null) {
      setState(() => _pendingImage = file);
    }
  }

  Future<void> _send() async {
    final image = _pendingImage;
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final question = _textController.text;

    setState(() {
      _pendingImage = null;
      _textController.clear();
    });

    await TutorChatStore.instance.sendPhoto(
      imageBase64: base64Image,
      mimeType: _mimeTypeFor(image),
      question: question,
    );

    if (mounted && _scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Snap & Solve')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: TutorChatStore.instance,
          builder: (context, _) {
            final store = TutorChatStore.instance;
            return Column(
              children: [
                Expanded(
                  child: store.messages.isEmpty
                      ? _EmptyState(theme: theme)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: store.messages.length + (store.sending ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= store.messages.length) {
                              return const _ThinkingBubble();
                            }
                            return _MessageBubble(message: store.messages[index]);
                          },
                        ),
                ),
                if (store.error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      store.error!,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                _Composer(
                  pendingImage: _pendingImage,
                  textController: _textController,
                  sending: store.sending,
                  onPickCamera: () => _pickImage(ImageSource.camera),
                  onPickGallery: () => _pickImage(ImageSource.gallery),
                  onClearImage: () => setState(() => _pendingImage = null),
                  onSend: _send,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Snap a question, get instant help',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo of a question from your textbook or past paper — '
              'the tutor will explain the answer step by step.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final TutorMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStudent = message.sender == TutorSender.student;
    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: isStudent ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imageBytesBase64 != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  base64Decode(message.imageBytesBase64!),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isStudent ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text('Reading and solving…', style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.pendingImage,
    required this.textController,
    required this.sending,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onClearImage,
    required this.onSend,
  });

  final XFile? pendingImage;
  final TextEditingController textController;
  final bool sending;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final VoidCallback onClearImage;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingImage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder<List<int>>(
                      future: pendingImage!.readAsBytes(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(height: 72, width: 72);
                        }
                        return Image.memory(
                          Uint8List.fromList(snapshot.data!),
                          height: 72,
                          width: 72,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      onPressed: onClearImage,
                      tooltip: 'Remove photo',
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                onPressed: sending ? null : onPickCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Take a photo',
              ),
              IconButton(
                onPressed: sending ? null : onPickGallery,
                icon: const Icon(Icons.photo_library_outlined),
                tooltip: 'Choose from gallery',
              ),
              Expanded(
                child: TextField(
                  controller: textController,
                  enabled: !sending,
                  decoration: const InputDecoration(
                    hintText: 'Add a note (optional)',
                    isDense: true,
                  ),
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: (pendingImage != null && !sending) ? onSend : null,
                icon: const Icon(Icons.send),
                tooltip: 'Send',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
