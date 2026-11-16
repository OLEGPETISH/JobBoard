// Расширение контракта: отклики студента, маршруты /applications.
// Отклики принадлежат пользователю; статус при создании всегда "sent".

import 'base_checks.dart';
import 'harness.dart';

Future<void> runApplicationChecks(Api api, Runner r) async {
  final student = await registerUser(api, 'student');
  final other = await registerUser(api, 'applother');
  final marker = 'Msg${DateTime.now().microsecondsSinceEpoch}';

  final jobs = await api.get('/job-posts', token: student.token, query: {'limit': '1'});
  expectStatus(jobs, 200);
  final jobId = ((jobs.obj['items'] as List).first as Map)['id'] as int;
  late Map<String, dynamic> app1;
  late Map<String, dynamic> app2;

  r.section('Отклики: /applications');
  await r.check('GET /applications без token -> 401 UNAUTHORIZED', () async {
    expectError(await api.get('/applications'), 401, 'UNAUTHORIZED');
  });
  await r.check('новый пользователь: пустой список {items:[],total:0}', () async {
    final res = await api.get('/applications', token: student.token);
    expectStatus(res, 200);
    expect((res.obj['items'] as List).isEmpty && res.obj['total'] == 0, 'ожидали пустой список');
  });
  await r.check('POST /applications -> 201, status = "sent", id от сервера', () async {
    final res = await api.post(
        '/applications',
        {'jobPostId': jobId, 'cvUrl': 'https://example.md/cv.pdf', 'message': 'Первый $marker'},
        token: student.token);
    expectStatus(res, 201);
    app1 = res.obj;
    expect(app1['id'] is int, 'id должен быть числом');
    expect(app1['jobPostId'] == jobId, 'jobPostId должен совпасть');
    expect(app1['cvUrl'] == 'https://example.md/cv.pdf', 'cvUrl должен совпасть');
    expect(app1['message'] == 'Первый $marker', 'message (с кириллицей) должен совпасть');
    expect(app1['status'] == 'sent', 'статус при создании — "sent"');
    expect(app1['createdAt'] is String, 'createdAt должен быть строкой');
  });
  await r.check('POST: статус из тела игнорируется, остаётся "sent"', () async {
    final res = await api.post(
        '/applications',
        {'jobPostId': jobId, 'cvUrl': '/files/1', 'message': 'Второй', 'status': 'rejected'},
        token: student.token);
    expectStatus(res, 201);
    app2 = res.obj;
    expect(app2['status'] == 'sent', 'клиент не вправе задавать статус при создании');
  });
  await r.check('POST без jobPostId -> 400 VALIDATION_ERROR', () async {
    expectError(await api.post('/applications', {'cvUrl': 'u', 'message': 'm'}, token: student.token),
        400, 'VALIDATION_ERROR');
  });
  await r.check('POST: несуществующая вакансия -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.post('/applications', {'jobPostId': 999999, 'cvUrl': 'u', 'message': 'm'},
            token: student.token),
        400,
        'VALIDATION_ERROR');
  });
  await r.check('POST без cvUrl -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.post('/applications', {'jobPostId': jobId, 'message': 'm'}, token: student.token),
        400,
        'VALIDATION_ERROR');
  });
  await r.check('POST без message -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.post('/applications', {'jobPostId': jobId, 'cvUrl': 'u'}, token: student.token),
        400,
        'VALIDATION_ERROR');
  });
  await r.check('GET /applications/{id} -> 200; несуществующий и /abc -> 404', () async {
    final res = await api.get('/applications/${app1['id']}', token: student.token);
    expectStatus(res, 200);
    expect(res.obj['message'] == 'Первый $marker', 'message должен совпасть');
    expectError(await api.get('/applications/999999', token: student.token), 404, 'NOT_FOUND');
    expectError(await api.get('/applications/abc', token: student.token), 404, 'NOT_FOUND');
  });
  await r.check('список: новые отклики первыми, total=2', () async {
    final res = await api.get('/applications', token: student.token);
    expectStatus(res, 200);
    final items = res.obj['items'] as List;
    expect(res.obj['total'] == 2 && items.length == 2, 'ожидали два отклика');
    expect((items.first as Map)['id'] == app2['id'], 'самый новый отклик должен идти первым');
  });
  await r.check('чужой пользователь: GET/PUT/DELETE -> 404, список пуст', () async {
    final id = app1['id'];
    expectError(await api.get('/applications/$id', token: other.token), 404, 'NOT_FOUND');
    expectError(
        await api.put('/applications/$id', {'cvUrl': 'u', 'message': 'hack'}, token: other.token),
        404,
        'NOT_FOUND');
    expectError(await api.delete('/applications/$id', token: other.token), 404, 'NOT_FOUND');
    final list = await api.get('/applications', token: other.token);
    expect(list.obj['total'] == 0, 'чужие отклики не должны попадать в список');
  });
  await r.check('PUT: смена статуса на "interview" -> 200', () async {
    final res = await api.put(
        '/applications/${app1['id']}',
        {'cvUrl': 'https://example.md/cv2.pdf', 'message': 'Правка $marker', 'status': 'interview'},
        token: student.token);
    expectStatus(res, 200);
    expect(res.obj['status'] == 'interview', 'статус должен обновиться');
    expect(res.obj['cvUrl'] == 'https://example.md/cv2.pdf', 'cvUrl должен обновиться');
  });
  await r.check('PUT без status оставляет прежний; jobPostId не меняется', () async {
    final res = await api.put(
        '/applications/${app1['id']}',
        {'cvUrl': 'u3', 'message': 'm3', 'jobPostId': 999999},
        token: student.token);
    expectStatus(res, 200);
    expect(res.obj['status'] == 'interview', 'статус должен остаться "interview"');
    expect(res.obj['jobPostId'] == jobId, 'jobPostId менять нельзя');
  });
  await r.check('PUT: неизвестный status -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.put('/applications/${app1['id']}', {'cvUrl': 'u', 'message': 'm', 'status': 'bogus'},
            token: student.token),
        400,
        'VALIDATION_ERROR');
  });
  await r.check('PUT без message -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.put('/applications/${app1['id']}', {'cvUrl': 'u'}, token: student.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('пагинация: limit=1 -> 1 элемент, total=2; search на сервере', () async {
    final p = await api.get('/applications', token: student.token, query: {'limit': '1'});
    expect((p.obj['items'] as List).length == 1 && p.obj['total'] == 2, 'ожидали 1 элемент, total=2');
    final none = await api.get('/applications', token: student.token, query: {'search': 'zzzz-none'});
    expect(none.obj['total'] == 0, 'поиск без совпадений должен давать total=0');
    final found = await api.get('/applications', token: student.token, query: {'search': 'Второй'});
    expect(found.obj['total'] == 1, 'поиск по message (кириллица) должен находить один отклик');
  });
  await r.check('DELETE -> 204 с пустым телом, затем GET -> 404', () async {
    final res = await api.delete('/applications/${app1['id']}', token: student.token);
    expectStatus(res, 204);
    expect(res.bytes.isEmpty, 'тело 204 должно быть пустым');
    expectError(await api.get('/applications/${app1['id']}', token: student.token), 404, 'NOT_FOUND');
  });
  await r.check('удаление вакансии автором удаляет и отклики на неё', () async {
    final created = await api.post('/job-posts', {'title': 'Temp $marker', 'company': 'Tmp'},
        token: student.token);
    expectStatus(created, 201);
    final tempId = created.obj['id'];
    final app = await api.post(
        '/applications', {'jobPostId': tempId, 'cvUrl': 'u', 'message': 'to be removed'},
        token: student.token);
    expectStatus(app, 201);
    expectStatus(await api.delete('/job-posts/$tempId', token: student.token), 204);
    expectError(await api.get('/applications/${app.obj['id']}', token: student.token), 404, 'NOT_FOUND');
  });
}
