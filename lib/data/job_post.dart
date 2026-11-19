class JobPost {
  final int id;
  final String title;
  final String company;
  final String salaryRange;
  final List<String> techStack;
  final String schedule;
  final String location;
  final String description;
  final List<String> requirements;

  const JobPost({
    required this.id,
    required this.title,
    required this.company,
    required this.salaryRange,
    required this.techStack,
    required this.schedule,
    required this.location,
    required this.description,
    required this.requirements,
  });

  factory JobPost.fromJson(Map<String, dynamic> j) => JobPost(
        id: j['id'] as int,
        title: j['title'] as String,
        company: j['company'] as String,
        salaryRange: j['salaryRange'] as String? ?? '',
        techStack: _stringList(j['techStack']),
        schedule: j['schedule'] as String? ?? '',
        location: j['location'] as String? ?? '',
        description: j['description'] as String? ?? '',
        requirements: _stringList(j['requirements']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'salaryRange': salaryRange,
        'techStack': techStack,
        'schedule': schedule,
        'location': location,
        'description': description,
        'requirements': requirements,
      };

  JobPost copyWith({int? id}) => JobPost(
        id: id ?? this.id,
        title: title,
        company: company,
        salaryRange: salaryRange,
        techStack: techStack,
        schedule: schedule,
        location: location,
        description: description,
        requirements: requirements,
      );
}

List<String> _stringList(Object? value) =>
    (value as List? ?? const []).map((e) => e as String).toList();