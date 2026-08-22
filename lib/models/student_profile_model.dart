/// Comprehensive Profile Model for Student / Young Adult users in Pakistan.
class StudentProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String educationLevel; // e.g. Undergraduate, Master's, High School
  final String degree; // e.g. BS Computer Science, BBA
  final String fieldOfStudy; // e.g. Computer Science, Finance, Biotechnology
  final String universityOrCollege; // e.g. NUST, FAST, LUMS, UET
  final double? gpa;
  final int? graduationYear;
  final List<String> skills;
  final List<String> careerInterests;
  final String city; // e.g. Islamabad, Lahore, Karachi
  final String? resumeUrl;
  final double completionPercentage; // 0.0 to 1.0

  const StudentProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.educationLevel,
    required this.degree,
    required this.fieldOfStudy,
    required this.universityOrCollege,
    this.gpa,
    this.graduationYear,
    required this.skills,
    required this.careerInterests,
    required this.city,
    this.resumeUrl,
    this.completionPercentage = 0.7,
  });

  StudentProfileModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? educationLevel,
    String? degree,
    String? fieldOfStudy,
    String? universityOrCollege,
    double? gpa,
    int? graduationYear,
    List<String>? skills,
    List<String>? careerInterests,
    String? city,
    String? resumeUrl,
    double? completionPercentage,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      educationLevel: educationLevel ?? this.educationLevel,
      degree: degree ?? this.degree,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      universityOrCollege: universityOrCollege ?? this.universityOrCollege,
      gpa: gpa ?? this.gpa,
      graduationYear: graduationYear ?? this.graduationYear,
      skills: skills ?? this.skills,
      careerInterests: careerInterests ?? this.careerInterests,
      city: city ?? this.city,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'educationLevel': educationLevel,
      'degree': degree,
      'fieldOfStudy': fieldOfStudy,
      'universityOrCollege': universityOrCollege,
      'gpa': gpa,
      'graduationYear': graduationYear,
      'skills': skills,
      'careerInterests': careerInterests,
      'city': city,
      'resumeUrl': resumeUrl,
      'completionPercentage': completionPercentage,
    };
  }

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      educationLevel: json['educationLevel'] as String,
      degree: json['degree'] as String,
      fieldOfStudy: json['fieldOfStudy'] as String,
      universityOrCollege: json['universityOrCollege'] as String,
      gpa: (json['gpa'] as num?)?.toDouble(),
      graduationYear: json['graduationYear'] as int?,
      skills: List<String>.from(json['skills'] ?? []),
      careerInterests: List<String>.from(json['careerInterests'] ?? []),
      city: json['city'] as String? ?? 'Pakistan',
      resumeUrl: json['resumeUrl'] as String?,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.7,
    );
  }
}
