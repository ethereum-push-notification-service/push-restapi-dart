import 'package:push_restapi_dart/push_restapi_dart.dart';

void testUpdateGroupConfig() async {
  final result = await updateGroupConfig(
      scheduleAt: DateTime.now().add(Duration(hours: 3)),
      chatId:
          '64434400c9a61256451f025f1f8c7b34d9651af4a03ca063126e137572fb85ca');

  print(result);
}
