import '../../../push_restapi_dart.dart';

Future<SpaceDTO> addSpeakers({
  required String spaceId,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
  required List<String> speakers,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
  if (account == null && signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }
  if (speakers.isEmpty) {
    throw Exception("Speaker address array cannot be empty!");
  }

  try {
    for (var speaker in speakers) {
      if (!isValidETHAddress(speaker)) {
        throw Exception('Invalid speaker address: $speaker');
      }
    }

    final group = await addAdmins(
        chatId: spaceId,
        admins: speakers,
        signer: signer,
        account: account,
        pgpPrivateKey: pgpPrivateKey);
    if (group != null) {
      return groupInfoDtoToSpaceDto(group);
    } else {
      throw Exception('Error while updating Space : $spaceId');
    }
  } catch (e) {
    log("[Push SDK] - API  - Error - API addSpeakers -: $e ");
    rethrow;
  }
}
