import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../models/post_model.dart';
import '../../../network/presentation/screens/create_post_screen.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class EditUniversityPostScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const EditUniversityPostScreen({super.key, required this.post});

  @override
  ConsumerState<EditUniversityPostScreen> createState() =>
      _EditUniversityPostScreenState();
}

class _EditUniversityPostScreenState
    extends ConsumerState<EditUniversityPostScreen> {
  late final TextEditingController _title =
      TextEditingController(text: widget.post.title);
  late final TextEditingController _content =
      TextEditingController(text: widget.post.content);
  bool _isSaving = false;

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required.')),
      );
      return;
    }
    final organizationId = ref.read(authControllerProvider).currentUser?.id;
    if (organizationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(communityRepositoryProvider).updateUniversityPost(
            organizationId,
            widget.post.copyWith(
              title: _title.text.trim(),
              content: _content.text.trim(),
              updatedAt: DateTime.now(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is StateError ? error.message : 'Unable to update post.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Edit Official Post')),
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
            const SizedBox(height: 20),
            CustomButton(
              text: _isSaving ? 'Saving...' : 'Save Changes',
              icon: Icons.save_outlined,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _save,
            ),
          ],
        ),
      );
}
