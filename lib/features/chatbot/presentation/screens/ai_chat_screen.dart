import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/chat_message_model.dart';
import '../../../../services/ai_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../opportunities/presentation/controllers/opportunity_controller.dart';

final aiServiceProvider = Provider<AiService>((ref) => MockAiService(ref.read(opportunityServiceProvider)));

class AiChatScreen extends ConsumerStatefulWidget {
  final String? starter;
  const AiChatScreen({super.key, this.starter});
  @override ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}
class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <ChatMessageModel>[];
  bool _loading = false;
  final _uuid = const Uuid();
  @override void initState() { super.initState(); if (widget.starter != null) { WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.starter!)); } }
  @override void dispose() { _input.dispose(); _scroll.dispose(); super.dispose(); }
  Future<void> _send(String text) async {
    if (_loading || text.trim().isEmpty) return;
    _input.clear();
    setState(() { _loading = true; _messages.add(ChatMessageModel(id: _uuid.v4(), sender: ChatSender.user, content: text.trim(), timestamp: DateTime.now())); });
    try {
      final reply = await ref.read(aiServiceProvider).sendMessage(text, ref.read(authControllerProvider).studentProfile);
      if (mounted) setState(() { _messages.add(ChatMessageModel(id: _uuid.v4(), sender: ChatSender.assistant, content: reply, timestamp: DateTime.now())); _loading = false; });
    } catch (_) { if (mounted) setState(() { _messages.add(ChatMessageModel(id: _uuid.v4(), sender: ChatSender.assistant, content: 'Something went wrong. Try again.', timestamp: DateTime.now(), status: ChatMessageStatus.failed)); _loading = false; }); }
    WidgetsBinding.instance.addPostFrameCallback((_) { if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut); });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Career Assistant'),
        actions: [IconButton(onPressed: () => setState(_messages.clear), icon: const Icon(Icons.add_comment_outlined))],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Ask me about careers, internships, or scholarships.'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(AppDimensions.p16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.sender == ChatSender.user ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 330),
                          decoration: BoxDecoration(
                            color: message.sender == ChatSender.user ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(message.content, style: TextStyle(color: message.sender == ChatSender.user ? Colors.white : null)),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.p12),
              child: Row(children: [
                Expanded(child: TextField(controller: _input, onSubmitted: _send, decoration: const InputDecoration(hintText: 'Ask a question'))),
                IconButton(onPressed: _loading ? null : () => _send(_input.text), icon: const Icon(Icons.send)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
