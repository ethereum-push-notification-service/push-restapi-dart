import 'dart:convert';

import '../../../push_restapi_dart.dart';

class ChatSendOptions {
  SendMessage? message;
  String? messageContent;
  String? messageType;
  String receiverAddress;
  String? accountAddress;
  String? pgpPrivateKey;

  ChatSendOptions(
      {this.message,
      this.messageContent,
      this.messageType,
      required this.receiverAddress,
      this.accountAddress,
      this.pgpPrivateKey}) {
    assert(MessageType.isValidMessageType(
        message?.type ?? messageType ?? MessageType.TEXT));
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message?.toJson(),
      'messageContent': messageContent,
      'messageType': messageType,
      'receiverAddress': receiverAddress,
      'accountAddress': accountAddress,
      'pgpPrivateKey': pgpPrivateKey
    };
  }
}

Future<MessageWithCID?> send(ChatSendOptions options) async {
  ComputedOptions computedOptions = computeOptions(options);

  computedOptions.accountAddress ??= getCachedWallet()?.address;
  if (computedOptions.accountAddress == null) {
    throw Exception('Account address is required.');
  }

  final isValidGroup = isGroup(computedOptions.to);
  final group =
      isValidGroup ? await getGroup(chatId: computedOptions.to) : null;

  if (isValidGroup && group == null) {
    throw Exception(
        'Invalid receiver. Please ensure \'receiver\' is a valid DID or ChatId in case of Group.');
  }

  final conversationHashResponse = await conversationHash(
    conversationId: computedOptions.to,
    accountAddress: computedOptions.accountAddress!,
  );

  if (!isValidETHAddress(computedOptions.accountAddress!)) {
    throw Exception('Invalid address ${computedOptions.accountAddress}');
  }

  computedOptions.pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;
  if (computedOptions.pgpPrivateKey == null) {
    throw Exception('Private Key is required.');
  }

  bool isIntent = !isValidGroup && conversationHashResponse == null;
  await validateSendOptions(computedOptions);

  try {
    final senderAcount =
        await getUser(address: computedOptions.accountAddress!);

    if (senderAcount == null) {
      throw Exception('Cannot get sender account.');
    }

    final senderPublicKey = getPublicKeyFromString(senderAcount.publicKey!);

    String messageContent;
    if (computedOptions.messageType == MessageType.REPLY ||
        computedOptions.messageType == MessageType.COMPOSITE) {
      messageContent =
          'MessageType Not Supported by this sdk version. Plz upgrade !!!';
    } else {
      messageContent = computedOptions.messageObj?.content;
    }

    final sendMessagePayload = await getSendMessagePayload(
        receiverAddress: computedOptions.to,
        senderPublicKey: senderPublicKey,
        senderPgpPrivateKey: computedOptions.pgpPrivateKey,
        senderAddress: computedOptions.accountAddress,
        messageType: computedOptions.messageType,
        messageContent: messageContent,
        messageObj: computedOptions.messageObj,
        group: group,
        isValidGroup: isValidGroup);

    return sendMessageService(sendMessagePayload, isIntent);
  } catch (e) {
    log('[Push SDK] - API  - Error - API $e');
    rethrow;
  }
}

Future<MessageWithCID?> sendMessageService(
    SendMessagePayload payload, bool isIntent) async {
  try {
    String apiRoute;
    if (isIntent) {
      apiRoute = '/v1/chat/request';
    } else {
      apiRoute = '/v1/chat/message';
    }
    final result = await http.post(path: apiRoute, data: payload.toJson());
    if (result == null || result is String) {
      return null;
    }
    return MessageWithCID.fromJson(result);
  } catch (e) {
    log("[Push SDK] - API $e");
    rethrow;
  }
}

validateSendOptions(ComputedOptions options) async {
  if (options.accountAddress == null) {
    throw Exception('Account address is required.');
  }

  if (!isValidETHAddress(options.accountAddress!)) {
    throw Exception('Invalid address ${options.accountAddress}');
  }

  if (options.pgpPrivateKey == null) {
    throw Exception('Private Key is required.');
  }

  if (options.messageType != MessageType.COMPOSITE &&
      options.messageType != MessageType.REPLY &&
      options.messageObj?.content.isEmpty) {
    throw Exception('Cannot send empty message');
  }

  // TODO: Validate message object
}

