import 'dart:typed_data';

import 'api_client.dart';
import 'result.dart';

class FileApi {
  FileApi(this._api);

  final ApiClient _api;

  Future<Result<String>> upload(String filename, Uint8List bytes) => _api.upload(
        '/files',
        filename: filename,
        bytes: bytes,
        parse: (json) => (json as Map<String, dynamic>)['url'] as String,
      );
}