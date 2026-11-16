# conformance

Набор тестов соответствия backend-контракту PAM: HTTP-клиент без зависимостей,
который проверяет сервер так же, как это делает приложение.

```
cd conformance
dart pub get
dart run bin/conformance.dart --base-url http://localhost:8080
```

Итог: `PASS - N/N checks passed`. Код возврата 0 — все проверки прошли.
Проверки сущностей темы добавляются в `lib/` по мере расширения сервера.
