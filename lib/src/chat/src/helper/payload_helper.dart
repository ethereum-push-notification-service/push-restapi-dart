import 'dart:convert';

import '../../../../push_restapi_dart.dart';

Future<SendMessagePayload> sendMessagePayloadCore({
  required String receiverAddress,
  required ConnectedUser senderConnectedUser,
  String? senderAddress,
  String? senderPgpPrivateKey,
  required String messageType,
  required String messageContent,
  dynamic messageObj,
  GroupInfoDTO? group,
  required bool isGroup,
}) async {
  late String secretKey;
  if (isGroup && group?.encryptedSecret != null && group?.sessionKey != null) {
    secretKey = await pgpDecrypt(
        cipherText: group!.encryptedSecret!,
        privateKeyArmored: senderConnectedUser.privateKey!);
  } else {
    secretKey = generateRandomSecret(15);
  }

  final encryptedMessageContentData = await getEncryptedRequestCore(
    receiverAddress: receiverAddress,
    message: messageContent,
    isGroup: isGroup,
    group: group,
    secretKey: secretKey,
    senderConnectedUser: senderConnectedUser,
  );

  final encryptedMessageContent = encryptedMessageContentData.message;
  final deprecatedSignature =
      removeVersionFromPublicKey(encryptedMessageContentData.signature);

  final encryptedMessageObjData = await getEncryptedRequestCore(
    receiverAddress: receiverAddress,
    message: jsonEncode(messageObj?.toJson()),
    senderConnectedUser: senderConnectedUser,
    isGroup: isGroup,
    group: group,
    secretKey: secretKey,
  );

  final encryptedMessageObj = encryptedMessageObjData.message;
  final encryptionType = encryptedMessageObjData.encryptionType;
  final encryptedMessageObjSecret =
      removeVersionFromPublicKey(encryptedMessageObjData.aesEncryptedSecret);

  return SendMessagePayload(
    fromDID: walletToPCAIP10(senderAddress!),
    toDID: !isGroup ? walletToPCAIP10(receiverAddress) : group?.chatId ?? '',
    fromCAIP10: walletToPCAIP10(senderAddress),
    toCAIP10: !isGroup ? walletToPCAIP10(receiverAddress) : group?.chatId ?? '',
    messageContent: encryptedMessageContent,
    messageObj: encryptionType == 'PlainText'
        ? messageObj?.toJson()
        : encryptedMessageObj,
    messageType: messageType,
    signature: deprecatedSignature,
    verificationProof: "pgp:$deprecatedSignature",
    encType: encryptionType,
    encryptedSecret: encryptedMessageObjSecret,
    sigType: "pgp",
  );
}
