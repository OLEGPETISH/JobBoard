// Расширение контракта: вакансии JobBoard, маршруты /job-posts.
// Каталог общий для всех пользователей; менять/удалять вакансию может только автор.

import 'base_checks.dart';
import 'harness.dart';

Map<String, dynamic> _first(Res res) =>
    (res.obj['items'] as List).first as Map<String, dynamic>;

Future<void> runJobPostChecks(Api api, Runner r) async {
  final owner = await registerUser(api, 'jobowner');
  final other = await registerUser(api, 'jobother');
  final marker = 'Conf${DateTime.now().microsecondsSinceEpoch}';
  late Map<String, dynamic> post;
  late int seedId;
  late int totalAtStart;

  r.section('Вакансии: /job-posts');
  await r.check('GET /job-posts без token -> 401 UNAUTHORIZED', () async {
    expectError(await api.get('/job-posts'), 401, 'UNAUTHORIZED');
  });
  await r.check('каталог не пуст, конверт {items,page,limit,total}', () async {
    final res = await api.get('/job-posts', token: owner.token);
    expectStatus(res, 200);
    final b = res.obj;
    expect((b['total'] as int) >= 1, 'в каталоге должны быть стартовые вакансии');
    expect(b['page'] == 1 && b['limit'] == 20, 'ожидали page=1, limit=20');
    totalAtStart = b['total'] as int;
    final item = _first(res);
    seedId = item['id'] as int;
    expect(item['id'] is int, 'id должен быть числом');
    for (final key in ['title', 'company', 'salaryRange', 'schedule', 'location', 'description', 'createdAt']) {
      expect(item[key] is String, '$key должен быть строкой');
    }
    expect(item['techStack'] is List && item['requirements'] is List,
        'techStack и requirements должны быть массивами');
  });
  await r.check('каталог общий: другой пользователь видит то же самое', () async {
    final res = await api.get('/job-posts', token: other.token);
    expect(res.obj['total'] == totalAtStart, 'total должен совпасть у разных пользователей');
  });
  await r.check('POST /job-posts -> 201, id от сервера, массивы сохранены', () async {
    final res = await api.post(
        '/job-posts',
        {
          'title': 'Dev $marker',
          'company': 'Acme',
          'salaryRange': '1 000 MDL',
          'techStack': ['Dart', 'Flutter'],
          'schedule': 'Part-time',
          'location': 'Remote',
          'description': 'Описание с кириллицей',
          'requirements': ['Git', 'SQL'],
        },
        token: owner.token);
    expectStatus(res, 201);
    post = res.obj;
    expect(post['id'] is int, 'id должен быть числом');
    expect(post['title'] == 'Dev $marker' && post['company'] == 'Acme', 'title/company должны совпасть');
    expect((post['techStack'] as List).join(',') == 'Dart,Flutter', 'techStack должен сохраниться');
    expect((post['requirements'] as List).join(',') == 'Git,SQL', 'requirements должен сохраниться');
    expect(post['description'] == 'Описание с кириллицей', 'кириллица должна сохраниться');
  });
  await r.check('POST /job-posts без title -> 400 VALIDATION_ERROR', () async {
    expectError(await api.post('/job-posts', {'company': 'Acme'}, token: owner.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('POST /job-posts без company -> 400 VALIDATION_ERROR', () async {
    expectError(await api.post('/job-posts', {'title': 'X'}, token: owner.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('POST /job-posts: techStack не массив -> 400 VALIDATION_ERROR', () async {
    final res = await api.post(
        '/job-posts', {'title': 'X', 'company': 'Y', 'techStack': 'Flutter'},
        token: owner.token);
    expectError(res, 400, 'VALIDATION_ERROR');
  });
  await r.check('GET /job-posts/{id} -> 200; чужая вакансия читается (общий каталог)', () async {
    final mine = await api.get('/job-posts/${post['id']}', token: owner.token);
    expectStatus(mine, 200);
    final theirs = await api.get('/job-posts/${post['id']}', token: other.token);
    expectStatus(theirs, 200);
    expect(theirs.obj['title'] == 'Dev $marker', 'title должен совпасть');
  });
  await r.check('GET /job-posts/{несуществующий} и /abc -> 404 NOT_FOUND', () async {
    expectError(await api.get('/job-posts/999999', token: owner.token), 404, 'NOT_FOUND');
    expectError(await api.get('/job-posts/abc', token: owner.token), 404, 'NOT_FOUND');
  });
  await r.check('PUT автором -> 200, данные обновлены', () async {
    final res = await api.put(
        '/job-posts/${post['id']}',
        {'title': 'Dev2 $marker', 'company': 'Acme', 'techStack': ['Java']},
        token: owner.token);
    expectStatus(res, 200);
    expect(res.obj['title'] == 'Dev2 $marker', 'title должен обновиться');
    expect((res.obj['techStack'] as List).join(',') == 'Java', 'techStack должен обновиться');
  });
  await r.check('PUT без title -> 400 VALIDATION_ERROR', () async {
    expectError(
        await api.put('/job-posts/${post['id']}', {'company': 'Acme'}, token: owner.token),
        400,
        'VALIDATION_ERROR');
  });
  await r.check('PUT/DELETE чужой вакансии -> 404, а не 403', () async {
    expectError(
        await api.put('/job-posts/${post['id']}', {'title': 'hack', 'company': 'x'}, token: other.token),
        404,
        'NOT_FOUND');
    expectError(await api.delete('/job-posts/${post['id']}', token: other.token), 404, 'NOT_FOUND');
  });
  await r.check('стартовые вакансии только для чтения: PUT/DELETE -> 404', () async {
    expectError(
        await api.put('/job-posts/$seedId', {'title': 'hack', 'company': 'x'}, token: owner.token),
        404,
        'NOT_FOUND');
    expectError(await api.delete('/job-posts/$seedId', token: owner.token), 404, 'NOT_FOUND');
  });
  await r.check('search на сервере: по title, по кириллице', () async {
    final byTitle = await api.get('/job-posts', token: owner.token, query: {'search': marker});
    expect(byTitle.obj['total'] == 1, 'поиск по уникальному title: ожидали 1 запись');
    final cyr = await api.get('/job-posts', token: owner.token, query: {'search': 'Кишинёв'});
    expectStatus(cyr, 200);
    expect((cyr.obj['total'] as int) >= 1, 'поиск по кириллице должен находить стартовые вакансии');
  });
  await r.check('search без совпадений -> пустой items, total=0', () async {
    final res = await api.get('/job-posts', token: owner.token, query: {'search': 'zzzz-none-zzzz'});
    expect((res.obj['items'] as List).isEmpty && res.obj['total'] == 0, 'ожидали пустой результат');
  });
  await r.check('пагинация: limit=3, страницы не пересекаются, limit<=100', () async {
    final p1 = await api.get('/job-posts', token: owner.token, query: {'page': '1', 'limit': '3'});
    final p2 = await api.get('/job-posts', token: owner.token, query: {'page': '2', 'limit': '3'});
    expect((p1.obj['items'] as List).length == 3, 'на первой странице 3 элемента');
    final ids1 = (p1.obj['items'] as List).map((e) => (e as Map)['id']).toSet();
    final ids2 = (p2.obj['items'] as List).map((e) => (e as Map)['id']).toSet();
    expect(ids2.isNotEmpty && ids1.intersection(ids2).isEmpty, 'страницы не должны пересекаться');
    final big = await api.get('/job-posts', token: owner.token, query: {'limit': '1000'});
    expect(big.obj['limit'] == 100, 'limit должен ограничиваться до 100');
  });
  await r.check('DELETE автором -> 204 с пустым телом, затем 404', () async {
    final res = await api.delete('/job-posts/${post['id']}', token: owner.token);
    expectStatus(res, 204);
    expect(res.bytes.isEmpty, 'тело 204 должно быть пустым');
    expectError(await api.get('/job-posts/${post['id']}', token: owner.token), 404, 'NOT_FOUND');
  });
}
