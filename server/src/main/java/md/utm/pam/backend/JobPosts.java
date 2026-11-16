// JobPosts: каталог вакансий JobBoard (по образцу Notes.java).
//
// В отличие от notes, вакансии — ОБЩИЙ каталог: любой вошедший студент видит
// все вакансии. Менять и удалять вакансию может только её автор (created_by);
// стартовые вакансии автора не имеют, поэтому для всех доступны только на чтение.
// Чужая вакансия при PUT/DELETE неотличима от несуществующей (404), как в notes.

package md.utm.pam.backend;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/job-posts")
public class JobPosts {

	private static final ObjectMapper JSON = new ObjectMapper();

	private final Db db;

	JobPosts(Db db) {
		this.db = db;
		seedIfEmpty();
	}

	// ---- JSON <-> строки БД ------------------------------------------------

	/** Списки (techStack, requirements) лежат в БД как JSON-текст. */
	private static String listToText(List<String> list) {
		try {
			return JSON.writeValueAsString(list);
		} catch (JsonProcessingException e) {
			throw new IllegalStateException(e);
		}
	}

	private static List<String> textToList(Object text) {
		try {
			return JSON.readValue(String.valueOf(text), new TypeReference<List<String>>() {
			});
		} catch (JsonProcessingException e) {
			return List.of(); // повреждённая ячейка не должна ронять весь список
		}
	}

	/** Строка БД -> JSON контракта. */
	private static Map<String, Object> toJson(Map<String, Object> row) {
		var json = new LinkedHashMap<String, Object>();
		json.put("id", row.get("id"));
		json.put("title", row.get("title"));
		json.put("company", row.get("company"));
		json.put("salaryRange", row.get("salary_range"));
		json.put("techStack", textToList(row.get("tech_stack")));
		json.put("schedule", row.get("schedule"));
		json.put("location", row.get("location"));
		json.put("description", row.get("description"));
		json.put("requirements", textToList(row.get("requirements")));
		json.put("createdAt", row.get("created_at"));
		return json;
	}

	// ---- валидация тела ----------------------------------------------------

	/** Необязательная строка: нет в теле -> "". */
	private static String optionalString(Map<String, Object> body, String key) {
		return body.get(key) instanceof String s ? s.trim() : "";
	}

	/** Необязательный массив строк: нет в теле -> []; не массив строк -> 400. */
	private static List<String> stringList(Map<String, Object> body, String key) {
		Object value = body.get(key);
		if (value == null) return List.of();
		if (!(value instanceof List<?> items)) {
			throw Errors.validation(key + " must be an array of strings");
		}
		var result = new ArrayList<String>();
		for (Object item : items) {
			if (!(item instanceof String s)) {
				throw Errors.validation(key + " must be an array of strings");
			}
			if (!s.isBlank()) result.add(s.trim());
		}
		return result;
	}

	// ---- поиск записи -------------------------------------------------------

	/** Любая вакансия каталога (чтение). */
	private Map<String, Object> find(long id) {
		var rows = db.jdbc.queryForList("SELECT * FROM job_posts WHERE id = ?", id);
		if (rows.isEmpty()) throw Errors.notFound("Job post not found");
		return rows.get(0);
	}

	/** Только вакансия, созданная этим пользователем (изменение/удаление). */
	private void requireOwner(long userId, long id) {
		var rows = db.jdbc.queryForList(
				"SELECT id FROM job_posts WHERE id = ? AND created_by = ?", id, userId);
		if (rows.isEmpty()) throw Errors.notFound("Job post not found");
	}

	// ---- маршруты ------------------------------------------------------------

