import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../services/community_repository.dart';
import '../../../../services/firebase_community_repository.dart';

final communityRepositoryProvider = Provider<CommunityRepository>(
  (ref) => Firebase.apps.isEmpty
      ? MockCommunityRepository.instance
      : FirebaseCommunityRepository(),
);

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  bool _isSubmitting = false;
  String? _topic;
  final _topics = const [
    'General',
    'Admissions',
    'Scholarships',
    'Internships',
    'Jobs',
    'Events',
    'Career Advice',
    'University',
    'Technology',
    'Business',
    'Biotech',
    'Finance',
  ];

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    if (_isSubmitting) return;
    if (_title.text.trim().isEmpty ||
        _content.text.trim().isEmpty ||
        _topic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a title, content, and topic.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(communityRepositoryProvider)
          .createPost(
            title: _title.text.trim(),
            content: _content.text.trim(),
            topic: _topic!,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully.')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is StateError
                ? error.message
                : 'Unable to publish your post. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Post')),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.p20),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: AppDimensions.p16),
        TextField(
          controller: _content,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'What would you like to share?',
          ),
        ),
        const SizedBox(height: AppDimensions.p16),
        DropdownButtonFormField<String>(
          initialValue: _topic,
          decoration: const InputDecoration(labelText: 'Topic'),
          items: _topics
              .map(
                (topic) => DropdownMenuItem(value: topic, child: Text(topic)),
              )
              .toList(),
          onChanged: (value) => setState(() => _topic = value),
        ),
        const SizedBox(height: AppDimensions.p24),
        CustomButton(
          text: _isSubmitting ? 'Publishing...' : 'Publish',
          icon: _isSubmitting
              ? Icons.hourglass_top_rounded
              : Icons.send_rounded,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _publish,
        ),
      ],
    ),
  );
}
