import '../../../push_restapi_dart.dart';

Future<GroupInfoDTO?> updateGroupMembers({
  String? account,
  Signer? signer,
  required String chatId,
  UpsertDTO? upsert,
  List<String> remove = const [],
  String? pgpPrivateKey,
}) async {
  account ??= getCachedWallet()?.address;
  signer ??= getCachedWallet()?.signer;
  pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
  upsert ??= UpsertDTO();

  /**
   * VALIDATIONS
   */
  if (account == null && signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }

  validateGroupMemberUpdateOptions(
    chatId: chatId,
    upsert: upsert,
    remove: remove,
  );

  final wallet = getWallet(address: walletToPCAIP10(account!), signer: signer);
  String userDID = getAccountAddress(wallet);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: pgpPrivateKey,
  );

  final convertedUpsert = {};
  for (var key in upsert.toJson().keys) {
    final userIds = await Future.wait(
      List.generate(
        (upsert.toJson()[key] ?? []).length,
        (index) => getUserDID(address: (upsert!.toJson()[key] ?? [])[index]),
      ),
    );
    convertedUpsert[key] = userIds;
  }

  final convertedRemove = await Future.wait(
    List.generate(remove.length, (index) => getUserDID(address: remove[index])),
  );

  String? encryptedSecret;

  final group = await getGroupInfo(chatId: chatId);

  if (!group.isPublic) {
    if (group.encryptedSecret != null) {
      final isMember =
          (await getGroupMemberStatus(chatId: chatId, did: connectedUser.did!))
              .isMember;

      var groupMembers = await getAllGroupMembersPublicKeys(chatId: chatId);

      final removeParticipantSet =
          convertedRemove.map((e) => e.toLowerCase()).toSet();

      bool sameMembers = true;

      for (var member in groupMembers) {
        if (removeParticipantSet.contains(member.did.toLowerCase())) {
          sameMembers = false;
          break;
        }
      }

      if (!sameMembers || !isMember) {
        final secretKey = generateRandomSecret(15);
        final publicKeys = <String>[];

        // This will now only take keys of non-removed members
        for (var member in groupMembers) {
          if (!removeParticipantSet.contains(member.did.toLowerCase())) {
            publicKeys.add(member.publicKey);
          }
        }

        // This is autoJoin Case
        if (!isMember) {
          publicKeys.add(connectedUser.publicKey!);
        }

        encryptedSecret = await pgpEncrypt(
          plainText: secretKey,
          keys: publicKeys,
        );
      }
    }
  }

  final bodyToBeHashed = {
    "upsert": convertedUpsert,
    "remove": convertedRemove,
    "encryptedSecret": encryptedSecret,
  };

  final hash = generateHash(bodyToBeHashed);

  final signature = await sign(
    message: hash,
    privateKey: connectedUser.privateKey!,
  );

  final sigType = 'pgpv2';
  final deltaVerificationProof =
      '$sigType:$signature:${walletToPCAIP10(userDID)}';

  final body = {
    "upsert": convertedUpsert,
    "remove": convertedRemove,
    "encryptedSecret": encryptedSecret,
    "deltaVerificationProof": deltaVerificationProof,
  };

  final result = await http.put(
    path: '/v1/chat/groups/$chatId/members',
    data: body,
  );

  if (result == null || result is String) {
    throw Exception(result);
  }

  return GroupInfoDTO.fromJson(result);
}
