import '../../../push_restapi_dart.dart';

Future<GroupDTO?> updateGroup({
  required String chatId,
  String? account,
  Signer? signer,
  required String groupName,
  required String groupDescription,
  String? groupImage,
  required List<String> members,
  required List<String> admins,
  required bool isPublic,
  String? pgpPrivateKey,
  String? meta,
  DateTime? scheduleAt,
  DateTime? scheduleEnd,
  ChatStatus? status,
  Map<String, dynamic>? rules,
}) async {
  return updateGroupCore(
    chatId: chatId,
    groupName: groupName,
    groupDescription: groupDescription,
    members: members,
    admins: admins,
    isPublic: isPublic,
    account: account,
    groupImage: groupImage,
    meta: meta,
    pgpPrivateKey: pgpPrivateKey,
    rules: rules,
    scheduleAt: scheduleAt,
    scheduleEnd: scheduleEnd,
    signer: signer,
    status: status,
  );
}

Future<GroupDTO?> updateGroupCore({
  required String chatId,
  String? account,
  Signer? signer,
  required String groupName,
  required String groupDescription,
  String? groupImage,
  required List<String> members,
  required List<String> admins,
  required bool isPublic,
  String? pgpPrivateKey,
  String? meta,
  DateTime? scheduleAt,
  DateTime? scheduleEnd,
  ChatStatus? status,
  Map<String, dynamic>? rules,
}) async {
  try {
    account ??= getCachedWallet()?.address;
    signer ??= getCachedWallet()?.signer;
    pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }

    final wallet = getWallet(address: account, signer: signer);
    String userDID = getAccountAddress(wallet);

    updateGroupRequestValidator(
      chatId,
      groupName,
      groupDescription,
      groupImage,
      members,
      admins,
      userDID,
    );

    final connectedUser = await getConnectedUserV2(
      wallet: wallet,
      privateKey: pgpPrivateKey,
    );

    final convertedMembers =
        await Future.wait(members.map((item) => getUserDID(address: item)));
    final convertedAdmins =
        await Future.wait(admins.map((item) => getUserDID(address: item)));

    final groupChat = await getGroup(chatId: chatId);

    // Compare members array with updateGroup.members array. If they have all the same elements then return true
    final updatedParticipants =
        Set.from(convertedAdmins.map((e) => e.toLowerCase()));

    final participantStatus =
        await getGroupMemberStatus(chatId: chatId, did: connectedUser.did!);

    var sameMembers = true;

    for (var member in groupChat.members) {
      if (!updatedParticipants.contains(member.wallet.toLowerCase())) {
        sameMembers = false;
      }
    }

    String? encryptedSecret;
    if ((!sameMembers || !participantStatus.isMember) && !groupChat.isPublic) {
      final secretKey = generateRandomSecret(15);
      var publicKeys = <String>[];

      // This will now only take keys of non-removed members
      for (var member in groupChat.members) {
        if (updatedParticipants.contains(member.wallet.toLowerCase())) {
          publicKeys.add(member.publicKey!);
        }
      }

      // This is autoJoin Case
      if (!participantStatus.isMember) {
        publicKeys.add(connectedUser.publicKey!);
      }

      // Encrypt secret key with group members public keys
      encryptedSecret =
          await pgpEncrypt(plainText: secretKey, keys: publicKeys);
    }

    final bodyToBeHashed = {
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupImage': groupImage,
      'members': convertedMembers,
      'admins': convertedAdmins,
      'chatId': chatId,
    };

    final hash = generateHash(bodyToBeHashed);

    final signature = await sign(
      message: hash,
      privateKey: connectedUser.privateKey!,
    );

    final sigType = 'pgp';
    final verificationProof = '$sigType:$signature:$userDID';

    final body = {
      'groupName': groupName,
      'groupImage': groupImage,
      'groupDescription': groupDescription,
      'members': convertedMembers,
      'admins': convertedAdmins,
      'address': 'eip155:$userDID',
      'verificationProof': verificationProof,
      'encryptedSecret': encryptedSecret,
      'scheduleAt': scheduleAt?.toIso8601String(),
      'scheduleEnd': scheduleEnd?.toIso8601String(),
      if (meta != null) 'meta': meta,
      if (status != null) 'status': chatStringFromChatStatus(status),
      if (rules != null) 'rules': rules,
    };

    final result = await http.put(
      path: '/v1/chat/groups/$chatId',
      data: body,
    );

    if (result == null || result is String) {
      return null;
    }

    return GroupDTO.fromJson(result);
  } catch (e) {
    log("[Push SDK] - API  - Error - API updateGroup -: $e ");
    rethrow;
  }
}
