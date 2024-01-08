import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<GroupAccess> getGroupAccess({
  required String chatId,
  required String did, // Decentralized Identifier
}) async {
  if (chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }
  if (did.isEmpty) {
    throw Exception('did cannot be null or empty');
  }

  final user = await getUserDID(address: did);

  final result = await http.get(path: '/v1/chat/groups/$chatId/access/$user');

  if (result == null || result is String) {
    throw Exception(result ?? 'Cannot get group access for $user in $chatId');
  }

  return GroupAccess.fromJson(result);
}
