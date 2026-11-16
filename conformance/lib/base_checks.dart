// Базовый контракт шаблона: /health, ошибки, auth, notes, files.
// Эти проверки обязаны проходить и на расширенном backend-е.

import 'dart:convert';

import 'harness.dart';

/// Пользователь теста: email уникален на каждый запуск.
class TestUser {
  TestUser(this.email, this.token);
  final String email;
  final String token;
}

Future<TestUser> registerUser(Api api, String tag) async {
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final email = '$tag.$stamp@test.md';
  final res = await api.post('/auth/register',
      {'email': email, 'password': 'parola123', 'name': 'Test $tag'});
  expectStatus(res, 201);
  return TestUser(email, res.obj['token'] as String);
}

Future<void> runBaseChecks(Api api, Runner r) async {
  late TestUser ana;
  late TestUser bob;
  late Map<String, dynamic> note;

  r.section('Сервер и формат ошибок');
  await r.check('GET /health -> 200 {"status":"ok"}', () async {
    final res = await api.get('/health');
    expectStatus(res, 200);
    expect(res.obj['status'] == 'ok', 'status должен быть "ok"');
  });
  await r.check('неизвестный маршрут -> 404 NOT_FOUND в конверте', () async {
    expectError(await api.get('/no-such-route'), 404, 'NOT_FOUND');
  });
  await r.check('защищённый маршрут без token -> 401 UNAUTHORIZED', () async {
    expectError(await api.get('/notes'), 401, 'UNAUTHORIZED');
  });
  await r.check('мусорный token -> 401 UNAUTHORIZED', () async {
    expectError(await api.get('/notes', token: 'abc.def.ghi'), 401, 'UNAUTHORIZED');
  });
  await r.check('битый JSON в теле -> 400 VALIDATION_ERROR', () async {
    final res = await api.send('POST', '/auth/login',
        body: utf8.encode('{oops'), contentType: 'application/json');
    expectError(res, 400, 'VALIDATION_ERROR');
  });
  await r.check('CORS: OPTIONS -> 200 и Access-Control-Allow-Origin', () async {
    final res = await api.send('OPTIONS', '/notes', headers: {
      'Origin': 'http://example.test',
      'Access-Control-Request-Method': 'POST',
    });
    expectStatus(res, 200);
    expect(res.headers['access-control-allow-origin'] != null,
        'нет заголовка Access-Control-Allow-Origin');
  });

  r.section('Аутентификация');
  await r.check('register -> 201 {token, user{id,email,name}}', () async {
    final email = 'ana.${DateTime.now().microsecondsSinceEpoch}@test.md';
    final res = await api.post(
        '/auth/register', {'email': email, 'password': 'parola123', 'name': 'Ana'});
    expectStatus(res, 201);
    final body = res.obj;
    expect(body['token'] is String && (body['token'] as String).isNotEmpty,
        'token должен быть непустой строкой');
    final user = body['user'] as Map<String, dynamic>;
    expect(user['id'] is int, 'user.id должен быть числом');
    expect(user['email'] == email, 'user.email должен совпасть');
    expect(user['name'] == 'Ana', 'user.name должен совпасть');
    expect(!user.containsKey('password') && !user.containsKey('password_hash'),
        'в ответе не должно быть пароля или хеша');
    ana = TestUser(email, body['token'] as String);
  });
  await r.check('register: тот же email -> 409 EMAIL_TAKEN', () async {
    final res = await api.post('/auth/register',
        {'email': ana.email, 'password': 'parola123', 'name': 'Ana'});
    expectError(res, 409, 'EMAIL_TAKEN');
  });
  await r.check('register: некорректный email -> 400 VALIDATION_ERROR', () async {
    final res = await api.post(
        '/auth/register', {'email': 'not-an-email', 'password': 'parola123', 'name': 'X'});
    expectError(res, 400, 'VALIDATION_ERROR');
  });
  await r.check('register: без name -> 400 VALIDATION_ERROR', () async {
    final res = await api.post('/auth/register',
        {'email': 'noname.${DateTime.now().microsecondsSinceEpoch}@test.md', 'password': 'parola123'});
    expectError(res, 400, 'VALIDATION_ERROR');
  });
  await r.check('register: без пароля -> 400 VALIDATION_ERROR', () async {
    final res = await api.post('/auth/register',
        {'email': 'nopass.${DateTime.now().microsecondsSinceEpoch}@test.md', 'name': 'X'});
    expectError(res, 400, 'VALIDATION_ERROR');
  });
  await r.check('login -> 200 {token, user}', () async {
    final res = await api.post(
        '/auth/login', {'email': ana.email, 'password': 'parola123'});
    expectStatus(res, 200);
    expect(res.obj['token'] is String, 'token должен быть строкой');
    expect((res.obj['user'] as Map)['email'] == ana.email, 'user.email должен совпасть');
  });
  await r.check('login: неверный пароль -> 401 UNAUTHORIZED', () async {
    expectError(
        await api.post('/auth/login', {'email': ana.email, 'password': 'wrong-pass'}),
        401,
        'UNAUTHORIZED');
  });
  await r.check('login: неизвестный email -> 401 UNAUTHORIZED', () async {
    expectError(
        await api.post('/auth/login', {'email': 'nobody@test.md', 'password': 'parola123'}),
        401,
        'UNAUTHORIZED');
  });
  await r.check('GET /me с token -> 200 {id,email,name}', () async {
    final res = await api.get('/me', token: ana.token);
    expectStatus(res, 200);
    expect(res.obj['email'] == ana.email, 'email должен совпасть');
    expect(res.obj['id'] is int, 'id должен быть числом');
  });
  await r.check('GET /me без token -> 401 UNAUTHORIZED', () async {
    expectError(await api.get('/me'), 401, 'UNAUTHORIZED');
  });

  r.section('Notes: CRUD, пагинация, поиск');
  bob = await registerUser(api, 'bob');
  await r.check('пустой список -> {items:[],page:1,limit:20,total:0}', () async {
    final res = await api.get('/notes', token: bob.token);
    expectStatus(res, 200);
    final b = res.obj;
    expect((b['items'] as List).isEmpty, 'items должен быть пустым');
    expect(b['page'] == 1 && b['limit'] == 20 && b['total'] == 0,
        'ожидали page=1, limit=20, total=0, получили ${res.text}');
  });
  await r.check('POST /notes -> 201 с id от сервера', () async {
    final res = await api.post(
        '/notes', {'title': 'Shopping', 'content': 'milk, bread'},
        token: ana.token);
    expectStatus(res, 201);
    note = res.obj;
    expect(note['id'] is int, 'id должен быть числом');
    expect(note['title'] == 'Shopping' && note['content'] == 'milk, bread',
        'title/content должны совпасть');
    expect(note['createdAt'] is String, 'createdAt должен быть строкой');
  });
  await r.check('POST /notes без title -> 400 VALIDATION_ERROR', () async {
    expectError(await api.post('/notes', {'content': 'x'}, token: ana.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('POST /notes: пустой title из пробелов -> 400', () async {
    expectError(await api.post('/notes', {'title': '   '}, token: ana.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('POST /notes без content -> 201, content = ""', () async {
    final res = await api.post('/notes', {'title': 'Only title'}, token: ana.token);
    expectStatus(res, 201);
    expect(res.obj['content'] == '', 'content по умолчанию должен быть пустой строкой');
  });
  await r.check('GET /notes/{id} -> 200', () async {
    final res = await api.get('/notes/${note['id']}', token: ana.token);
    expectStatus(res, 200);
    expect(res.obj['title'] == 'Shopping', 'title должен совпасть');
  });
  await r.check('GET /notes/{несуществующий} -> 404 NOT_FOUND', () async {
    expectError(await api.get('/notes/999999', token: ana.token), 404, 'NOT_FOUND');
  });
  await r.check('GET /notes/abc (id не число) -> 404 NOT_FOUND', () async {
    expectError(await api.get('/notes/abc', token: ana.token), 404, 'NOT_FOUND');
  });
  await r.check('PUT /notes/{id} -> 200, данные обновлены', () async {
    final res = await api.put(
        '/notes/${note['id']}', {'title': 'Groceries', 'content': 'eggs'},
        token: ana.token);
    expectStatus(res, 200);
    expect(res.obj['title'] == 'Groceries' && res.obj['content'] == 'eggs',
        'ответ должен содержать новые значения');
    final again = await api.get('/notes/${note['id']}', token: ana.token);
    expect(again.obj['title'] == 'Groceries', 'изменение должно сохраниться');
  });
  await r.check('PUT /notes/{id} без title -> 400 VALIDATION_ERROR', () async {
    expectError(await api.put('/notes/${note['id']}', {'content': 'x'}, token: ana.token),
        400, 'VALIDATION_ERROR');
  });
  await r.check('PUT /notes/{несуществующий} -> 404', () async {
    expectError(await api.put('/notes/999999', {'title': 'x'}, token: ana.token), 404,
        'NOT_FOUND');
  });
  await r.check('чужая заметка: GET/PUT/DELETE -> 404, а не 403', () async {
    final id = note['id'];
    expectError(await api.get('/notes/$id', token: bob.token), 404, 'NOT_FOUND');
    expectError(await api.put('/notes/$id', {'title': 'hack'}, token: bob.token), 404,
        'NOT_FOUND');
    expectError(await api.delete('/notes/$id', token: bob.token), 404, 'NOT_FOUND');
  });
  await r.check('чужие заметки не попадают в список', () async {
    final res = await api.get('/notes', token: bob.token);
    expect(res.obj['total'] == 0, 'у нового пользователя total должен быть 0');
  });

  // Данные для пагинации и поиска: пять заметок отдельного пользователя.
  final pager = await registerUser(api, 'pager');
  for (var i = 1; i <= 5; i++) {
    expectStatus(
        await api.post('/notes', {'title': 'Item $i', 'content': 'unique-$i marker'},
            token: pager.token),
        201);
  }
  await r.check('пагинация: limit=2 → 2 элемента, total=5; page=3 → 1 элемент', () async {
    final p1 = await api.get('/notes', token: pager.token, query: {'page': '1', 'limit': '2'});
    expectStatus(p1, 200);
    expect((p1.obj['items'] as List).length == 2, 'на первой странице 2 элемента');
    expect(p1.obj['total'] == 5 && p1.obj['limit'] == 2 && p1.obj['page'] == 1,
        'ожидали total=5, limit=2, page=1');
    final p3 = await api.get('/notes', token: pager.token, query: {'page': '3', 'limit': '2'});
    expect((p3.obj['items'] as List).length == 1, 'на третьей странице 1 элемент');
  });
  await r.check('страницы не пересекаются (порядок стабилен)', () async {
    final p1 = await api.get('/notes', token: pager.token, query: {'page': '1', 'limit': '2'});
    final p2 = await api.get('/notes', token: pager.token, query: {'page': '2', 'limit': '2'});
    final ids1 = (p1.obj['items'] as List).map((e) => (e as Map)['id']).toSet();
    final ids2 = (p2.obj['items'] as List).map((e) => (e as Map)['id']).toSet();
    expect(ids1.intersection(ids2).isEmpty, 'одна запись попала на две страницы');
  });
  await r.check('limit больше 100 ограничивается до 100', () async {
    final res = await api.get('/notes', token: pager.token, query: {'limit': '1000'});
    expect(res.obj['limit'] == 100, 'ожидали limit=100, получили ${res.obj['limit']}');
  });
  await r.check('мусор в page/limit -> значения по умолчанию', () async {
    final res =
        await api.get('/notes', token: pager.token, query: {'page': 'abc', 'limit': 'zz'});
    expectStatus(res, 200);
    expect(res.obj['page'] == 1 && res.obj['limit'] == 20,
        'ожидали page=1, limit=20 по умолчанию');
  });
  await r.check('search находит запись по title и content (на сервере)', () async {
    final byTitle = await api.get('/notes', token: pager.token, query: {'search': 'Item 3'});
    expect(byTitle.obj['total'] == 1, 'поиск по title: ожидали 1 запись');
    final byContent =
        await api.get('/notes', token: pager.token, query: {'search': 'unique-4'});
    expect(byContent.obj['total'] == 1, 'поиск по content: ожидали 1 запись');
  });
  await r.check('search без совпадений -> пустой items, total=0', () async {
    final res = await api.get('/notes', token: pager.token, query: {'search': 'zzzz-none'});
    expectStatus(res, 200);
    expect((res.obj['items'] as List).isEmpty && res.obj['total'] == 0,
        'ожидали пустой результат');
  });
  await r.check('DELETE /notes/{id} -> 204 с пустым телом', () async {
    final res = await api.delete('/notes/${note['id']}', token: ana.token);
    expectStatus(res, 204);
    expect(res.bytes.isEmpty, 'тело 204 должно быть пустым');
  });
  await r.check('GET удалённой заметки -> 404', () async {
    expectError(await api.get('/notes/${note['id']}', token: ana.token), 404, 'NOT_FOUND');
  });
  await r.check('DELETE несуществующей -> 404', () async {
    expectError(await api.delete('/notes/999999', token: ana.token), 404, 'NOT_FOUND');
  });

  r.section('Files: загрузка и скачивание');
  final content = utf8.encode('hello conformance');
  late Map<String, dynamic> file;
  await r.check('POST /files (multipart) -> 201 {id,url,name,mimeType,size}', () async {
    final res = await api.upload('/files', content, token: ana.token);
    expectStatus(res, 201);
    file = res.obj;
    expect(file['id'] is int, 'id должен быть числом');
    expect((file['url'] as String).startsWith('/files/'), 'url — относительный путь /files/{id}');
    expect(file['name'] == 'test.txt', 'name должен совпасть с именем файла');
    expect(file['mimeType'] == 'text/plain', 'mimeType должен совпасть');
    expect(file['size'] == content.length, 'size должен равняться размеру файла');
  });
  await r.check('GET /files/{id} без token отдаёт те же байты', () async {
    final res = await api.get(file['url'] as String);
    expectStatus(res, 200);
    expect(utf8.decode(res.bytes) == 'hello conformance', 'байты должны совпасть');
    expect((res.headers['content-type'] ?? '').startsWith('text/plain'),
        'Content-Type должен совпасть с загруженным');
  });
  await r.check('скачивание: заголовки анти-XSS', () async {
    final res = await api.get(file['url'] as String);
    expect(res.headers['x-content-type-options'] == 'nosniff', 'нужен X-Content-Type-Options: nosniff');
    expect((res.headers['content-disposition'] ?? '').startsWith('attachment'),
        'нужен Content-Disposition: attachment');
    expect((res.headers['content-security-policy'] ?? '').contains("default-src 'none'"),
        "нужен Content-Security-Policy c default-src 'none'");
  });
  await r.check('GET /files/{несуществующий} -> 404 NOT_FOUND', () async {
    expectError(await api.get('/files/999999'), 404, 'NOT_FOUND');
  });
  await r.check('POST /files без token -> 401 UNAUTHORIZED', () async {
    expectError(await api.upload('/files', content), 401, 'UNAUTHORIZED');
  });
  await r.check('POST /files без поля file -> 400 VALIDATION_ERROR', () async {
    expectError(await api.upload('/files', content, field: 'other', token: ana.token), 400,
        'VALIDATION_ERROR');
  });
  await r.check('POST /files больше 5 МБ -> 400 VALIDATION_ERROR', () async {
    final big = List<int>.filled(5 * 1024 * 1024 + 4096, 65);
    expectError(await api.upload('/files', big, token: ana.token), 400, 'VALIDATION_ERROR');
  });
}
