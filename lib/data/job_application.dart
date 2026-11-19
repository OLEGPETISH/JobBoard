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
        factory JobApplication.fromJson(Map<String, dynamic> j) {
    final status = ApplicationStatus.values.asNameMap()[j['status'] as String];
    if (status == null) throw const FormatException('unknown status');
    return JobApplication(
      id: j['id'] as int,
      jobPostId: j['jobPostId'] as int,
      cvUrl: j['cvUrl'] as String,
      message: j['message'] as String,
      sentDate: _sentDate(j['createdAt'] as String), // ISO сервера -> «16 ноября»
      status: status,
    );
  }

  /// Тело POST/PUT. Статус при создании сервер игнорирует (всегда "sent").
  Map<String, dynamic> toJson() => {
        'jobPostId': jobPostId,
        'cvUrl': cvUrl,
        'message': message,
        'status': status.name,
      };
}
const _months = [
  'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
  'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
];

String _sentDate(String iso) {
  final d = DateTime.parse(iso).toLocal(); // FormatException, если не дата
  return '${d.day} ${_months[d.month - 1]}';
}