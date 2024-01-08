import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<void> testGetGroupMemberStatus() async {
  final result = await getGroupMemberStatus(
      did: '0xBF8e4e027D59B11A30096AA6a51A0B5f79C7e648',
      chatId:
          '5ed6ac1c59384fc447986141e5ff593b8fd446d63bd3a9a0f16e06e012bc86d3');

  print('testGetGroupMemberStatus result: $result');
}
