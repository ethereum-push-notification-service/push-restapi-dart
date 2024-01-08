import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

void testTrendingSpace() async {
  final result = await push.trending();

  print(result);
  if (result is List<push.SpaceFeeds>) {}
}
