import '../../../push_restapi_dart.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

Future<GroupInfoDTO?> addMembers({
  required String chatId,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
  required List<String> members,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

  try {
    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }

    if (members.isEmpty) {
      throw Exception("Member address array cannot be empty!");
    }

    return push.updateGroupMembers(
      chatId: chatId,
      signer: signer,
      pgpPrivateKey: pgpPrivateKey,
      account: account,
      upsert: UpsertDTO(members: members),
    );
  } catch (e) {
    log("[Push SDK] - API  - Error - API addMembers -: $e ");
    rethrow;
  }
}
