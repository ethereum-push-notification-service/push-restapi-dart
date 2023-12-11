import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<String?> approve({
  required String senderAddress,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
  String status = 'Approved',
}) async {
  try {
    account ??= getCachedWallet()?.address;
    signer ??= getCachedWallet()?.signer;
    if (account == null && signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }

    final wallet = getWallet(address: account, signer: signer);
    final address = getAccountAddress(wallet);

    pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
    if (pgpPrivateKey == null) {
      throw Exception('Private Key is required.');
    }

    final isGroup = !isValidETHAddress(senderAddress);

    final connectedUser = await getConnectedUserV2(
      wallet: wallet,
      privateKey: pgpPrivateKey,
    );

    late String fromDID, toDID;

    if (isGroup) {
      fromDID = await getUserDID(address: address);
      toDID = await getUserDID(address: senderAddress);
    } else {
      fromDID = await getUserDID(address: senderAddress);
      toDID = await getUserDID(address: address);
    }

    String? encryptedSecret;

    /**
     * GENERATE VERIFICATION PROOF
     */

    // pgp is used for public grps & w2w
    // pgpv2 is used for private grps
    var sigType = 'pgp';

    if (isGroup) {
      final group = await getGroupInfo(chatId: senderAddress);
      if (!group.isPublic) {
        /**
         * Secret Key Gen Override has no effect if an encrypted secret key is already present
         */
        if (group.encryptedSecret != null) {
          sigType = 'pgpv2';
          final secretKey = generateRandomSecret(15);

          final groupMembers = await getAllGroupMembersPublicKeys(
            chatId: group.chatId,
          );

          final publickKeys = groupMembers.map((e) => e.publicKey).toList();
          publickKeys.add(connectedUser.publicKey!);
          encryptedSecret =
              await pgpEncrypt(plainText: secretKey, keys: publickKeys);
        }
      }
    }

    final bodyToBeHashed = {
      "fromDID": fromDID,
      "toDID": toDID,
      "status": status,
      if (sigType == 'pgpv2') 'encryptedSecret': encryptedSecret,
    };
    final hash = generateHash(bodyToBeHashed);

    final signature = await sign(
      message: hash,
      privateKey: connectedUser.privateKey!,
    );

    final body = {
      "fromDID": fromDID,
      "toDID": toDID,
      "signature": signature,
      "status": status,
      "sigType": sigType,
      "verificationProof": '$sigType:$signature',
      'encryptedSecret': encryptedSecret,
    };

    final result = await http.put(
      path: '/v1/chat/request/accept',
      data: body,
      skipJsonDecode: true,
    );

    if (result == null) {
      throw Exception(isGroup
          ? 'Unanable to accept $senderAddress group invite'
          : 'Unable to approve request from $senderAddress');
    }

    //if chat address was returned
    if (result is String) {
      return result;
    }

    return result['data'];
  } catch (e) {
    log(e);
    throw Exception('[Push SDK] - API chats: $e');
  }
}
