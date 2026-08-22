enum OpportunityType {
  scholarship,
  internship,
}

enum OpportunityStatus {
  draft,
  submitted,
  underReview,
  verificationPending,
  verified,
  published,
  rejected,
}

/// Rich Opportunity Model for Verified Scholarships and Internships.
class OpportunityModel {
  final String id;
  final String title;
  final String organizationName;
  final String? organizationLogo;
  final OpportunityType type;
  final String location; // e.g. "Islamabad, PK", "Lahore, PK", "Remote", "London, UK"
  final DateTime deadline;
  final bool isVerified; // Crucial: Only true if explicitly verified
  final bool isPaid; // For internships
  final String stipendOrFunding; // e.g. "PKR 50,000 / month", "100% Tuition Fee", "Fully Funded"
  final String shortDescription;
  final String fullDescription;
  final String officialUrl; // Official website application link for One-Tap Apply
  final List<String> requiredSkills;
  final List<String> eligibleFields;
  final String? degreeLevel; // Undergraduate, Master's, PhD, Fresh Grad, High School
  final String? duration; // e.g. "3 Months", "4 Years", "8 Weeks"
  final List<String> requiredDocuments;
  final List<String> eligibilityCriteria;
  final List<String> benefits;
  final bool isSaved;
  final bool isApplied;
  final DateTime? appliedAt;
  final bool hasDeadlineReminder;
  final DateTime createdAt;

  const OpportunityModel({
    required this.id,
    required this.title,
    required this.organizationName,
    this.organizationLogo,
    required this.type,
    required this.location,
    required this.deadline,
    required this.isVerified,
    this.isPaid = false,
    required this.stipendOrFunding,
    required this.shortDescription,
    required this.fullDescription,
    required this.officialUrl,
    required this.requiredSkills,
    required this.eligibleFields,
    this.degreeLevel,
    this.duration,
    this.requiredDocuments = const [],
    this.eligibilityCriteria = const [],
    this.benefits = const [],
    this.isSaved = false,
    this.isApplied = false,
    this.appliedAt,
    this.hasDeadlineReminder = false,
    required this.createdAt,
  });

  bool get isScholarship => type == OpportunityType.scholarship;
  bool get isInternship => type == OpportunityType.internship;

  OpportunityModel copyWith({
    String? id,
    String? title,
    String? organizationName,
    String? organizationLogo,
    OpportunityType? type,
    String? location,
    DateTime? deadline,
    bool? isVerified,
    bool? isPaid,
    String? stipendOrFunding,
    String? shortDescription,
    String? fullDescription,
    String? officialUrl,
    List<String>? requiredSkills,
    List<String>? eligibleFields,
    String? degreeLevel,
    String? duration,
    List<String>? requiredDocuments,
    List<String>? eligibilityCriteria,
    List<String>? benefits,
    bool? isSaved,
    bool? isApplied,
    DateTime? appliedAt,
    bool? hasDeadlineReminder,
    DateTime? createdAt,
  }) {
    return OpportunityModel(
      id: id ?? this.id,
      title: title ?? this.title,
      organizationName: organizationName ?? this.organizationName,
      organizationLogo: organizationLogo ?? this.organizationLogo,
      type: type ?? this.type,
      location: location ?? this.location,
      deadline: deadline ?? this.deadline,
      isVerified: isVerified ?? this.isVerified,
      isPaid: isPaid ?? this.isPaid,
      stipendOrFunding: stipendOrFunding ?? this.stipendOrFunding,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      officialUrl: officialUrl ?? this.officialUrl,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      eligibleFields: eligibleFields ?? this.eligibleFields,
      degreeLevel: degreeLevel ?? this.degreeLevel,
      duration: duration ?? this.duration,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      eligibilityCriteria: eligibilityCriteria ?? this.eligibilityCriteria,
      benefits: benefits ?? this.benefits,
      isSaved: isSaved ?? this.isSaved,
      isApplied: isApplied ?? this.isApplied,
      appliedAt: appliedAt ?? this.appliedAt,
      hasDeadlineReminder: hasDeadlineReminder ?? this.hasDeadlineReminder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'organizationName': organizationName,
      'organizationLogo': organizationLogo,
      'type': type.name,
      'location': location,
      'deadline': deadline.toIso8601String(),
      'isVerified': isVerified,
      'isPaid': isPaid,
      'stipendOrFunding': stipendOrFunding,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'officialUrl': officialUrl,
      'requiredSkills': requiredSkills,
      'eligibleFields': eligibleFields,
      'degreeLevel': degreeLevel,
      'duration': duration,
      'requiredDocuments': requiredDocuments,
      'eligibilityCriteria': eligibilityCriteria,
      'benefits': benefits,
      'isSaved': isSaved,
      'isApplied': isApplied,
      'appliedAt': appliedAt?.toIso8601String(),
      'hasDeadlineReminder': hasDeadlineReminder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OpportunityModel.fromJson(Map<String, dynamic> json) {
    return OpportunityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      organizationName: json['organizationName'] as String,
      organizationLogo: json['organizationLogo'] as String?,
      type: json['type'] == 'internship'
          ? OpportunityType.internship
          : OpportunityType.scholarship,
      location: json['location'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      isPaid: json['isPaid'] as bool? ?? false,
      stipendOrFunding: json['stipendOrFunding'] as String,
      shortDescription: json['shortDescription'] as String,
      fullDescription: json['fullDescription'] as String,
      officialUrl: json['officialUrl'] as String,
      requiredSkills: List<String>.from(json['requiredSkills'] ?? []),
      eligibleFields: List<String>.from(json['eligibleFields'] ?? []),
      degreeLevel: json['degreeLevel'] as String?,
      duration: json['duration'] as String?,
      requiredDocuments: List<String>.from(json['requiredDocuments'] ?? []),
      eligibilityCriteria:
          List<String>.from(json['eligibilityCriteria'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      isSaved: json['isSaved'] as bool? ?? false,
      isApplied: json['isApplied'] as bool? ?? false,
      appliedAt: json['appliedAt'] != null
          ? DateTime.parse(json['appliedAt'] as String)
          : null,
      hasDeadlineReminder: json['hasDeadlineReminder'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
