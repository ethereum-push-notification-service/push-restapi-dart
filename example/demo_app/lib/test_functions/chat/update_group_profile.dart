import 'package:push_restapi_dart/push_restapi_dart.dart';

void testUpdateGroupProfile() async {
  final result = await updateGroupProfile(
      options: ChatUpdateGroupProfileType(
          groupImage:
              'https://tmpfiles.org/dl/3250024/screenshot2023-11-26at8.51.05pm.png',
          chatId:
              '64434400c9a61256451f025f1f8c7b34d9651af4a03ca063126e137572fb85ca',
          groupName: 'Ayo New name'));

  print(result);
}
