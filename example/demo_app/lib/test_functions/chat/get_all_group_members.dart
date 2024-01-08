import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<void> testGetAllGroupMembers() async {
  final result = await getAllGroupMembers(
      chatId:
          '5ed6ac1c59384fc447986141e5ff593b8fd446d63bd3a9a0f16e06e012bc86d3');

  print('testGetAllGroupMembers result: $result');

  result.forEach((member) {
    print('testGetAllGroupMembers member address: ${member.address}');
  });
}
