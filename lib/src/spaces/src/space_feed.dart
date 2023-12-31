import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<SpaceFeeds?> spaceFeed({
  String? accountAddress,
  String? pgpPrivateKey,
  bool toDecrypt = true,
  required String recipient,
}) async {
  accountAddress ??= getCachedWallet()?.address;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
  if (accountAddress == null) {
    throw Exception('Account address is required.');
  }

  final user = await getUserDID(address: accountAddress);
  final recipientWallet = await getUserDID(address: recipient);

  if (!isValidETHAddress(user)) {
    throw Exception("Invalid address $user");
  }

  try {
    final path = "/v1/spaces/users/$user/space/$recipientWallet";
    final result = await http.get(path: path);
    if (result == null) {
      return null;
    }
    return SpaceFeeds.fromJson(result['data']);
  } catch (e) {
    log('Push spaceFeed: Error $e');
    rethrow;
  }
}
