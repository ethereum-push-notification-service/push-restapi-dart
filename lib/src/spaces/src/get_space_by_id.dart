import '../../../push_restapi_dart.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

Future<SpaceDTO> getSpaceById({
  required String spaceId,
}) async {
  try {
    final group = await push.getGroup(chatId: spaceId);
    return groupDtoToSpaceDto(group);
  } catch (e) {
    print('[Push SDK] - API  - Error - API update -:  $e');
    throw Exception('Space not found for id : $spaceId');
  }
}
