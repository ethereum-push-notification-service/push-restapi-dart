import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<GroupDTO> getGroup({required String chatId}) async {
  if (chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }

  final result = await http.get(path: '/v1/chat/groups/$chatId');

  if (result == null || result is String) {
    throw Exception(result ?? 'Cannot find group with $chatId');
  }

  return GroupDTO.fromJson(result);
}
