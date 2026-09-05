import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../network/presentation/screens/create_post_screen.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class UniversityCreatePostScreen extends ConsumerStatefulWidget {
  const UniversityCreatePostScreen({super.key});
  @override
  ConsumerState<UniversityCreatePostScreen> createState() =>
      _UniversityCreatePostScreenState();
}

class _UniversityCreatePostScreenState
    extends ConsumerState<UniversityCreatePostScreen> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  String? _category;
  bool _isSubmitting = false;
  final _categories = const [
    'General',
    'Admissions',
    'Scholarships',
    'Internships',
    'Jobs',
    'Events',
    'Career Advice',
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
        _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete title, content, and category.')),
      );
      return;
    }
    final auth = ref.read(authControllerProvider);
    final organizationId = auth.currentUser?.id;
    final organizationName =
        auth.organizationProfile?.orgName ?? auth.currentUser?.name ?? '';
    if (organizationId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(communityRepositoryProvider)
          .createUniversityPost(
            universityId: organizationId,
            universityName: organizationName,
            title: _title.text.trim(),
            content: _content.text.trim(),
            topic: _category!,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('University post published')),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_friendlyError(error))));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission-denied')) {
      return "You don't have permission to perform this action.";
    }
    if (message.contains('unauthenticated') || message.contains('sign in')) {
      return 'Your session has expired. Please log in again.';
    }
    if (message.contains('network')) {
      return 'Network error. Please check your internet connection.';
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Official Post')),
    body: ListView(
      padding: const EdgeInsets.all(AppDimensions.p20),
      children: [
        TextField(
          controller: _title,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _content,
          maxLines: 6,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: _categories
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) => setState(() => _category = value),
        ),
        const SizedBox(height: 20),
        CustomButton(
          text: _isSubmitting ? 'Publishing...' : 'Publish Post',
          icon: Icons.publish,
          isLoading: _isSubmitting,
          onPressed: _isSubmitting ? null : _publish,
        ),
      ],
    ),
  );
}
