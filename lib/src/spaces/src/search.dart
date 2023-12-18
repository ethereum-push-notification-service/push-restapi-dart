import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<List<SpaceDTO>> searchSpaces({
  required String searchTerm,
  int pageNumber = 1,
  int pageSize = 20,
}) async {
  try {
    final body = {
      'searchTerm': searchTerm,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };

    final result = await http.post(path: '/v1/spaces/search', data: body);

    if (result == null || result is String) {
      throw Exception(result ?? 'Cannot find spaces that match $searchTerm');
    }

    return (result as List).map((e) => SpaceDTO.fromJson(e)).toList();
  } catch (e) {
    log('[Push SDK] - API  - Error - API searchSpaces -:  $e');
    rethrow;
  }
}
