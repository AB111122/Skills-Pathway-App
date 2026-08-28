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
  @override ConsumerState<EditUniversityPostScreen> createState() => _EditUniversityPostScreenState();
}
class _EditUniversityPostScreenState extends ConsumerState<EditUniversityPostScreen> {
  late final TextEditingController _title = TextEditingController(text: widget.post.title);
  late final TextEditingController _content = TextEditingController(text: widget.post.content);
  @override void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }
  Future<void> _save() async { if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and content are required.'))); return; } final organizationId = ref.read(authControllerProvider).currentUser?.id; if (organizationId == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first.'))); return; } await ref.read(communityRepositoryProvider).updateUniversityPost(organizationId, widget.post.copyWith(title: _title.text.trim(), content: _content.text.trim(), updatedAt: DateTime.now())); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully'))); Navigator.pop(context, true); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Edit Official Post')), body: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')), const SizedBox(height: 12), TextField(controller: _content, maxLines: 6, decoration: const InputDecoration(labelText: 'Content')), const SizedBox(height: 20), CustomButton(text: 'Save Changes', icon: Icons.save_outlined, onPressed: _save)]));
}
