// Applications: отклики студента на вакансии (по образцу Notes.java).
//
// Отклики принадлежат пользователю: студент видит только свои, чужой отклик
// неотличим от несуществующего (404). Статус ставит сервер: при создании это
// "sent"; значения совпадают с enum ApplicationStatus в приложении.

package md.utm.pam.backend;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

@RestController
@RequestMapping("/applications")
public class Applications {

	private static final Set<String> STATUSES = Set.of("sent", "viewed", "interview", "rejected");

	private final Db db;

	Applications(Db db) {
		this.db = db;
	}

	/** Строка БД -> JSON контракта. */
	private static Map<String, Object> toJson(Map<String, Object> row) {
		var json = new LinkedHashMap<String, Object>();
		json.put("id", row.get("id"));
		json.put("jobPostId", row.get("job_post_id"));
		json.put("cvUrl", row.get("cv_url"));
		json.put("message", row.get("message"));
		json.put("status", row.get("status"));
		json.put("createdAt", row.get("created_at"));
		return json;
	}

	/** Отклик только среди откликов текущего пользователя (чужой = 404). */
	private Map<String, Object> find(long userId, long id) {
		var rows = db.jdbc.queryForList(
				"SELECT * FROM applications WHERE id = ? AND user_id = ?", id, userId);
		if (rows.isEmpty()) throw Errors.notFound("Application not found");
		return rows.get(0);
	}

	/** jobPostId обязан быть числом и указывать на существующую вакансию. */
	private long requireJobPostId(Map<String, Object> body) {
		if (!(body.get("jobPostId") instanceof Number n)
				|| n.doubleValue() != n.longValue()) {
			throw Errors.validation("jobPostId is required");
		}
		long jobPostId = n.longValue();
		Integer exists = db.jdbc.queryForObject(
				"SELECT COUNT(*) FROM job_posts WHERE id = ?", Integer.class, jobPostId);
		if (exists == null || exists == 0) {
			throw Errors.validation("jobPostId must reference an existing job post");
		}
		return jobPostId;
	}

	/** GET /applications?page=1&limit=20&search=  -> {items, page, limit, total} */
	@GetMapping
	public Map<String, Object> list(@RequestAttribute("userId") long userId,
			@RequestParam(defaultValue = "") String page,
			@RequestParam(defaultValue = "") String limit,
			@RequestParam(defaultValue = "") String search) {
		int pageN = Math.max(parseIntOr(page, 1), 1);
		int limitN = Math.min(Math.max(parseIntOr(limit, 20), 1), 100);

		String where = "user_id = ? AND (message LIKE ? OR cv_url LIKE ?)";
		String like = "%" + search + "%";

		int total = db.jdbc.queryForObject(
				"SELECT COUNT(*) FROM applications WHERE " + where,
				Integer.class, userId, like, like);
		List<Map<String, Object>> rows = db.jdbc.queryForList(
				"SELECT * FROM applications WHERE " + where
						+ " ORDER BY id DESC LIMIT ? OFFSET ?",
				userId, like, like, limitN, (pageN - 1) * limitN);

		return Map.of(
				"items", rows.stream().map(Applications::toJson).toList(),
				"page", pageN,
				"limit", limitN,
				"total", total);
	}

	/** POST /applications {jobPostId, cvUrl, message} -> 201 отклик, status = "sent" */
	@PostMapping
	@ResponseStatus(HttpStatus.CREATED)
	public Map<String, Object> create(@RequestAttribute("userId") long userId,
			@RequestBody Map<String, Object> body) {
		long jobPostId = requireJobPostId(body);
		String cvUrl = Errors.stringField(body, "cvUrl");
		if (cvUrl == null) throw Errors.validation("cvUrl is required");
		String message = Errors.stringField(body, "message");
		if (message == null) throw Errors.validation("message is required");

		long id = db.insert(
				"INSERT INTO applications (user_id, job_post_id, cv_url, message, status, created_at) "
						+ "VALUES (?, ?, ?, ?, 'sent', ?)",
				userId, jobPostId, cvUrl, message, Db.nowIso());
		return toJson(find(userId, id));
	}

	/** GET /applications/{id} -> 200 отклик | 404 */
	@GetMapping("/{id}")
	public Map<String, Object> get(@RequestAttribute("userId") long userId,
			@PathVariable long id) {
		return toJson(find(userId, id));
	}

	/**
	 * PUT /applications/{id} {cvUrl, message, status?} -> 200 | 404.
	 * jobPostId не меняется; status необязателен (нет в теле — остаётся прежним).
	 */
	@PutMapping("/{id}")
	public Map<String, Object> update(@RequestAttribute("userId") long userId,
			@PathVariable long id, @RequestBody Map<String, Object> body) {
		var current = find(userId, id); // 404 раньше любой валидации
		String cvUrl = Errors.stringField(body, "cvUrl");
		if (cvUrl == null) throw Errors.validation("cvUrl is required");
		String message = Errors.stringField(body, "message");
		if (message == null) throw Errors.validation("message is required");

		String status = String.valueOf(current.get("status"));
		if (body.get("status") != null) {
			if (!(body.get("status") instanceof String s) || !STATUSES.contains(s)) {
				throw Errors.validation("status must be one of: sent, viewed, interview, rejected");
			}
			status = s;
		}

		db.jdbc.update("UPDATE applications SET cv_url = ?, message = ?, status = ? WHERE id = ?",
				cvUrl, message, status, id);
		return toJson(find(userId, id));
	}

	/** DELETE /applications/{id} -> 204 | 404 */
	@DeleteMapping("/{id}")
	@ResponseStatus(HttpStatus.NO_CONTENT)
	public void delete(@RequestAttribute("userId") long userId, @PathVariable long id) {
		find(userId, id); // 404 до удаления
		db.jdbc.update("DELETE FROM applications WHERE id = ?", id);
	}

	private static int parseIntOr(String value, int fallback) {
		try {
			return Integer.parseInt(value);
		} catch (NumberFormatException e) {
			return fallback;
		}
	}
}
