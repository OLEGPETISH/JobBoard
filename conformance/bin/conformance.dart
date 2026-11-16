// Набор тестов соответствия backend-контракту PAM.
//
//   dart pub get
//   dart run bin/conformance.dart --base-url http://localhost:8080
//
// Код возврата: 0 — все проверки прошли, 1 — есть провалы, 2 — ошибка запуска.

import 'dart:io';

import 'package:conformance/application_checks.dart';
import 'package:conformance/base_checks.dart';
import 'package:conformance/harness.dart';
import 'package:conformance/job_post_checks.dart';

Future<void> main(List<String> args) async {
  var baseUrl = 'http://localhost:8080';
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--base-url' && i + 1 < args.length) {
      baseUrl = args[i + 1];
    }
  }
  baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '');

  final api = Api(baseUrl);
  final runner = Runner();
  stdout.writeln('Conformance: $baseUrl');

  try {
    await api.get('/health');
  } on SocketException catch (e) {
    stderr.writeln('Сервер не отвечает на $baseUrl (${e.message}). Запущен ли он?');
    exit(2);
  }

  await runBaseChecks(api, runner);
  await runJobPostChecks(api, runner);
  await runApplicationChecks(api, runner);

  api.close();
  stdout.writeln('');
  if (runner.failed == 0) {
    stdout.writeln('PASS - ${runner.passed}/${runner.total} checks passed');
  } else {
    stdout.writeln('FAIL - ${runner.passed}/${runner.total} checks passed, ${runner.failed} failed');
  }
  exit(runner.failed == 0 ? 0 : 1);
}
