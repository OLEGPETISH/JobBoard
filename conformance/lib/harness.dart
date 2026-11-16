// Минимальный каркас: HTTP-клиент, проверки и счётчик результатов.
// Только dart:io и dart:convert — `dart pub get` ничего не скачивает.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Проваленная проверка: сообщение попадает в отчёт.
class Fail implements Exception {
  Fail(this.message);
  final String message;
}

/// Ответ сервера в удобном для проверок виде.
class Res {
  Res(this.status, this.headers, this.bytes);
  final int status;
  final Map<String, String> headers; // имена в нижнем регистре
  final List<int> bytes;

  String get text => utf8.decode(bytes, allowMalformed: true);
  Object? get json => jsonDecode(text);
  Map<String, dynamic> get obj => jsonDecode(text) as Map<String, dynamic>;
}

/// Тонкая обёртка над HttpClient: метод, путь, query, JSON-тело, token.
class Api {
  Api(this.base);
  final String base;
  final HttpClient _client = HttpClient();

  Future<Res> send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? json,
    List<int>? body,
    String? contentType,
    String? token,
    Map<String, String>? headers,
  }) async {
    var uri = Uri.parse('$base$path');
    if (query != null) uri = uri.replace(queryParameters: query);

    final req = await _client.openUrl(method, uri);
    if (token != null) req.headers.set('Authorization', 'Bearer $token');
    headers?.forEach(req.headers.set);

    List<int>? payload = body;
    if (json != null) {
      req.headers.set('Content-Type', 'application/json');
      payload = utf8.encode(jsonEncode(json));
    } else if (contentType != null) {
      req.headers.set('Content-Type', contentType);
    }
    if (payload != null) {
      req.contentLength = payload.length;
      req.add(payload);
    } else if (method == 'POST' || method == 'PUT') {
      req.contentLength = 0;
    }

    final resp = await req.close();
    final bytes = <int>[];
    await for (final chunk in resp) {
      bytes.addAll(chunk);
    }
    final h = <String, String>{};
    resp.headers.forEach((name, values) => h[name.toLowerCase()] = values.join(', '));
    return Res(resp.statusCode, h, bytes);
  }

  Future<Res> get(String path, {String? token, Map<String, String>? query}) =>
      send('GET', path, token: token, query: query);
  Future<Res> post(String path, Object? json, {String? token}) =>
      send('POST', path, json: json, token: token);
  Future<Res> put(String path, Object? json, {String? token}) =>
      send('PUT', path, json: json, token: token);
  Future<Res> delete(String path, {String? token}) =>
      send('DELETE', path, token: token);

  /// multipart/form-data с одним файлом в поле [field].
  Future<Res> upload(
    String path,
    List<int> data, {
    String field = 'file',
    String filename = 'test.txt',
    String mime = 'text/plain',
    String? token,
  }) {
    const boundary = '----conformance7MA4YWxkTrZu0gW';
    final head = utf8.encode('--$boundary\r\n'
        'Content-Disposition: form-data; name="$field"; filename="$filename"\r\n'
        'Content-Type: $mime\r\n\r\n');
    final tail = utf8.encode('\r\n--$boundary--\r\n');
    final body = BytesBuilder()
      ..add(head)
      ..add(data)
      ..add(tail);
    return send('POST', path,
        body: body.takeBytes(),
        contentType: 'multipart/form-data; boundary=$boundary',
        token: token);
  }

  void close() => _client.close(force: true);
}

// ----- проверки ------------------------------------------------------------

void expect(bool condition, String message) {
  if (!condition) throw Fail(message);
}

void expectStatus(Res res, int status) {
  if (res.status != status) {
    final preview = res.text.length > 160 ? '${res.text.substring(0, 160)}...' : res.text;
    throw Fail('ожидали HTTP $status, получили ${res.status}: $preview');
  }
}

/// Стандартный конверт ошибки: {"error":{"code":"...","message":"..."}}.
void expectError(Res res, int status, String code) {
  expectStatus(res, status);
  Object? body;
  try {
    body = res.json;
  } on FormatException {
    throw Fail('тело ошибки — не JSON: ${res.text}');
  }
  final error = body is Map ? body['error'] : null;
  if (error is! Map) throw Fail('нет объекта "error" в теле: ${res.text}');
  if (error['code'] != code) {
    throw Fail('ожидали code=$code, получили ${error['code']}');
  }
  if (error['message'] is! String || (error['message'] as String).isEmpty) {
    throw Fail('"error.message" должна быть непустой строкой');
  }
}

/// Запускает проверки по порядку и ведёт счёт.
class Runner {
  int passed = 0;
  int failed = 0;

  void section(String title) => stdout.writeln('\n$title');

  Future<void> check(String name, FutureOr<void> Function() body) async {
    try {
      await body();
      passed++;
      stdout.writeln('  ok    $name');
    } on Fail catch (e) {
      failed++;
      stdout.writeln('  FAIL  $name\n          ${e.message}');
    } on SocketException catch (e) {
      failed++;
      stdout.writeln('  FAIL  $name\n          сервер недоступен: ${e.message}');
    } catch (e) {
      failed++;
      stdout.writeln('  FAIL  $name\n          исключение: $e');
    }
  }

  int get total => passed + failed;
}
