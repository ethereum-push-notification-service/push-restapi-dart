import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

import '../../../push_restapi_dart.dart';

Future<GroupInfoDTO?> removeAdmins({
  required String chatId,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
  required List<String> admins,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

  try {
    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }

    if (admins.isEmpty) {
      throw Exception("Admin address array cannot be empty!");
    }

    return push.updateGroupMembers(
        chatId: chatId,
        signer: signer,
        pgpPrivateKey: pgpPrivateKey,
        account: account,
        remove: admins);
  } catch (e) {
    log("[Push SDK] - API  - Error - API removeAdmins -: $e ");
    rethrow;
  }
}
