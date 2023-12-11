import '../../../push_restapi_dart.dart';

Future<SpaceDTO> info({
  required String spaceId,
}) async {
  try {
    if (spaceId.isEmpty) {
      throw Exception("spaceId cannot be null or empty");
    }
    final group = await getGroup(chatId: spaceId);
    return groupDtoToSpaceDto(group);
  } catch (e) {
    print('[Push SDK] - API  - Error - API update -:  $e');

    throw Exception('Space not found for id : $spaceId');
  }
}
