import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../models/post_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import 'create_post_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<PostModel>> _posts;
  late final TabController _tabController;
  String? _topic;
  int _tab = 0;
  final _topics = const [
    'General',
    'Admissions',
    'All topics',
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
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    _posts = ref.read(communityRepositoryProvider).getPosts(topic: _topic);
  }

  void _refresh() {
    setState(() {
      _load();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        'Professional Network',
        style: AppTextStyles.titleLarge(context),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final created = await context.push<bool>('/network/create');
            if (created == true) _refresh();
          },
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    ),
    body: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppDimensions.p16),
          child: Row(
            children: _topics
                .map(
                  (topic) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(topic),
                      selected:
                          (_topic == null && topic == 'All topics') ||
                          _topic == topic,
                      onSelected: (_) {
                        setState(() {
                          _topic = topic == 'All topics' ? null : topic;
                          _load();
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hot'),
            Tab(text: 'New'),
            Tab(text: 'Following'),
          ],
          onTap: (index) => setState(() => _tab = index),
        ),
        Expanded(
          child: FutureBuilder<List<PostModel>>(
            future: _posts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Could not load posts.'));
              }
              var posts = snapshot.data ?? [];
              if (_tab == 1) {
                posts = [...posts]
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              }
              if (_tab == 2) {
                posts = posts.where((post) => post.isFollowingAuthor).toList();
              }
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    _tab == 2
                        ? "You aren't following anyone yet."
                        : 'No posts yet',
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  _refresh();
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.p16),
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _PostCard(post: posts[index], onChanged: _refresh),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _PostCard extends ConsumerWidget {
  final PostModel post;
  final VoidCallback onChanged;
  const _PostCard({required this.post, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authControllerProvider).currentUser?.id ?? '';
    final canDelete =
        post.authorId == userId ||
        (post.authorType == 'university' && post.universityId == userId);

    return Card(
      child: InkWell(
        onTap: () async {
          await context.push('/network/post/${post.id}', extra: post);
          onChanged();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(post.authorName.substring(0, 1))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: AppTextStyles.labelLarge(context),
                        ),
                        Text(
                          post.authorRole,
                          style: AppTextStyles.bodySmall(context),
                        ),
                        if (post.authorType == 'university')
                          Text(
                            'Official University Post',
                            style: AppTextStyles.bodySmall(
                              context,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(communityRepositoryProvider)
                          .toggleFollowAuthor(post.id);
                      onChanged();
                    },
                    child: Text(
                      post.isFollowingAuthor ? 'Following' : 'Follow',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: AppTextStyles.titleMedium(context),
                    ),
                  ),
                  Chip(label: Text(post.topic)),
                ],
              ),
              const SizedBox(height: 6),
              Text(post.content, maxLines: 3, overflow: TextOverflow.ellipsis),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      await ref
                          .read(communityRepositoryProvider)
                          .toggleLike(post.id);
                      onChanged();
                    },
                    icon: Icon(
                      post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    ),
                  ),
                  Text('${post.likesCount}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.comment_outlined, size: 20),
                  const SizedBox(width: 4),
                  Text('${post.commentsCount}'),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'report') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report submitted')),
                        );
                        return;
                      }

                      if (value == 'delete' && canDelete) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete this post?'),
                            content: const Text(
                              'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await ref
                                .read(communityRepositoryProvider)
                                .deletePost(userId, post.id);
                            onChanged();
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error is StateError
                                        ? error.message
                                        : 'Unable to delete this post.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Text('Report'),
                      ),
                      if (canDelete)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
