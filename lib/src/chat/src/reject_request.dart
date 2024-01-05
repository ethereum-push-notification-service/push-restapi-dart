import 'package:push_restapi_dart/push_restapi_dart.dart';

/// Reject Chat Request
Future<String?> reject({
  required String senderAddress,
  String? account,
  Signer? signer,
  String? pgpPrivateKey,
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

    /**
     * GENERATE VERIFICATION PROOF
     */

    // pgp is used for public grps & w2w
    // pgpv2 is used for private grps
    var sigType = 'pgp';

    final bodyToBeHashed = {
      "fromDID": fromDID,
      "toDID": toDID,
    };

    final hash = generateHash(bodyToBeHashed);

    final signature = await sign(
      message: hash,
      privateKey: connectedUser.privateKey!,
    );

    final body = {
      "fromDID": fromDID,
      "toDID": toDID,
      "verificationProof": '$sigType:$signature',
    };

    final result = await http.put(
      path: '/v1/chat/request/reject',
      data: body,
      skipJsonDecode: true,
    );

    if (result == null) {
      throw Exception(isGroup
          ? 'Unanable to reject $senderAddress group invite'
          : 'Unable to reject request from $senderAddress');
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
