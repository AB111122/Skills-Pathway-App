enum ReminderType { oneDay, threeDays, sevenDays }

class AlertModel {
  final String id;
  final String opportunityId;
  final String userId;
  final DateTime deadline;
  final DateTime reminderDate;
  final ReminderType reminderType;
  final bool isEnabled;

  const AlertModel({
    required this.id,
    required this.opportunityId,
    required this.userId,
    required this.deadline,
    required this.reminderDate,
    required this.reminderType,
    this.isEnabled = true,
  });

  AlertModel copyWith({bool? isEnabled}) => AlertModel(
        id: id,
        opportunityId: opportunityId,
        userId: userId,
        deadline: deadline,
        reminderDate: reminderDate,
        reminderType: reminderType,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'opportunityId': opportunityId,
        'userId': userId,
        'deadline': deadline.toIso8601String(),
        'reminderDate': reminderDate.toIso8601String(),
        'reminderType': reminderType.name,
        'isEnabled': isEnabled,
      };

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['id'] as String,
        opportunityId: json['opportunityId'] as String,
        userId: json['userId'] as String,
        deadline: DateTime.parse(json['deadline'] as String),
        reminderDate: DateTime.parse(json['reminderDate'] as String),
        reminderType: ReminderType.values.firstWhere(
          (type) => type.name == json['reminderType'],
          orElse: () => ReminderType.oneDay,
        ),
        isEnabled: json['isEnabled'] as bool? ?? true,
      );
}