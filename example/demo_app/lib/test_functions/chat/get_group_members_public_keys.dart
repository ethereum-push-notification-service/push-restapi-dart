import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<void> testGetGroupMembersPublicKeys() async {
  final result = await getGroupMembersPublicKeys(
      chatId:
          '5ed6ac1c59384fc447986141e5ff593b8fd446d63bd3a9a0f16e06e012bc86d3');

  print('testGetGroupMembersPublicKeys result: $result');
}
