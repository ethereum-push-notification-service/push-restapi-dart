// ignore_for_file: constant_identifier_names

import '../../../../push_restapi_dart.dart';

const SIG_TYPE_V2 = 'eip712v2';

Future<List<Feeds>> decryptFeeds({
  required List<Feeds> feeds,
  required User connectedUser,
  required String pgpPrivateKey,
}) async {
  final updatedFeeds = <Feeds>[];

  for (var feed in feeds) {
    final msg = feed.msg!;

    if (msg.encType == 'pgp') {
      feed.msg?.messageContent = await decryptMessage(
        privateKeyArmored: pgpPrivateKey,
        message: msg,
      );
      updatedFeeds.add(feed);
    } else {
      updatedFeeds.add(feed);
    }
  }

  return updatedFeeds;
}

Future<List<SpaceFeeds>> decryptSpaceFeeds({
  required List<SpaceFeeds> feeds,
  required User connectedUser,
  required String pgpPrivateKey,
}) async {
  final updatedFeeds = <SpaceFeeds>[];

  for (var feed in feeds) {
    final msg = feed.msg!;

    if (msg.encType == 'pgp') {
      feed.msg?.messageContent = await decryptMessage(
        privateKeyArmored: pgpPrivateKey,
        message: msg,
      );
      updatedFeeds.add(feed);
    } else {
      updatedFeeds.add(feed);
    }
  }

  return updatedFeeds;
}

Future<String> signMessageWithPGP(
    {required String message,
    required String publicKey,
    required String privateKeyArmored}) async {
  final signature = await sign(
      message: message, publicKey: publicKey, privateKey: privateKeyArmored);
  return signature;
}

Future<Map<String, String>> encryptAndSign({
  required String plainText,
  required List<String> keys,
  required String senderPgpPrivateKey,
  required String publicKey,
}) async {
  final secretKey = generateRandomSecret(32);

  final cipherText =
      await aesEncrypt(plainText: plainText, secretKey: secretKey);

//TODO fix issue in pgpEncrypt function
  final encryptedSecret = await pgpEncrypt(plainText: secretKey, keys: keys);

  final signature = await sign(
      message: cipherText,
      privateKey: senderPgpPrivateKey,
      publicKey: publicKey);

  return {
    'cipherText': cipherText,
    'encryptedSecret': encryptedSecret,
    'signature': signature,
    'sigType': 'pgp',
    'encType': 'pgp',
  };
}

Future<IEncryptedRequest?> getEncryptedRequest({
  required String receiverAddress,
  required ConnectedUser senderCreatedUser,
  required String message,
  required bool isGroup,
  GroupDTO? group,
}) async {
  if (!isGroup) {
    final User? receiverCreatedUser = await getUser(address: receiverAddress);

    if (receiverCreatedUser != null || receiverCreatedUser?.publicKey != null) {
      if (!isValidETHAddress(receiverAddress)) {
        throw Exception('Invalid receiver address!');
      }

      await createUserService(
        user: receiverAddress,
        publicKey: '',
        encryptedPrivateKey: '',
      );
      // If the user is being created here, that means that user don't have a PGP keys. So this intent will be in plaintext

      final signature = await signMessageWithPGP(
        message: message,
        publicKey: senderCreatedUser.publicKey!,
        privateKeyArmored: senderCreatedUser.privateKey!,
      );

      return IEncryptedRequest(
          message: message,
          encryptionType: 'PlainText',
          aesEncryptedSecret: '',
          signature: signature);
    } else {
      // It's possible for a user to be created but the PGP keys still not created

      if (receiverCreatedUser != null &&
          !receiverCreatedUser.publicKey!
              .contains('-----BEGIN PGP PUBLIC KEY BLOCK-----')) {
        final signature = await signMessageWithPGP(
          message: message,
          publicKey: senderCreatedUser.publicKey!,
          privateKeyArmored: senderCreatedUser.privateKey!,
        );

        return IEncryptedRequest(
            message: message,
            encryptionType: 'PlainText',
            aesEncryptedSecret: '',
            signature: signature);
      } else {
        final response = await encryptAndSign(
            plainText: message,
            keys: [
              receiverCreatedUser!.publicKey!,
              senderCreatedUser.publicKey!
            ],
            senderPgpPrivateKey: senderCreatedUser.privateKey!,
            publicKey: senderCreatedUser.publicKey!);

        return IEncryptedRequest(
            message: response['cipherText']!,
            encryptionType: 'pgp',
            aesEncryptedSecret: response['encryptedSecret']!,
            signature: response['signature']!);
      }
    }
  } else if (group != null) {
    if (group.isPublic) {
      final signature = await signMessageWithPGP(
        message: message,
        publicKey: senderCreatedUser.publicKey!,
        privateKeyArmored: senderCreatedUser.privateKey!,
      );

      return IEncryptedRequest(
          message: message,
          encryptionType: 'PlainText',
          aesEncryptedSecret: '',
          signature: signature);
    } else {
      final publicKeys =
          group.members.map((member) => member.publicKey).toList();

      final response = await encryptAndSign(
          plainText: message,
          keys: publicKeys as List<String>,
          senderPgpPrivateKey: senderCreatedUser.privateKey!,
          publicKey: senderCreatedUser.publicKey!);

      return IEncryptedRequest(
          message: response['cipherText']!,
          encryptionType: 'pgp',
          aesEncryptedSecret: response['encryptedSecret']!,
          signature: response['signature']!);
    }
  }
  return null;
}

Future<Map<String, dynamic>> getEip712Signature(
  Wallet wallet,
  String hash,
  bool isDomainEmpty,
) async {
  // final typeInformation = getTypeInformation();

  // TODO: Make chain id dynamic
  int chainId = 2013;

  // final domain = getDomainInformation(chainId);

  // sign a message using EIP712
  // TODO
  final signedMessage = "";

  final verificationProof = isDomainEmpty
      ? '$SIG_TYPE_V2:$signedMessage'
      : '$SIG_TYPE_V2:$chainId:$signedMessage';

  return {'verificationProof': verificationProof};
}

Future<Map<String, dynamic>> getEip191Signature(
  Wallet wallet,
  String message, {
  String version = 'v1',
}) async {
  if (wallet.signer == null) {
    log('This method is deprecated. Provide signer in the function');
    // sending random signature for making it backward compatible
    return {'signature': 'xyz', 'sigType': 'a'};
  }

  // EIP191 signature

  final signature = await wallet.signer?.getEip191Signature(message) ?? "";

  final sigType = version == 'v1' ? 'eip191' : 'eip191v2';
  return {'verificationProof': '$sigType:$signature'};
}

Future<String> getDecryptedPrivateKey({
  required Wallet wallet,
  required User user,
  required String address,
}) async {
  if (wallet.signer != null) {
    return decryptPGPKey(
      encryptedPGPPrivateKey: user.encryptedPrivateKey!,
      wallet: wallet,
    );
  } else {
    throw Exception('Provide signer');
  }
}
