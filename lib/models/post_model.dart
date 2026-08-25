enum PostStatus { pending, approved, rejected }

class PostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String authorRole;
  final String authorType;
  final String? universityId;
  final String title;
  final String content;
  final String topic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isFollowingAuthor;
  final PostStatus status;
  final int reportCount;

  const PostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.authorRole,
    this.authorType = 'student',
    this.universityId,
    required this.title,
    required this.content,
    required this.topic,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isFollowingAuthor = false,
    this.status = PostStatus.approved,
    this.reportCount = 0,
  });

  PostModel copyWith({
    String? title,
    String? content,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isFollowingAuthor,
    PostStatus? status,
    int? reportCount,
    DateTime? updatedAt,
  }) => PostModel(
        id: id,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        authorRole: authorRole,
        authorType: authorType,
        universityId: universityId,
        title: title ?? this.title,
        content: content ?? this.content,
        topic: topic,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        likesCount: likesCount ?? this.likesCount,
        commentsCount: commentsCount ?? this.commentsCount,
        isLiked: isLiked ?? this.isLiked,
        isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
        status: status ?? this.status,
        reportCount: reportCount ?? this.reportCount,
      );
}