	/** GET /job-posts?page=1&limit=20&search=  -> {items, page, limit, total} */
	@GetMapping
	public Map<String, Object> list(
			@RequestParam(defaultValue = "") String page,
			@RequestParam(defaultValue = "") String limit,
			@RequestParam(defaultValue = "") String search) {
		int pageN = Math.max(parseIntOr(page, 1), 1);
		int limitN = Math.min(Math.max(parseIntOr(limit, 20), 1), 100);

		String where = "(title LIKE ? OR company LIKE ? OR description LIKE ? OR tech_stack LIKE ? OR location LIKE ?)";
		String like = "%" + search + "%";

		int total = db.jdbc.queryForObject(
				"SELECT COUNT(*) FROM job_posts WHERE " + where,
				Integer.class, like, like, like, like, like);
		List<Map<String, Object>> rows = db.jdbc.queryForList(
				"SELECT * FROM job_posts WHERE " + where + " ORDER BY id ASC LIMIT ? OFFSET ?",
				like, like, like, like, like, limitN, (pageN - 1) * limitN);

		return Map.of(
				"items", rows.stream().map(JobPosts::toJson).toList(),
				"page", pageN,
				"limit", limitN,
				"total", total);
	}

	/** POST /job-posts -> 201 вакансия (id даёт сервер) */
	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public Map<String, Object> create(@RequestAttribute("userId") long userId,
			@RequestBody Map<String, Object> body) {
		String title = Errors.stringField(body, "title");
		if (title == null) throw Errors.validation("title is required");
		String company = Errors.stringField(body, "company");
		if (company == null) throw Errors.validation("company is required");

		long id = db.insert(
				"INSERT INTO job_posts (created_by, title, company, salary_range, tech_stack, "
						+ "schedule, location, description, requirements, created_at) "
						+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
				userId, title, company, optionalString(body, "salaryRange"),
				listToText(stringList(body, "techStack")),
				optionalString(body, "schedule"), optionalString(body, "location"),
				optionalString(body, "description"),
				listToText(stringList(body, "requirements")), Db.nowIso());
		return toJson(find(id));
	}

	/** GET /job-posts/{id} -> 200 вакансия | 404 */
	@GetMapping("/{id}")
	public Map<String, Object> get(@PathVariable long id) {
		return toJson(find(id));
	}

	/** PUT /job-posts/{id} -> 200 обновлённая вакансия | 404 (в т.ч. чужая) */
	@PutMapping("/{id}")
	public Map<String, Object> update(@RequestAttribute("userId") long userId,
			@PathVariable long id, @RequestBody Map<String, Object> body) {
		requireOwner(userId, id);
		String title = Errors.stringField(body, "title");
		if (title == null) throw Errors.validation("title is required");
		String company = Errors.stringField(body, "company");
		if (company == null) throw Errors.validation("company is required");

		db.jdbc.update(
				"UPDATE job_posts SET title = ?, company = ?, salary_range = ?, tech_stack = ?, "
						+ "schedule = ?, location = ?, description = ?, requirements = ? WHERE id = ?",
				title, company, optionalString(body, "salaryRange"),
				listToText(stringList(body, "techStack")),
				optionalString(body, "schedule"), optionalString(body, "location"),
				optionalString(body, "description"),
				listToText(stringList(body, "requirements")), id);
		return toJson(find(id));
	}

