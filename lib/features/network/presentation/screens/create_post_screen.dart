import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) => MockCommunityRepository.instance);

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  String? _topic;
  final _topics = const ['Scholarships', 'Internships', 'Career Advice', 'University', 'Technology', 'Business', 'Biotech', 'Finance'];

  @override void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }
  Future<void> _publish() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty || _topic == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a title, content, and topic.')));
      return;
    }
    await ref.read(communityRepositoryProvider).createPost(title: _title.text.trim(), content: _content.text.trim(), topic: _topic!);
    if (mounted) Navigator.pop(context, true);
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Post')),
    body: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [
      TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
      const SizedBox(height: AppDimensions.p16),
      TextField(controller: _content, maxLines: 6, decoration: const InputDecoration(labelText: 'What would you like to share?')),
      const SizedBox(height: AppDimensions.p16),
      DropdownButtonFormField<String>(initialValue: _topic, decoration: const InputDecoration(labelText: 'Topic'), items: _topics.map((topic) => DropdownMenuItem(value: topic, child: Text(topic))).toList(), onChanged: (value) => setState(() => _topic = value)),
      const SizedBox(height: AppDimensions.p24),
      CustomButton(text: 'Publish', icon: Icons.send_rounded, onPressed: _publish),
    ]),
  );
}