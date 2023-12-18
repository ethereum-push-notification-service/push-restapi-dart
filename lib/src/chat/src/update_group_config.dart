import '../../../push_restapi_dart.dart';

Future<GroupDTO> updateGroupConfig({
  String? account,
  Signer? signer,
  required String chatId,
  String? meta,
  DateTime? scheduleAt,
  DateTime? scheduleEnd,
  ChatStatus? status,
  String? pgpPrivateKey,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

  /**
   * VALIDATIONS
   */
  if (account == null && signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }

  final wallet = getWallet(address: account, signer: signer);
  String userDID = getAccountAddress(wallet);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: pgpPrivateKey,
  );
  /**
   * CREATE PROFILE VERIFICATION PROOF
   */
  final bodyToBeHashed = {
    'meta': meta,
    'scheduleAt': scheduleAt?.toIso8601String(),
    'scheduleEnd': scheduleEnd?.toIso8601String(),
    'status': status,
  };
  final hash = generateHash(bodyToBeHashed);

  final signature = await sign(
    message: hash,
    privateKey: connectedUser.privateKey!,
  );

  final sigType = 'pgpv2';
  final configVerificationProof =
      '$sigType:$signature:${walletToPCAIP10(userDID)}';

  final body = {
    ...bodyToBeHashed,
    'configVerificationProof': configVerificationProof,
  };

  final result = await http.put(
    path: '/v1/chat/groups/$chatId/config',
    data: body,
  );

  if (result == null || result is String) {
    throw Exception(result);
  }

  return GroupDTO.fromJson(result);
}
