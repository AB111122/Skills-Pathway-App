import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/application_model.dart';
import '../models/opportunity_model.dart';
import '../models/post_model.dart';

class FirestoreSerializers {
  static dynamic timestamp(DateTime value) => Timestamp.fromDate(value);

  static DateTime date(Object? value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  static Map<String, dynamic> opportunityToMap(OpportunityModel item) {
    return {
      ...item.toJson(),
      'deadline': timestamp(item.deadline),
      'createdAt': timestamp(item.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static OpportunityModel opportunityFromMap(
    Map<String, dynamic> source, {
    required String id,
  }) {
    final data = Map<String, dynamic>.from(source);
    data['id'] = id;
    data['deadline'] = date(data['deadline']).toIso8601String();
    data['createdAt'] = date(data['createdAt']).toIso8601String();
    if (data['appliedAt'] != null) {
      data['appliedAt'] = date(data['appliedAt']).toIso8601String();
    }
    return OpportunityModel.fromJson(data);
  }

  static Map<String, dynamic> applicationToMap(ApplicationModel item) {
    return {
      'id': item.id,
      'studentId': item.studentId,
      'studentName': item.studentName,
      'opportunityId': item.opportunityId,
      'opportunityTitle': item.opportunityTitle,
      'organizationId': item.universityId,
      'universityId': item.universityId,
      'organizationName': item.universityName,
      'universityName': item.universityName,
      'status': item.status.name,
      'appliedAt': timestamp(item.applicationDate),
      'updatedAt': timestamp(item.applicationDate),
    };
  }

  static ApplicationModel applicationFromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    return ApplicationModel(
      id: data['id'] as String? ?? id,
      studentId: data['studentId'] as String,
      studentName: data['studentName'] as String? ?? '',
      opportunityId: data['opportunityId'] as String,
      opportunityTitle: data['opportunityTitle'] as String? ?? '',
      universityId:
          data['universityId'] as String? ?? data['organizationId'] as String,
      universityName:
          data['universityName'] as String? ??
          data['organizationName'] as String? ??
          '',
      applicationDate: date(data['appliedAt']),
      status: ApplicationStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => ApplicationStatus.pending,
      ),
    );
  }

  static Map<String, dynamic> postToMap(PostModel item) {
    return {
      'id': item.id,
      'authorId': item.authorId,
      'authorName': item.authorName,
      'authorAvatar': item.authorAvatar,
      'authorRole': item.authorRole,
      'authorType': item.authorType,
      'universityId': item.universityId,
      'title': item.title,
      'content': item.content,
      'topic': item.topic,
      'createdAt': timestamp(item.createdAt),
      'updatedAt': timestamp(item.updatedAt),
      'likesCount': item.likesCount,
      'commentsCount': item.commentsCount,
      'status': item.status.name,
      'reportCount': item.reportCount,
    };
  }

  static PostModel postFromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    return PostModel(
      id: id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      authorAvatar: data['authorAvatar'] as String?,
      authorRole: data['authorRole'] as String? ?? 'Student',
      authorType: data['authorType'] as String? ?? 'student',
      universityId: data['universityId'] as String?,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      topic: data['topic'] as String? ?? 'General',
      createdAt: date(data['createdAt']),
      updatedAt: date(data['updatedAt']),
      likesCount: (data['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (data['commentsCount'] as num?)?.toInt() ?? 0,
      status: PostStatus.values.firstWhere(
        (value) => value.name == data['status'],
        orElse: () => PostStatus.approved,
      ),
      reportCount: (data['reportCount'] as num?)?.toInt() ?? 0,
    );
  }
}
