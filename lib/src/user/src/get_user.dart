import '../../../push_restapi_dart.dart';

Future<User?> getUser({
  required String address,
}) async {
  if (!isValidETHAddress(address)) {
    throw Exception('Invalid address!');
  }

  final caip10 = walletToPCAIP10(address);
  final requestUrl = '/v2/users/?caip10=$caip10';
  final result = await http.get(path: requestUrl);

  if (result == null || result.isEmpty) {
    return null;
  }

  if (result is String) {
    throw Exception(result);
  }

  return User.fromJson(result);
}
