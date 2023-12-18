// ignore_for_file: constant_identifier_names

import '../../../../push_restapi_dart.dart';
import 'pgp.dart' as pgphelper;

const SIG_TYPE_V2 = 'eip712v2';

Future<List<Feeds>> decryptFeeds({
  required List<Feeds> feeds,
  required User connectedUser,
  required String pgpPrivateKey,
}) async {
  User? otherPeer;
  String?
      signatureValidationPubliKey; // To do signature verification, it depends on who has sent the message

  for (final feed in feeds) {
    final message = feed.msg!;
    bool gotOtherPeer = false;

    if (message.encType != 'PlainText') {
      if (message.fromCAIP10 != connectedUser.wallets?.split(',')[0]) {
        if (!gotOtherPeer) {
          otherPeer = await getUser(address: message.fromCAIP10);
          gotOtherPeer = true;
        }
        signatureValidationPubliKey = otherPeer!.publicKey;
      } else {
        signatureValidationPubliKey = connectedUser.publicKey;
      }

      feed.msg = await decryptAndVerifyMessage(
        pgpPublicKey: signatureValidationPubliKey!,
        message: message,
        pgpPrivateKey: pgpPrivateKey,
      );
    }
  }

  return feeds;
}

// TODO: Remove this
Future<List<SpaceFeeds>> decryptSpaceFeeds({
  required List<SpaceFeeds> feeds,
  required User connectedUser,
  required String pgpPrivateKey,
}) async {
  final updatedFeeds = <SpaceFeeds>[];

  for (var feed in feeds) {
    final msg = feed.msg!;

    if (msg.encType != 'PlainText') {
      feed.msg = await decryptAndVerifyMessage(
        pgpPublicKey: connectedUser.publicKey!,
        message: msg,
        pgpPrivateKey: pgpPrivateKey,
      );
      updatedFeeds.add(feed);
    } else {
      updatedFeeds.add(feed);
    }
  }

  return updatedFeeds;
}

Future<String> signMessageWithPGPCore({
  required String message,
  required String privateKeyArmored,
}) async {
  final signature = await sign(
    message: message,
    privateKey: privateKeyArmored,
  );
  return signature;
}

Future<Map<String, String>> encryptAndSignCore({
  required String plainText,
  required List<String> keys,
  required String senderPgpPrivateKey,
  String? secretKey,
}) async {
  secretKey ??= generateRandomSecret(32);

  final cipherText =
      await aesEncrypt(plainText: plainText, secretKey: secretKey);

  final encryptedSecret = await pgpEncrypt(plainText: secretKey, keys: keys);

  final signature = await sign(
    message: cipherText,
    privateKey: senderPgpPrivateKey,
  );

  return {
    'cipherText': cipherText,
    'encryptedSecret': encryptedSecret,
    'signature': signature,
    'sigType': 'pgp',
    'encType': 'pgp',
  };
}

Future<IEncryptedRequest> getEncryptedRequestCore({
  required String receiverAddress,
  required ConnectedUser senderConnectedUser,
  required String message,
  required bool isGroup,
  GroupInfoDTO? group,
  required String secretKey,
}) async {
  if (!isGroup) {
    if (!isValidETHAddress(receiverAddress)) {
      throw Exception('Invalid receiver address!');
    }

    User? receiverCreatedUser = await getUser(address: receiverAddress);

    if (receiverCreatedUser != null || receiverCreatedUser?.publicKey != null) {
      await createUserService(
        user: receiverAddress,
        publicKey: '',
        encryptedPrivateKey: '',
      );

      // If the user is being created here, that means that user don't have a PGP keys. So this intent will be in plaintext

      final signature = await signMessageWithPGPCore(
        message: message,
        privateKeyArmored: senderConnectedUser.privateKey!,
      );

      return IEncryptedRequest(
        message: message,
        encryptionType: 'PlainText',
        aesEncryptedSecret: '',
        signature: signature,
      );
    } else {
      // It's possible for a user to be created but the PGP keys still not created

      if (receiverCreatedUser != null &&
          !receiverCreatedUser.publicKey!
              .contains('-----BEGIN PGP PUBLIC KEY BLOCK-----')) {
        final signature = await signMessageWithPGPCore(
          message: message,
          privateKeyArmored: senderConnectedUser.privateKey!,
        );

        return IEncryptedRequest(
          message: message,
          encryptionType: 'PlainText',
          aesEncryptedSecret: '',
          signature: signature,
        );
      } else {
        final response = await encryptAndSignCore(
          plainText: message,
          keys: [
            receiverCreatedUser!.publicKey!,
            senderConnectedUser.publicKey!
          ],
          senderPgpPrivateKey: senderConnectedUser.privateKey!,
          secretKey: secretKey,
        );

        return IEncryptedRequest(
            message: response['cipherText']!,
            encryptionType: 'pgp',
            aesEncryptedSecret: response['encryptedSecret']!,
            signature: response['signature']!);
      }
    }
  } else if (group != null) {
    if (group.isPublic) {
      final signature = await signMessageWithPGPCore(
        message: message,
        privateKeyArmored: senderConnectedUser.privateKey!,
      );

      return IEncryptedRequest(
          message: message,
          encryptionType: 'PlainText',
          aesEncryptedSecret: '',
          signature: signature);
    } else {
      // Private Groups

      // 1. Private Groups with session keys
      if (group.sessionKey != null && group.encryptedSecret != null) {
        final cipherText = await aesEncrypt(
          plainText: message,
          secretKey: secretKey,
        );

        final signature = await pgphelper.sign(
          message: cipherText,
          privateKey: senderConnectedUser.privateKey!,
        );
        return IEncryptedRequest(
          message: cipherText,
          encryptionType: 'pgpv1:group',
          aesEncryptedSecret: '',
          signature: signature,
        );
      } else {
        final members =
            await getAllGroupMembersPublicKeys(chatId: group.chatId);
        final publicKeys = members.map((e) => e.publicKey).toList();

        final response = await encryptAndSignCore(
          plainText: message,
          keys: publicKeys,
          senderPgpPrivateKey: senderConnectedUser.privateKey!,
          secretKey: secretKey,
        );

        return IEncryptedRequest(
            message: response['cipherText']!,
            encryptionType: 'pgp',
            aesEncryptedSecret: response['encryptedSecret']!,
            signature: response['signature']!);
      }
    }
  } else {
    throw Exception('Error in encryption');
  }
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
