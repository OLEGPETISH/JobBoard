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
}

enum ApplicationStatus { sent, viewed, interview, rejected }

class JobApplication {
  final int id;
  final int jobPostId;
  final String message;
  final String sentDate;
  final ApplicationStatus status;

  const JobApplication({
    required this.id,
    required this.jobPostId,
    required this.message,
    required this.sentDate,
    required this.status,
  });
}

const List<JobPost> mockJobs = [
  JobPost(
    id: 1,
    title: 'Junior Flutter Developer',
    company: 'Nordsoft Moldova',
    salaryRange: '9 000–13 000 MDL',
    techStack: ['Flutter', 'Dart', 'Firebase'],
    schedule: 'Part-time, 20 ч/нед',
    location: 'Кишинёв / гибрид',
    description: 'Разработка мобильного приложения для клиента из сферы логистики в команде из пяти человек.',
    requirements: ['Знание Dart и основ Flutter', 'Умение работать с Git', 'Английский от B1'],
  ),
  JobPost(
    id: 2,
    title: 'Стажёр-тестировщик (QA Intern)',
    company: 'Tekwill Partners',
    salaryRange: '6 000–8 000 MDL',
    techStack: ['Postman', 'Jira', 'SQL'],
    schedule: 'Стажировка, 3 месяца',
    location: 'Кишинёв',
    description: 'Ручное тестирование веб-приложений, написание тест-кейсов и баг-репортов.',
    requirements: ['Понимание жизненного цикла тестирования', 'Базовый SQL', 'Внимательность'],
  ),
  JobPost(
    id: 3,
    title: 'Java Backend Developer (Part-time)',
    company: 'Amber Systems',
    salaryRange: '14 000–20 000 MDL',
    techStack: ['Java', 'Spring Boot', 'PostgreSQL'],
    schedule: 'Part-time, 25 ч/нед',
    location: 'Remote',
    description: 'Поддержка REST API для финансовой платформы, написание модульных тестов, code review.',
    requirements: ['Java 17+', 'Spring Boot', 'Опыт работы с PostgreSQL', 'Понимание REST'],
  ),
  JobPost(
    id: 4,
    title: 'Frontend Developer (React)',
    company: 'Pixel Forge Studio',
    salaryRange: '12 000–18 000 MDL',
    techStack: ['React', 'TypeScript', 'Tailwind'],
    schedule: 'Part-time, гибкий график',
    location: 'Remote',
    description: 'Верстка и разработка интерфейсов для e-commerce проектов, работа по макетам из Figma.',
    requirements: ['React и TypeScript', 'Адаптивная верстка', 'Опыт работы с Figma'],
  ),
  JobPost(
    id: 5,
    title: 'Python Data Analyst Intern',
    company: 'Datavia Analytics',
    salaryRange: '7 000–9 500 MDL',
    techStack: ['Python', 'Pandas', 'Power BI'],
    schedule: 'Стажировка, 4 месяца',
    location: 'Кишинёв / гибрид',
    description: 'Подготовка отчетов и дашбордов, очистка данных, помощь аналитикам в исследованиях.',
    requirements: ['Python и Pandas', 'Основы статистики', 'Готовность учиться'],
  ),
  JobPost(
    id: 6,
    title: 'Junior DevOps Engineer',
    company: 'CloudNest',
    salaryRange: '15 000–22 000 MDL',
    techStack: ['Docker', 'Linux', 'GitLab CI'],
    schedule: 'Part-time, 20 ч/нед',
    location: 'Remote',
    description: 'Настройка CI/CD пайплайнов, контейнеризация сервисов, мониторинг инфраструктуры.',
    requirements: ['Уверенный Linux', 'Docker', 'Понимание CI/CD'],
  ),
  JobPost(
    id: 7,
    title: 'Android Developer (Kotlin)',
    company: 'Mobiline Group',
    salaryRange: '13 000–19 000 MDL',
    techStack: ['Kotlin', 'Jetpack Compose', 'Room'],
    schedule: 'Part-time, 20 ч/нед',
    location: 'Кишинёв',
    description: 'Разработка новых экранов в банковском приложении и исправление ошибок.',
    requirements: ['Kotlin', 'Знакомство с Jetpack Compose', 'Архитектура MVVM'],
  ),
  JobPost(
    id: 8,
    title: 'Junior UI/UX Designer',
    company: 'Studio Kreativ',
    salaryRange: '8 000–11 000 MDL',
    techStack: ['Figma', 'Design Systems'],
    schedule: 'Part-time, гибкий график',
    location: 'Remote',
    description: 'Проектирование интерфейсов мобильных приложений, прототипы и пользовательские сценарии.',
    requirements: ['Figma', 'Портфолио с 2–3 проектами', 'Понимание принципов Material Design'],
  ),
];

const List<JobApplication> mockApplications = [
  JobApplication(id: 1, jobPostId: 1, message: 'Здравствуйте! Изучаю Flutter, есть учебный проект с Firebase.', sentDate: '28 сент.', status: ApplicationStatus.interview),
  JobApplication(id: 2, jobPostId: 3, message: 'Прошёл курс по Spring Boot, готов работать 25 часов в неделю.', sentDate: '26 сент.', status: ApplicationStatus.viewed),
  JobApplication(id: 3, jobPostId: 2, message: 'Прохожу курс по тестированию ПО, хочу применить знания на практике.', sentDate: '25 сент.', status: ApplicationStatus.sent),
  JobApplication(id: 4, jobPostId: 6, message: 'Настраивал Docker-контейнеры в лабораторных работах в университете.', sentDate: '22 сент.', status: ApplicationStatus.rejected),
  JobApplication(id: 5, jobPostId: 5, message: 'Есть опыт анализа данных на Python в курсовой работе.', sentDate: '20 сент.', status: ApplicationStatus.viewed),
  JobApplication(id: 6, jobPostId: 8, message: 'Прикладываю ссылку на портфолио в Figma.', sentDate: '18 сент.', status: ApplicationStatus.sent),
];