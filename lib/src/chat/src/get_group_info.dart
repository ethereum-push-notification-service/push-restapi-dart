import '../../../push_restapi_dart.dart';

Future<GroupInfoDTO> getGroupInfo({required String chatId}) async {
  if (chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }

  final result = await http.get(path: '/v2/chat/groups/$chatId');

  if (result == null || result is String) {
    throw Exception(
        result ?? 'Failed to retrieve group information. ChatId: $chatId');
  }

  return GroupInfoDTO.fromJson(result);
}