Future<SendMessagePayload> getSendMessagePayload({
  required String receiverAddress,
  String? senderAddress,
  String? senderPgpPrivateKey,
  required String senderPublicKey,
  required String messageType,
  required String messageContent,
  dynamic messageObj,
  GroupDTO? group,
  required bool isValidGroup,
}) async {
  final secretKey = generateRandomSecret(15);

  final encryptedMessageContentData = await getEncryptedRequest(
      receiverAddress: receiverAddress,
      senderPublicKey: senderPublicKey,
      senderPgpPrivateKey: senderPgpPrivateKey!,
      message: messageContent,
      isGroup: isValidGroup,
      group: group,
      secretKey: secretKey);
  final encryptedMessageContent = encryptedMessageContentData.message;
  final deprecatedSignature =
      removeVersionFromPublicKey(encryptedMessageContentData.signature);

  final encryptedMessageObjData = await getEncryptedRequest(
      receiverAddress: receiverAddress,
      senderPublicKey: senderPublicKey,
      senderPgpPrivateKey: senderPgpPrivateKey,
      message: jsonEncode(messageObj?.toJson()),
      isGroup: isValidGroup,
      group: group,
      secretKey: secretKey);
  final encryptedMessageObj = encryptedMessageObjData.message;
  final encryptionType = encryptedMessageObjData.encryptionType;
  final encryptedMessageObjSecret =
      removeVersionFromPublicKey(encryptedMessageObjData.aesEncryptedSecret);

  return SendMessagePayload(
      fromDID: walletToPCAIP10(senderAddress!),
      toDID: !isValidGroup
          ? walletToPCAIP10(receiverAddress)
          : group?.chatId ?? '',
      fromCAIP10: walletToPCAIP10(senderAddress),
      toCAIP10: !isValidGroup
          ? walletToPCAIP10(receiverAddress)
          : group?.chatId ?? '',
      messageContent: encryptedMessageContent,
      messageObj: encryptionType == 'PlainText'
          ? messageObj?.toJson()
          : encryptedMessageObj,
      messageType: messageType,
      signature: deprecatedSignature,
      verificationProof: "pgp:$deprecatedSignature",
      encType: encryptionType,
      encryptedSecret: encryptedMessageObjSecret,
      sigType: "pgp");
}

class ComputedOptions {
  String messageType;
  dynamic messageObj;
  String to;
  String? accountAddress;
  String? pgpPrivateKey;

  ComputedOptions(
      {required this.messageType,
      required this.to,
      this.messageObj,
      this.accountAddress,
      this.pgpPrivateKey});

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'messageObj': messageObj,
      'to': to,
      'accountAddress': accountAddress,
      'pgpPrivateKey': pgpPrivateKey
    };
  }
}

class _Content {
  String content;

  _Content({
    required this.content,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    return data;
  }

  static _Content fromJson(Map<String, dynamic> json) {
    return _Content(
      content: json['content'],
    );
  }
}

class _NestedContent {
  String messageType;
  _Content messageObj;

  _NestedContent({
    required this.messageType,
    required this.messageObj,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageType'] = messageType;
    data['messageObj'] = messageObj.toJson();
    return data;
  }

  static _NestedContent fromJson(Map<String, dynamic> json) {
    return _NestedContent(
      messageType: json['messageType'],
      messageObj: _Content.fromJson(json['messageObj']),
    );
  }

  static _NestedContent fromNestedContent(NestedContent nestedContent) {
    return _NestedContent(
        messageType: nestedContent.type,
        messageObj: _Content(content: nestedContent.content));
  }
}

ComputedOptions computeOptions(ChatSendOptions options) {
  log('computeOptions method - options $options');
  String messageType =
      options.message?.type ?? options.messageType ?? MessageType.TEXT;
  dynamic messageObj = options.message;

  if (messageObj == null) {
    if (![
      MessageType.TEXT,
      MessageType.IMAGE,
      MessageType.FILE,
      MessageType.MEDIA_EMBED,
      MessageType.GIF
    ].contains(messageType)) {
      throw Exception('Options.message is required');
    } else if (options.messageContent != null) {
      // use messageContent for backwards compatibility
      messageObj = SendMessage(
        content: options.messageContent!,
        type: messageType,
      );
    }
  }

  String to = options.receiverAddress;
  if (to.isEmpty) {
    throw Exception('Options.to is required');
  }

  // Parse Reply Message
  if (messageType == MessageType.REPLY) {
    if (messageObj?.replyContent != null) {
      messageObj?.replyContent =
          _NestedContent.fromNestedContent(messageObj.replyContent);
    } else {
      throw Exception('Options.message is not properly defined for Reply');
    }
  }

  // Parse Composite Message
  if (messageType == MessageType.COMPOSITE) {
    if (messageObj?.compositeContent != null) {
      messageObj?.compositeContent =
          messageObj?.compositeContent?.map((nestedContent) {
        log("FROM NESTED CONTENT ${_NestedContent.fromNestedContent(nestedContent)}");
        return _NestedContent.fromNestedContent(nestedContent);
      });
    } else {
      throw Exception('Options.message is not properly defined for Composite');
    }
  }

  return ComputedOptions(
      messageType: messageType,
      messageObj: messageObj,
      to: to,
      accountAddress: options.accountAddress,
      pgpPrivateKey: options.pgpPrivateKey);
}
