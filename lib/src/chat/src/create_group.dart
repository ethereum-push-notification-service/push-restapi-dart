import '../../../push_restapi_dart.dart';

Future<GroupDTO?> createGroup({
  String? account,
  Signer? signer,
  required String groupName,
  required String groupDescription,
  String? groupImage,
  required List<String> members,
  required List<String> admins,
  required bool isPublic,
  String? contractAddressNFT,
  int? numberOfNFTs,
  String? contractAddressERC20,
  int? numberOfERC20,
  String? pgpPrivateKey,
  String? meta,
  String? groupType,
  DateTime? scheduleAt,
  DateTime? scheduleEnd,
}) async {
  try {
    account ??= getCachedWallet()?.address;
    signer ??= getCachedWallet()?.signer;
    pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }
    final wallet = getWallet(address: account, signer: signer);
    String address = getAccountAddress(wallet);

    createGroupRequestValidator(
        groupName: groupName,
        groupDescription: groupDescription,
        members: members,
        admins: admins);

    final convertedMembersDIDList =
        await Future.wait(members.map((item) => getUserDID(address: item)));
    final convertedAdminsDIDList =
        await Future.wait(admins.map((item) => getUserDID(address: item)));

    final connectedUser = await getConnectedUserV2(
      wallet: wallet,
      privateKey: pgpPrivateKey,
    );
    final bodyToBeHashed = {
      'groupName': groupName,
      'groupDescription': groupDescription,
      'members': convertedMembersDIDList,
      'groupImage': groupImage,
      'admins': convertedAdminsDIDList,
      'isPublic': isPublic,
      'contractAddressNFT': contractAddressNFT,
      'numberOfNFTs': numberOfNFTs ?? 0,
      'contractAddressERC20': contractAddressERC20,
      'numberOfERC20': numberOfERC20 ?? 0,
      'groupCreator': "eip155:$address",
    };

    final hash = generateHash(bodyToBeHashed);
    final signature = await sign(
      message: hash,
      privateKey: connectedUser.privateKey!,
    );

    const sigType = 'pgp';

    final String verificationProof = '$sigType:$signature';

    groupType ??= "default";

    final body = {
      'groupName': groupName,
      'groupDescription': groupDescription,
      'members': convertedMembersDIDList,
      'groupImage': groupImage,
      'admins': convertedAdminsDIDList,
      'isPublic': isPublic,
      'contractAddressNFT': contractAddressNFT,
      'numberOfNFTs': numberOfNFTs ?? 0,
      'contractAddressERC20': contractAddressERC20,
      'numberOfERC20': numberOfERC20 ?? 0,
      'groupCreator': "eip155:$address",
      'verificationProof': verificationProof,
      'groupType': groupType,
      'scheduleAt': scheduleAt?.toIso8601String(),
      'scheduleEnd': scheduleEnd?.toIso8601String(),
    };
    if (meta != null) {
      body['meta'] = meta;
    }

    final result = await http.post(
      path: '/v1/chat/groups',
      data: body,
    );

    if (result == null) {
      throw Exception(result);
    }
    return GroupDTO.fromJson(result);
  } catch (e) {
    log("[Push SDK] - API  - Error - API createGroup -: $e ");
    rethrow;
  }
}