	/** DELETE /job-posts/{id} -> 204 | 404. Отклики на неё удаляются вместе с ней. */
	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@RequestAttribute("userId") long userId, @PathVariable long id) {
		requireOwner(userId, id);
		db.jdbc.update("DELETE FROM applications WHERE job_post_id = ?", id);
		db.jdbc.update("DELETE FROM job_posts WHERE id = ?", id);
	}

	/** Query-параметры приходят текстом; мусор -> значение по умолчанию. */
	private static int parseIntOr(String value, int fallback) {
		try {
			return Integer.parseInt(value);
		} catch (NumberFormatException e) {
			return fallback;
		}
	}

	// ---- стартовые вакансии ---------------------------------------------------

	/** При первом запуске каталог не пуст: восемь вакансий, без автора (read-only). */
	private void seedIfEmpty() {
		Integer count = db.jdbc.queryForObject("SELECT COUNT(*) FROM job_posts", Integer.class);
		if (count != null && count > 0) return;

		seed("Junior Flutter Developer", "Nordsoft", "8 000 – 12 000 MDL",
				List.of("Flutter", "Dart", "Git", "REST API"), "Part-time", "Кишинёв, гибрид",
				"Разработка мобильного приложения для клиентов финтех-сервиса вместе с командой из трёх разработчиков. Работа над экранами, состоянием и интеграцией с backend-ом.",
				List.of("Знание Dart и основ Flutter", "Умение работать с Git", "Базовое понимание REST API", "Готовность работать 20 часов в неделю"));
		seed("QA Intern", "Tekwill", "4 000 – 6 000 MDL",
				List.of("QA", "Postman", "SQL", "Jira"), "Стажировка", "Кишинёв",
				"Стажировка в команде тестирования: написание тест-кейсов, ручное тестирование веб-приложения, оформление багов в Jira.",
				List.of("Понимание основ тестирования", "Внимательность к деталям", "Базовый SQL", "Английский на уровне чтения документации"));
		seed("Java Backend Developer", "Amber", "10 000 – 15 000 MDL",
				List.of("Java", "Spring Boot", "SQL", "Git"), "Part-time", "Remote",
				"Разработка REST API на Spring Boot для внутренней платформы: проектирование таблиц, эндпоинты, авторизация, покрытие тестами.",
				List.of("Java 17 и основы Spring Boot", "SQL и работа с реляционными БД", "Понимание HTTP и REST", "Опыт учебных проектов приветствуется"));
		seed("React Developer", "Pixel Forge", "9 000 – 13 000 MDL",
				List.of("React", "TypeScript", "HTML", "CSS"), "Part-time", "Remote",
				"Разработка интерфейсов для веб-приложений студии: компоненты, формы, работа с API, адаптивная вёрстка.",
				List.of("React и TypeScript на уровне проектов", "Уверенные HTML и CSS", "Работа с Git", "Портфолио или репозиторий на GitHub"));
		seed("Python Data Analyst Intern", "Datavia", "5 000 – 7 000 MDL",
				List.of("Python", "Pandas", "SQL"), "Стажировка", "Кишинёв",
				"Стажировка в аналитической команде: подготовка и очистка данных, отчёты и графики, автоматизация рутинных расчётов на Python.",
				List.of("Python и библиотека Pandas", "SQL на базовом уровне", "Интерес к анализу данных", "Аккуратность в расчётах"));
		seed("Junior DevOps Engineer", "CloudNest", "9 000 – 12 000 MDL",
				List.of("DevOps", "Docker", "Linux", "CI/CD"), "Part-time", "Кишинёв, гибрид",
				"Поддержка сборок и развёртываний: настройка CI/CD, контейнеризация сервисов в Docker, мониторинг и работа с Linux-серверами.",
				List.of("Уверенная работа в командной строке Linux", "Основы Docker", "Понимание CI/CD", "Скриптовый язык: Bash или Python"));
		seed("Android Kotlin Developer", "Mobiline", "9 000 – 14 000 MDL",
				List.of("Kotlin", "Android", "Git"), "Part-time", "Remote",
				"Развитие Android-приложения оператора связи: новые экраны, исправление ошибок, работа с сетевым слоем и локальным хранилищем.",
				List.of("Kotlin и основы Android SDK", "Понимание жизненного цикла Activity", "Git", "Готовность учиться в команде"));
		seed("UI/UX Designer", "Studio Kreativ", "6 000 – 9 000 MDL",
				List.of("Figma", "UI/UX", "Prototyping"), "Part-time", "Кишинёв",
				"Проектирование интерфейсов мобильных приложений: исследования, прототипы в Figma, дизайн-система и передача макетов разработчикам.",
				List.of("Figma на уверенном уровне", "Основы UX-исследований", "Портфолио с учебными или реальными проектами", "Умение принимать обратную связь"));
	}

	private void seed(String title, String company, String salaryRange, List<String> techStack,
			String schedule, String location, String description, List<String> requirements) {
		db.insert(
				"INSERT INTO job_posts (created_by, title, company, salary_range, tech_stack, "
						+ "schedule, location, description, requirements, created_at) "
						+ "VALUES (NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
				title, company, salaryRange, listToText(techStack), schedule, location,
				description, listToText(requirements), Db.nowIso());
	}
}
