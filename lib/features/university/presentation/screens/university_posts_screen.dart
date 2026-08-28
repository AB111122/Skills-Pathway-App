import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/post_model.dart';
import '../../../network/presentation/screens/create_post_screen.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class UniversityPostsScreen extends ConsumerStatefulWidget {
  const UniversityPostsScreen({super.key});
  @override ConsumerState<UniversityPostsScreen> createState() => _UniversityPostsScreenState();
}

class _UniversityPostsScreenState extends ConsumerState<UniversityPostsScreen> {
  late Future<List<PostModel>> _posts;
  @override void initState() { super.initState(); _reload(); }
  void _reload() { final organizationId = ref.read(authControllerProvider).currentUser?.id ?? ''; _posts = ref.read(communityRepositoryProvider).getPostsByAuthor(organizationId); }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Official Posts')),
    body: FutureBuilder<List<PostModel>>(future: _posts, builder: (context, snapshot) { if (!snapshot.hasData) return const Center(child: CircularProgressIndicator()); final posts = snapshot.data!; final organizationId = ref.read(authControllerProvider).currentUser?.id ?? ''; return ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [
      ElevatedButton.icon(onPressed: () async { await context.push('/university/posts/create'); if (mounted) setState(_reload); }, icon: const Icon(Icons.add), label: const Text('Create Official Post')),
      const SizedBox(height: 16),
      if (posts.isEmpty) const Text('No official posts yet.'),
      ...posts.map((post) => Card(child: ListTile(title: Text(post.title), subtitle: Text('${post.topic} | ${post.likesCount + post.commentsCount} engagement'), trailing: PopupMenuButton<String>(onSelected: (action) async { if (action == 'edit') { await context.push('/university/posts/${post.id}/edit', extra: post); if (mounted) setState(_reload); } if (action == 'delete') { final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete post?'), content: const Text('Are you sure you want to delete this post?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))])); if (confirmed == true) { await ref.read(communityRepositoryProvider).deleteUniversityPost(organizationId, post.id); if (mounted) setState(_reload); } } }, itemBuilder: (_) => const [PopupMenuItem(value: 'view', child: Text('View')), PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))])))),
    ]); }),
  );
}
