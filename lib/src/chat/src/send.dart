import '../../../push_restapi_dart.dart';

Future<MessageWithCID?> send(ChatSendOptions options) async {
  final computedOptions = computeOptions(options);

  computedOptions.account ??= getCachedWallet()?.address;
  computedOptions.signer ??= getCachedWallet()?.signer;
  computedOptions.pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

  /**
   * Validate Input Options
   */
  await validateSendOptions(computedOptions);

  final wallet = getWallet(
      address: computedOptions.account, signer: computedOptions.signer);
  final connectedUser = await getConnectedUserV2(
    wallet: wallet,
    privateKey: options.pgpPrivateKey,
  );

  final isGroup = !isValidETHAddress(computedOptions.to);
  final group = isGroup ? await getGroupInfo(chatId: computedOptions.to) : null;

  final conversationHashResponse = await conversationHash(
    conversationId: computedOptions.to,
    accountAddress: computedOptions.account!,
  );

  bool isIntent = !isGroup && conversationHashResponse == null;

  try {
    final senderAcount = await getUser(address: computedOptions.account!);

    if (senderAcount == null) {
      throw Exception('Cannot get sender account.');
    }

    String messageContent;
    if (computedOptions.messageType == MessageType.REPLY ||
        computedOptions.messageType == MessageType.COMPOSITE) {
      messageContent =
          'MessageType Not Supported by this sdk version. Plz upgrade !!!';
    } else {
      messageContent = computedOptions.messageObj?.content;
    }

    final sendMessagePayload = await sendMessagePayloadCore(
      senderConnectedUser: connectedUser,
      receiverAddress: computedOptions.to,
      senderPgpPrivateKey: computedOptions.pgpPrivateKey,
      senderAddress: computedOptions.account,
      messageType: computedOptions.messageType,
      messageContent: messageContent,
      messageObj: computedOptions.messageObj,
      group: group,
      isGroup: isGroup,
    );

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

  static _NestedContent fromNestedContent(NestedContent nestedContent) {
    return _NestedContent(
        messageType: nestedContent.type,
        messageObj: _Content(content: nestedContent.content));
  }
}

ComputedOptions computeOptions(ChatSendOptions options) {
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

  String to = options.to;
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
    account: options.account,
    signer: options.signer,
    pgpPrivateKey: options.pgpPrivateKey,
  );
}
