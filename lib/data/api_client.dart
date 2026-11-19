import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_message.dart';
import 'result.dart';
import 'token_store.dart';


class ApiClient {
  ApiClient(this.baseUrl, this.tokens, {this.onUnauthorized});

  final String baseUrl;
  final TokenStore tokens;

  /// Решает корень композиции: назад на login. Repository не знает про router.
  final void Function()? onUnauthorized;

  static const _timeout = Duration(seconds: 8);

  Future<Result<T>> call<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    int okStatus = 200, // хороший статус: 200 / 201 / 204
    required T Function(Object? json) parse,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
      final res = await _send(method, uri, body).timeout(_timeout); // слой 1: дорога
      if (res.statusCode == 401) return Err(await _sessionDied());
      if (res.statusCode != okStatus) return Err(apiMessage(res)); // слой 2: статус
      // 204: тело пустое — jsonDecode на нём упал бы (ловушка C8).
      final json =
          res.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(res.bodyBytes));
      return Ok(parse(json));
    } on SocketException {
      return const Err('Нет сети — повторите попытку');
    } on http.ClientException {
      return const Err('Нет сети — повторите попытку');
    } on TimeoutException {
      return const Err('Сервер не отвечает');
    } on FormatException {
      return const Err('Ответ не тот, что обещан'); // слой 3: тело-сюрприз
    } on TypeError {
      return const Err('Ответ не тот, что обещан');
    }
  }

  Future<http.Response> _send(String method, Uri uri, Object? body) async {
    final request = http.Request(method, uri)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Authorization'] = 'Bearer ${await tokens.read() ?? ''}';
    if (body != null) request.body = jsonEncode(body);
    return http.Response.fromStream(await request.send());
  }

  /// 401 = пропуск умер: token выбрасывается (C9), корень уводит на login.
  Future<String> _sessionDied() async {
    await tokens.clear();
    onUnauthorized?.call();
    return 'Сессия истекла — войдите снова';
  }
}