import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/comment_model.dart';
import '../../../../models/post_model.dart';
import 'create_post_screen.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final PostModel post;
  const PostDetailsScreen({super.key, required this.post});
  @override ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}
class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _comment = TextEditingController();
  late Future<List<CommentModel>> _comments;
  @override void initState() { super.initState(); _comments = ref.read(communityRepositoryProvider).getComments(widget.post.id); }
  @override void dispose() { _comment.dispose(); super.dispose(); }
  void _reload() => setState(() => _comments = ref.read(communityRepositoryProvider).getComments(widget.post.id));
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Discussion')), body: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [Text(widget.post.topic), const SizedBox(height: 8), Text(widget.post.title, style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12), Text(widget.post.content), const Divider(height: 32), const Text('Comments'), FutureBuilder<List<CommentModel>>(future: _comments, builder: (context, snapshot) { final comments = snapshot.data ?? []; if (comments.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No comments yet')); return Column(children: comments.map((comment) => ListTile(title: Text(comment.authorName), subtitle: Text(comment.content))).toList()); }), Row(children: [Expanded(child: TextField(controller: _comment, decoration: const InputDecoration(hintText: 'Add a comment'))), IconButton(onPressed: () async { if (_comment.text.trim().isEmpty) return; await ref.read(communityRepositoryProvider).addComment(widget.post.id, _comment.text.trim()); _comment.clear(); _reload(); }, icon: const Icon(Icons.send))]) ]));
}
