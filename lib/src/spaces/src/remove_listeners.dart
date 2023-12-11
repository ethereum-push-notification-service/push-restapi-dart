import '../../../push_restapi_dart.dart';

Future<SpaceDTO> removeListeners({
  required String spaceId,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
  required List<String> listeners,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
  try {
    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }

    if (listeners.isEmpty) {
      throw Exception("listeners address array cannot be empty!");
    }

    for (var listener in listeners) {
      if (!isValidETHAddress(listener)) {
        throw Exception('Invalid listener address: $listener');
      }
    }

    final group = await removeMembers(
        chatId: spaceId,
        members: listeners,
        signer: signer,
        account: account,
        pgpPrivateKey: pgpPrivateKey);
    if (group != null) {
      return groupInfoDtoToSpaceDto(group);
    } else {
      throw Exception('Error while updating Space : $spaceId');
    }
  } catch (e) {
    log("[Push SDK] - API  - Error - API removeListeners -: $e ");
    rethrow;
  }
}
