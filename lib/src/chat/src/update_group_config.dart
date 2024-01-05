import '../../../push_restapi_dart.dart';

class ChatUpdateConfigProfileType {
  String? account;
  Signer? signer;
  String chatId;
  String? meta;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  ChatStatus? status;
  String? pgpPrivateKey;

  ChatUpdateConfigProfileType({
    this.account,
    this.signer,
    required this.chatId,
    this.meta,
    this.scheduleAt,
    this.scheduleEnd,
    this.status,
    this.pgpPrivateKey,
  });
}

Future<GroupDTO> updateGroupConfig({
  required ChatUpdateConfigProfileType options,
}) async {
  options.account ??= getCachedWallet()?.address;
  options.signer ??= getCachedWallet()?.signer;
  options.pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

  /**
   * VALIDATIONS
   */
  if (options.account == null && options.signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }

  final wallet = getWallet(address: options.account, signer: options.signer);
  String userDID = getAccountAddress(wallet);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: options.pgpPrivateKey,
  );
  /**
   * CREATE PROFILE VERIFICATION PROOF
   */
  final bodyToBeHashed = {
    'meta': options.meta,
    'scheduleAt': options.scheduleAt?.toIso8601String(),
    'scheduleEnd': options.scheduleEnd?.toIso8601String(),
    'status': options.status,
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
    path: '/v1/chat/groups/${options.chatId}/config',
    data: body,
  );

  if (result == null || result is String) {
    throw Exception(result);
  }

  return GroupDTO.fromJson(result);
}
