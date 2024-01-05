import '../../../push_restapi_dart.dart';

class ChatUpdateGroupProfileType {
  String? account;
  Signer? signer;
  String chatId;
  late String groupName;
  String? groupDescription;
  String? groupImage;
  dynamic rules;
  String? pgpPrivateKey;

  ChatUpdateGroupProfileType({
    this.account,
    this.signer,
    required this.chatId,
    required this.groupName,
    this.groupDescription,
    this.groupImage,
    this.rules,
    this.pgpPrivateKey,
  });
}

Future<GroupInfoDTO> updateGroupProfile({
  required ChatUpdateGroupProfileType options,
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

  final wallet = getWallet(
      address: walletToPCAIP10(options.account!), signer: options.signer);
  String userDID = getAccountAddress(wallet);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: options.pgpPrivateKey,
  );

  updateGroupRequestValidator(
    options.chatId,
    options.groupName,
    options.groupDescription ?? '',
    options.groupImage,
    [],
    [],
    userDID,
  );

  final group = await getGroupInfo(chatId: options.chatId);

  /**
   * CREATE PROFILE VERIFICATION PROOF
   */
  final bodyToBeHashed = {
    'groupName': options.groupName,
    'groupDescription': options.groupDescription ?? group.groupDescription,
    'groupImage': options.groupImage,
    'rules': options.rules ?? {},
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
    'groupName': options.groupName,
    'groupDescription': options.groupDescription ?? group.groupDescription,
    'groupImage': options.groupImage,
    'rules': options.rules ?? {},
    'profileVerificationProof': profileVerificationProof,
  };

  final result = await http.put(
    path: '/v1/chat/groups/${options.chatId}/profile',
    data: body,
  );

  if (result == null || result is String) {
    throw Exception(result);
  }

  return GroupInfoDTO.fromJson(result);
}
