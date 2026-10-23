enum ApplicationStatus { sent, viewed, interview, rejected }

class JobApplication {
  final int id;
  final int jobPostId;
  final String cvUrl; 
  final String message;
  final String sentDate;
  final ApplicationStatus status;

  const JobApplication({
    required this.id,
    required this.jobPostId,
    required this.cvUrl,
    required this.message,
    required this.sentDate,
    required this.status,
  });

  JobApplication copyWith({
    int? id,
    String? sentDate,
    ApplicationStatus? status,
  }) =>
      JobApplication(
        id: id ?? this.id,
        jobPostId: jobPostId,
        cvUrl: cvUrl,
        message: message,
        sentDate: sentDate ?? this.sentDate,
        status: status ?? this.status,
      );
}