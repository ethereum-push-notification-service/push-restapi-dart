import 'package:push_restapi_dart/push_restapi_dart.dart';

///Get the latest chat message
Future<List<Message>> latest({
  required String threadhash,
  required String account,
  int limit = FetchLimit.DEFAULT,
  required String pgpPrivateKey,
  bool toDecrypt = false,
}) async {
  return history(
    threadhash: threadhash,
    accountAddress: account,
    pgpPrivateKey: pgpPrivateKey,
    limit: 1,
    toDecrypt: toDecrypt,
  );
}
