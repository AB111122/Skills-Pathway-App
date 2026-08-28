import 'package:uuid/uuid.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';

abstract class CommunityRepository {
  Future<List<PostModel>> getPosts({String? topic});
  Future<List<CommentModel>> getComments(String postId);
  Future<PostModel> createPost({required String title, required String content, required String topic});
  Future<PostModel> createUniversityPost({required String universityId, required String universityName, required String title, required String content, required String topic});
  Future<CommentModel> addComment(String postId, String content);
  Future<PostModel> toggleLike(String postId);
  Future<PostModel> toggleFollowAuthor(String postId);
  Future<void> reportPost(String postId, String reason);
  List<PostModel> postsForAuthor(String authorId);
  Future<List<PostModel>> getPostsByAuthor(String authorId);
  Future<PostModel> updateUniversityPost(String universityId, PostModel post);
  Future<void> deleteUniversityPost(String universityId, String postId);
}

class MockCommunityRepository implements CommunityRepository {
  static final MockCommunityRepository instance = MockCommunityRepository._internal();
  MockCommunityRepository() {}
  MockCommunityRepository._internal();
  final List<PostModel> _posts = [
    PostModel(id: 'p1', authorId: 'u1', authorName: 'Ayesha Khan', authorRole: 'Computer Science student', title: 'How did you prepare for scholarship essays?', content: 'I am collecting practical advice for writing a strong personal statement.', topic: 'Scholarships', createdAt: DateTime.now().subtract(const Duration(hours: 2)), updatedAt: DateTime.now().subtract(const Duration(hours: 2)), likesCount: 24, commentsCount: 3),
    PostModel(id: 'p2', authorId: 'u2', authorName: 'Hamza Ali', authorRole: 'Software engineering graduate', title: 'What made your internship application stand out?', content: 'Sharing notes on portfolios, project descriptions, and interview preparation.', topic: 'Internships', createdAt: DateTime.now().subtract(const Duration(days: 1)), updatedAt: DateTime.now().subtract(const Duration(days: 1)), likesCount: 18, commentsCount: 5),
    PostModel(id: 'p3', authorId: 'u3', authorName: 'Sara Malik', authorRole: 'Biotech researcher', title: 'Finding mentors in biotechnology', content: 'Which communities helped you connect with researchers and labs?', topic: 'Biotech', createdAt: DateTime.now().subtract(const Duration(days: 3)), updatedAt: DateTime.now().subtract(const Duration(days: 3)), likesCount: 11),
    PostModel(id: 'p4', authorId: 'u4', authorName: 'Omar Raza', authorRole: 'Business student', title: 'Skills worth learning this semester', content: 'I am choosing between analytics, finance, and product management electives.', topic: 'Career Advice', createdAt: DateTime.now().subtract(const Duration(days: 4)), updatedAt: DateTime.now().subtract(const Duration(days: 4)), likesCount: 31),
  ];
  final Map<String, List<CommentModel>> _comments = {
    'p1': [CommentModel(id: 'c1', postId: 'p1', authorId: 'u5', authorName: 'Nida Ahmed', content: 'Start with one specific moment and connect it to your goals.', createdAt: DateTime.now().subtract(const Duration(hours: 1)))],
  };
  final Uuid _uuid = const Uuid();

  List<PostModel> postsForAuthor(String authorId) => _posts.where((post) => post.authorId == authorId).toList();

  @override
  Future<List<PostModel>> getPostsByAuthor(String authorId) async =>
      postsForAuthor(authorId);

  @override
  Future<List<PostModel>> getPosts({String? topic}) async => _posts.where((post) => post.status == PostStatus.approved && (topic == null || post.topic == topic)).toList();

  @override
  Future<List<CommentModel>> getComments(String postId) async => _comments[postId] ?? [];

  @override
  Future<PostModel> createPost({required String title, required String content, required String topic}) async {
    final post = PostModel(id: _uuid.v4(), authorId: 'local-user', authorName: 'You', authorRole: 'Student', title: title, content: content, topic: topic, createdAt: DateTime.now(), updatedAt: DateTime.now(), status: PostStatus.approved);
    _posts.insert(0, post);
    return post;
  }

  @override
  Future<PostModel> createUniversityPost({required String universityId, required String universityName, required String title, required String content, required String topic}) async {
    final post = PostModel(id: _uuid.v4(), authorId: universityId, universityId: universityId, authorType: 'university', authorName: universityName, authorRole: 'Official University', title: title, content: content, topic: topic, createdAt: DateTime.now(), updatedAt: DateTime.now());
    _posts.insert(0, post);
    return post;
  }

  @override
  Future<CommentModel> addComment(String postId, String content) async {
    final comment = CommentModel(id: _uuid.v4(), postId: postId, authorId: 'local-user', authorName: 'You', content: content, createdAt: DateTime.now());
    (_comments[postId] ??= []).add(comment);
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index >= 0) _posts[index] = _posts[index].copyWith(commentsCount: _comments[postId]!.length);
    return comment;
  }

  @override
  Future<PostModel> toggleLike(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    final post = _posts[index];
    _posts[index] = post.copyWith(isLiked: !post.isLiked, likesCount: post.likesCount + (post.isLiked ? -1 : 1));
    return _posts[index];
  }

  @override
  Future<PostModel> toggleFollowAuthor(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    _posts[index] = _posts[index].copyWith(isFollowingAuthor: !_posts[index].isFollowingAuthor);
    return _posts[index];
  }

  @override
  Future<void> reportPost(String postId, String reason) async {}

  @override
  Future<PostModel> updateUniversityPost(String universityId, PostModel post) async {
    final index = _posts.indexWhere((item) => item.id == post.id);
    if (index < 0 || _posts[index].authorType != 'university' || _posts[index].universityId != universityId) {
      throw StateError('You can only edit your own university posts.');
    }
    _posts[index] = post;
    return post;
  }

  @override
  Future<void> deleteUniversityPost(String universityId, String postId) async {
    final index = _posts.indexWhere((item) => item.id == postId);
    if (index < 0 || _posts[index].authorType != 'university' || _posts[index].universityId != universityId) {
      throw StateError('You can only delete your own university posts.');
    }
    _posts.removeAt(index);
  }
}