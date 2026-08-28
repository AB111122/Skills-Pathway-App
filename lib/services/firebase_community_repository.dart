import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../models/comment_model.dart';
import '../models/post_model.dart';
import 'community_repository.dart';
import 'firestore_serializers.dart';

class FirebaseCommunityRepository implements CommunityRepository {
  FirebaseCommunityRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  @override
  Future<List<PostModel>> getPosts({String? topic}) async {
    final snapshot = await _posts.get();
    final items = snapshot.docs
        .map(_fromPost)
        .where((post) => post.status == PostStatus.approved)
        .where((post) => topic == null || post.topic == topic)
        .toList();
    return _withUserState(items);
  }

  @override
  Future<List<CommentModel>> getComments(String postId) async {
    final snapshot = await _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .get();
    return snapshot.docs.map(_fromComment).toList();
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String content,
    required String topic,
  }) async {
    final user = _requireUser();
    final profile = await _profile(user.uid);
    final reference = _posts.doc();
    final now = FieldValue.serverTimestamp();
    await reference.set({
      'id': reference.id,
      'authorId': user.uid,
      'authorName': profile['name'] as String? ?? user.displayName ?? '',
      'authorRole': 'Student',
      'authorType': 'student',
      'title': title,
      'content': content,
      'topic': topic,
      'createdAt': now,
      'updatedAt': now,
      'likesCount': 0,
      'commentsCount': 0,
      'status': PostStatus.approved.name,
      'reportCount': 0,
    });
    return _fromSnapshot(await reference.get());
  }

  @override
  Future<PostModel> createUniversityPost({
    required String universityId,
    required String universityName,
    required String title,
    required String content,
    required String topic,
  }) async {
    final user = _requireUser();
    if (user.uid != universityId) {
      throw StateError('You can only create posts for your own organization.');
    }
    final reference = _posts.doc();
    final now = FieldValue.serverTimestamp();
    await reference.set({
      'id': reference.id,
      'authorId': user.uid,
      'universityId': user.uid,
      'authorName': universityName,
      'authorRole': 'Official University',
      'authorType': 'university',
      'title': title,
      'content': content,
      'topic': topic,
      'isOfficial': true,
      'createdAt': now,
      'updatedAt': now,
      'likesCount': 0,
      'commentsCount': 0,
      'status': PostStatus.approved.name,
      'reportCount': 0,
    });
    return _fromSnapshot(await reference.get());
  }

  @override
  Future<CommentModel> addComment(String postId, String content) async {
    final user = _requireUser();
    final profile = await _profile(user.uid);
    final reference = _firestore.collection('comments').doc(_uuid.v4());
    final now = FieldValue.serverTimestamp();
    await reference.set({
      'id': reference.id,
      'postId': postId,
      'authorId': user.uid,
      'authorName': profile['name'] as String? ?? user.displayName ?? '',
      'content': content,
      'createdAt': now,
      'status': CommentStatus.approved.name,
    });
    await _posts.doc(postId).update({'commentsCount': FieldValue.increment(1)});
    return _fromComment(await reference.get());
  }

  @override
  Future<PostModel> toggleLike(String postId) async {
    final user = _requireUser();
    final post = _posts.doc(postId);
    final like = post.collection('likes').doc(user.uid);
    final liked = await like.get();
    if (liked.exists) {
      await like.delete();
      await post.update({'likesCount': FieldValue.increment(-1)});
    } else {
      await like.set({
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await post.update({'likesCount': FieldValue.increment(1)});
    }
    return _fromSnapshot(await post.get());
  }

  @override
  Future<PostModel> toggleFollowAuthor(String postId) async {
    final user = _requireUser();
    final post = _fromSnapshot(await _posts.doc(postId).get());
    final follow = _firestore
        .collection('follows')
        .doc('${user.uid}_${post.authorId}');
    final following = await follow.get();
    if (following.exists) {
      await follow.delete();
    } else {
      await follow.set({
        'followerId': user.uid,
        'authorId': post.authorId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return post.copyWith(isFollowingAuthor: !following.exists);
  }

  @override
  Future<void> reportPost(String postId, String reason) async {
    _requireUser();
    await _posts.doc(postId).update({'reportCount': FieldValue.increment(1)});
  }

  @override
  List<PostModel> postsForAuthor(String authorId) => const [];

  @override
  Future<List<PostModel>> getPostsByAuthor(String authorId) async {
    _requireUser();
    final snapshot = await _posts.where('authorId', isEqualTo: authorId).get();
    return snapshot.docs.map(_fromPost).toList();
  }

  @override
  Future<PostModel> updateUniversityPost(
    String universityId,
    PostModel post,
  ) async {
    final user = _requireUser();
    if (user.uid != universityId ||
        post.authorId != universityId ||
        post.authorType != 'university') {
      throw StateError('You can only edit your own university posts.');
    }
    await _posts.doc(post.id).update({
      'title': post.title,
      'content': post.content,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return _fromSnapshot(await _posts.doc(post.id).get());
  }

  @override
  Future<void> deleteUniversityPost(String universityId, String postId) async {
    final user = _requireUser();
    final post = _fromSnapshot(await _posts.doc(postId).get());
    if (user.uid != universityId ||
        post.authorId != universityId ||
        post.authorType != 'university') {
      throw StateError('You can only delete your own university posts.');
    }
    await _posts.doc(postId).delete();
  }

  User _requireUser() =>
      _auth.currentUser ?? (throw StateError('Please sign in first.'));

  Future<Map<String, dynamic>> _profile(String uid) async =>
      (await _firestore.collection('users').doc(uid).get()).data() ?? {};

  Future<List<PostModel>> _withUserState(List<PostModel> items) async {
    final user = _auth.currentUser;
    if (user == null) return items;
    final result = <PostModel>[];
    for (final post in items) {
      final liked = await _posts
          .doc(post.id)
          .collection('likes')
          .doc(user.uid)
          .get();
      final followed = await _firestore
          .collection('follows')
          .doc('${user.uid}_${post.authorId}')
          .get();
      result.add(
        post.copyWith(
          isLiked: liked.exists,
          isFollowingAuthor: followed.exists,
        ),
      );
    }
    return result;
  }

  PostModel _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) =>
      _fromPost(snapshot);

  PostModel _fromPost(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return FirestoreSerializers.postFromMap(
      snapshot.data() ?? {},
      id: snapshot.id,
    );
  }

  CommentModel _fromComment(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return CommentModel(
      id: snapshot.id,
      postId: data['postId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _date(data['createdAt']) ?? DateTime.now(),
      status: CommentStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => CommentStatus.approved,
      ),
    );
  }

  DateTime? _date(Object? value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : value is String
      ? DateTime.tryParse(value)
      : null;
}
