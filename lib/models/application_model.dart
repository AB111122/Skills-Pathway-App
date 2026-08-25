enum ApplicationStatus { pending, reviewed, shortlisted, rejected }

class ApplicationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String opportunityId;
  final String opportunityTitle;
  final String universityId;
  final String universityName;
  final DateTime applicationDate;
  final ApplicationStatus status;

  const ApplicationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.universityId,
    required this.universityName,
    required this.applicationDate,
    this.status = ApplicationStatus.pending,
  });

  ApplicationModel copyWith({ApplicationStatus? status}) => ApplicationModel(
        id: id,
        studentId: studentId,
        studentName: studentName,
        opportunityId: opportunityId,
        opportunityTitle: opportunityTitle,
        universityId: universityId,
        universityName: universityName,
        applicationDate: applicationDate,
        status: status ?? this.status,
      );
}