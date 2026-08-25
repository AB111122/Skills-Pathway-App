import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/post_model.dart';
import '../../../network/presentation/screens/create_post_screen.dart';

class UniversityPostsScreen extends ConsumerStatefulWidget {
  const UniversityPostsScreen({super.key});
  @override ConsumerState<UniversityPostsScreen> createState() => _UniversityPostsScreenState();
}

class _UniversityPostsScreenState extends ConsumerState<UniversityPostsScreen> {
  List<PostModel> get posts => (ref.read(communityRepositoryProvider).postsForAuthor('prof_org_01'));
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Official Posts')),
    body: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [
      ElevatedButton.icon(onPressed: () async { await context.push('/university/posts/create'); setState(() {}); }, icon: const Icon(Icons.add), label: const Text('Create Official Post')),
      const SizedBox(height: 16),
      if (posts.isEmpty) const Text('No official posts yet.'),
      ...posts.map((post) => Card(child: ListTile(title: Text(post.title), subtitle: Text('${post.topic} | ${post.likesCount + post.commentsCount} engagement'), trailing: PopupMenuButton<String>(onSelected: (action) async { if (action == 'edit') { await context.push('/university/posts/${post.id}/edit', extra: post); setState(() {}); } if (action == 'delete') { final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete post?'), content: const Text('Are you sure you want to delete this post?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])); if (confirmed == true) { await ref.read(communityRepositoryProvider).deleteUniversityPost('prof_org_01', post.id); setState(() {}); } } }, itemBuilder: (_) => const [PopupMenuItem(value: 'view', child: Text('View')), PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))])))),
    ]),
  );
}
