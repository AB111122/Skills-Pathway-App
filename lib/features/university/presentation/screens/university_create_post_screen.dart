import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../network/presentation/screens/create_post_screen.dart';

class UniversityCreatePostScreen extends ConsumerStatefulWidget { const UniversityCreatePostScreen({super.key}); @override ConsumerState<UniversityCreatePostScreen> createState() => _UniversityCreatePostScreenState(); }
class _UniversityCreatePostScreenState extends ConsumerState<UniversityCreatePostScreen> {
  final _title = TextEditingController(); final _content = TextEditingController(); String? _category;
  final _categories = const ['Admissions', 'Scholarships', 'Events', 'Internships', 'Workshops', 'Announcements', 'News'];
  @override void dispose() { _title.dispose(); _content.dispose(); super.dispose(); }
  Future<void> _publish() async { if (_title.text.trim().isEmpty || _content.text.trim().isEmpty || _category == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete title, content, and category.'))); return; } await ref.read(communityRepositoryProvider).createUniversityPost(universityId: 'prof_org_01', universityName: 'National University of Sciences & Technology (NUST)', title: _title.text.trim(), content: _content.text.trim(), topic: _category!); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('University post published'))); Navigator.pop(context, true); } }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create Official Post')), body: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')), const SizedBox(height: 12), TextField(controller: _content, maxLines: 6, decoration: const InputDecoration(labelText: 'Content')), const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(labelText: 'Category'), items: _categories.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(), onChanged: (value) => setState(() => _category = value)), const SizedBox(height: 20), CustomButton(text: 'Publish Post', icon: Icons.publish, onPressed: _publish)]));
}
