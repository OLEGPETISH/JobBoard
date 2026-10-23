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