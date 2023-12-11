import '../../../push_restapi_dart.dart';

Future<GroupInfoDTO> updateGroupProfile({
  String? account,
  Signer? signer,
  required String chatId,
  required String groupName,
  String? groupDescription,
  required String groupImage,
  dynamic rules,
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

  final wallet = getWallet(address: walletToPCAIP10(account!), signer: signer);
  String userDID = getAccountAddress(wallet);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: pgpPrivateKey,
  );

  updateGroupRequestValidator(
    chatId,
    groupName,
    groupDescription ?? '',
    groupImage,
    [],
    [],
    userDID,
  );

  final group = await getGroupInfo(chatId: chatId);

  /**
   * CREATE PROFILE VERIFICATION PROOF
   */
  final bodyToBeHashed = {
    'groupName': groupName,
    'groupDescription': groupDescription ?? group.groupDescription,
    'groupImage': groupImage,
    'rules': rules ?? {},
    "isPublic": group.isPublic,
    "groupType": group.groupType,
  };
  final hash = generateHash(bodyToBeHashed);

  final signature = await sign(
    message: hash,
    privateKey: connectedUser.privateKey!,
  );

  final sigType = 'pgpv2';
  final profileVerificationProof =
      '$sigType:$signature:${walletToPCAIP10(userDID)}';

  final body = {
    'groupName': groupName,
    'groupDescription': groupDescription ?? group.groupDescription,
    'groupImage': groupImage,
    'rules': rules ?? {},
    'profileVerificationProof': profileVerificationProof,
  };

  final result = await http.put(
    path: '/v1/chat/groups/$chatId/profile',
    data: body,
  );

  if (result == null || result is String) {
    throw Exception(result);
  }

  return GroupInfoDTO.fromJson(result);
}
