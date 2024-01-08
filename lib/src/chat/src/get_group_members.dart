import 'package:push_restapi_dart/push_restapi_dart.dart';

class FetchChatGroupInfoType {
  late String chatId;
  int page;
  int limit;
  bool? pending;
  String? role;

  FetchChatGroupInfoType({
    required this.chatId,
    this.page = 1,
    this.limit = 20,
    this.pending,
    this.role,
  });
}

Future<List<ChatMemberProfile>> getGroupMembers(
    {required FetchChatGroupInfoType options}) async {
  if (options.chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }

  var requestUrl =
      '/v1/chat/groups/${options.chatId}/members?pageNumber=${options.page}&pageSize=${options.limit}';
  if (options.pending != null) {
    requestUrl += '&pending=${options.pending}';
  }
  if (options.role != null) {
    requestUrl += '&role=${options.role}';
  }
  final result = await http.get(
    path: requestUrl,
  );

  if (result == null || result is String) {
    throw Exception(result ??
        'Failed to retrieve group members. ChatId: ${options.chatId}');
  }

  return (result['members'] as List)
      .map((e) => ChatMemberProfile.fromJson(e))
      .toList();
}
