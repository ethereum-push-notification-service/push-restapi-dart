import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<String> getEncryptedSecret({required String sessionKey}) async {
  if (sessionKey.isEmpty) {
    throw Exception('sessionKey is required');
  }
  final result =
      await http.get(path: '/v1/chat/encryptedsecret/sessionKey/$sessionKey');

  if (result == null || result is! Map) {
    throw Exception(
        result ?? 'Unable to get encrypted secret with sesionkey $sessionKey');
  }
  return result['encryptedSecret'];
}
