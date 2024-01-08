import 'package:push_restapi_dart/push_restapi_dart.dart';

void testFetchGroupByName() async {
  final result = await getGroupByName(groupName: 'cloth');

  print(result);
}
