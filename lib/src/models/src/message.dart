import 'dart:convert';

import 'package:push_restapi_dart/push_restapi_dart.dart';

class Message {
  String fromCAIP10;
  String toCAIP10;
  String fromDID;
  String toDID;
  String messageType;
  String messageContent;
  dynamic messageObj;
  String signature;
  String sigType;
  String? link;
  int? timestamp;
  String encType;
  String encryptedSecret;
  bool? deprecated;
  String? deprecatedCode;
  String? verificationProof;
  String? sessionKey;

  String get displayText {
    var content = '';
    try {
      final contentMap = messageObj["content"];

      if (contentMap is String) {
        content = contentMap;
      } else if (contentMap is Map) {
        content = contentMap['messageObj']['content'];
      }
    } catch (e) {
      content = '$e';
    }
    return content;
  }

  Message? get replyTo {
    try {
      final reference = messageObj['reference'];
      if (reference == null) {
        return null;
      } else {
        return Message.fromJson(jsonDecode(reference));
      }
    } catch (e) {
      return null;
    }
  }

  Message({
    required this.fromCAIP10,
    required this.toCAIP10,
    required this.fromDID,
    required this.toDID,
    required this.messageType,
    required this.messageContent,
    this.messageObj,
    required this.signature,
    required this.sigType,
    this.link,
    this.timestamp,
    required this.encType,
    required this.encryptedSecret,
    this.deprecated,
    this.deprecatedCode,
    this.verificationProof,
    this.sessionKey,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      fromCAIP10: json['fromCAIP10'],
      toCAIP10: json['toCAIP10'],
      fromDID: json['fromDID'],
      toDID: json['toDID'],
      messageType: json['messageType'],
      messageContent: json['messageContent'],
      messageObj: json['messageObj'],
      signature: json['signature'],
      sigType: json['sigType'],
      link: json['link'],
      timestamp: json['timestamp'],
      encType: json['encType'],
      encryptedSecret: json['encryptedSecret'],
      deprecated: json['deprecated'],
      deprecatedCode: json['deprecatedCode'],
      verificationProof: json['verificationProof'],
      sessionKey: json['sessionKey'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['fromCAIP10'] = fromCAIP10;
    data['toCAIP10'] = toCAIP10;
    data['fromDID'] = fromDID;
    data['toDID'] = toDID;
    data['messageType'] = messageType;
    data['messageContent'] = messageContent;
    data['messageObj'] = messageObj;
    data['signature'] = signature;
    data['sigType'] = sigType;
    data['link'] = link;
    data['timestamp'] = timestamp;
    data['encType'] = encType;
    data['encryptedSecret'] = encryptedSecret;
    data['deprecated'] = deprecated;
    data['deprecatedCode'] = deprecatedCode;
    data['verificationProof'] = verificationProof;
    data['sessionKey'] = sessionKey;
    return data;
  }
}

class MessageObject {
  Content? content;
  String? reference;

  MessageObject({this.content, this.reference});

  MessageObject.fromJson(Map<String, dynamic> json) {
    content =
        json['content'] != null ? Content.fromJson(json['content']) : null;
    reference = json['reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    data['reference'] = reference;
    return data;
  }
}

class Content {
  String? messageType;
  MessageObj? messageObj;

  Content({this.messageType, this.messageObj});

  Content.fromJson(Map<String, dynamic> json) {
    messageType = json['messageType'];
    messageObj = json['messageObj'] != null
        ? MessageObj.fromJson(json['messageObj'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['messageType'] = messageType;
    if (messageObj != null) {
      data['messageObj'] = messageObj!.toJson();
    }
    return data;
  }
}

class MessageObj {
  String? content;

  MessageObj({this.content});

  MessageObj.fromJson(Map<String, dynamic> json) {
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content'] = content;
    return data;
  }
}

class MessageWithCID {
  String cid;
  String? chatId;
  String? link;
  String fromCAIP10;
  String toCAIP10;
  String fromDID;
  String toDID;
  String messageType;
  String messageContent;
  String signature;
  String sigType;
  int? timestamp;
  String encType;
  String encryptedSecret;
  String? verificationProof;

  MessageWithCID({
    required this.cid,
    this.chatId,
    this.link,
    required this.fromCAIP10,
    required this.toCAIP10,
    required this.fromDID,
    required this.toDID,
    required this.messageType,
    required this.messageContent,
    required this.signature,
    required this.sigType,
    this.timestamp,
    required this.encType,
    required this.encryptedSecret,
    this.verificationProof,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cid'] = cid;
    data['chatId'] = chatId;
    data['link'] = link;
    data['fromCAIP10'] = fromCAIP10;
    data['toCAIP10'] = toCAIP10;
    data['fromDID'] = fromDID;
    data['toDID'] = toDID;
    data['messageType'] = messageType;
    data['messageContent'] = messageContent;
    data['signature'] = signature;
    data['sigType'] = sigType;
    data['timestamp'] = timestamp;
    data['encType'] = encType;
    data['encryptedSecret'] = encryptedSecret;
    data['verificationProof'] = verificationProof;
    return data;
  }

  static MessageWithCID fromJson(Map<String, dynamic> json) {
    return MessageWithCID(
      cid: json['cid'],
      chatId: json['chatId'],
      link: json['link'],
      fromCAIP10: json['fromCAIP10'],
      toCAIP10: json['toCAIP10'],
      fromDID: json['fromDID'],
      toDID: json['toDID'],
      messageType: json['messageType'],
      messageContent: json['messageContent'],
      signature: json['signature'],
      sigType: json['sigType'],
      timestamp: json['timestamp'],
      encType: json['encType'],
      encryptedSecret: json['encryptedSecret'],
      verificationProof: json['verificationProof'],
    );
  }
}

class NestedContent {
  String type;
  String content;

  NestedContent({
    required this.type,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['content'] = content;
    return data;
  }

  static NestedContent fromJson(Map<String, dynamic> json) {
    return NestedContent(
      type: json['type'],
      content: json['content'],
    );
  }
}

class Info {
  List<String> affected;
  Map<String, dynamic> arbitrary;

  Info({
    required this.affected,
    required this.arbitrary,
  });

  factory Info.fromJson(Map<String, dynamic> map) {
    return Info(
      affected: List<String>.from(map['affected']),
      arbitrary: map['arbitrary'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['affected'] = affected;
    data['arbitrary'] = arbitrary;
    return data;
  }
}

class SendMessage {
  String type;
  String? content;

  /* 
    Note: replyContent, compositeContent are dynamic bcz their types need to change during runtime
    replyContent change from NestedContent to _NestedContent
  */

  // for reply message
  dynamic replyContent;

  // for composite message
  dynamic compositeContent;

  // for meta & user activity message
  Info? info;

  String? reference;

  SendMessage({
    required this.type,
    this.content,
    this.replyContent,
    this.compositeContent,
    this.info,
    this.reference,
  });

  factory SendMessage.fromMap(Map<String, dynamic> map) {
    final messageType = map['type'] as String;
    switch (messageType) {
      case MessageType.TEXT:
      case MessageType.IMAGE:
      case MessageType.FILE:
      case MessageType.MEDIA_EMBED:
      case MessageType.GIF:
        return SendMessage(
          type: messageType,
          content: map['content'] as String,
        );
      case MessageType.META:
        return SendMessage(
          type: messageType,
          content: map['content'] as String,
          info: Info.fromJson(map['info']),
        );
      case MessageType.REACTION:
        return SendMessage(
          type: messageType,
          content: map['content'] as String,
          reference: map['reference'] as String?,
        );
      default:
        throw ArgumentError('Invalid message type: $messageType');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = content;

    if (type == MessageType.META) {
      data['info'] = info?.toJson();
    }

    if (type == MessageType.REACTION) {
      data['reference'] = reference;
    }

    return data;
  }
}

class MetaMessage extends SendMessage {
  MetaMessage({
    required Info info,
    required String content,
  }) : super(type: MessageType.META, content: content, info: info);

  factory MetaMessage.fromJson(Map<String, dynamic> json) {
    return MetaMessage(
      info: Info.fromJson(json['info']),
      content: json['content'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['info'] = info?.toJson();
    data['content'] = content;
    return data;
  }
}

class UserActivityMessage extends SendMessage {
  UserActivityMessage({
    required Info info,
    required String content,
  }) : super(type: MessageType.USER_ACTIVITY, content: content, info: info);

  factory UserActivityMessage.fromJson(Map<String, dynamic> json) {
    return UserActivityMessage(
      info: Info.fromJson(json['info']),
      content: json['content'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['info'] = info?.toJson();
    data['content'] = content;
    return data;
  }
}

class ReactionMessage extends SendMessage {
  ReactionMessage({
    required String content,
    required String reference,
  }) : super(
            type: MessageType.REACTION, content: content, reference: reference);

  factory ReactionMessage.fromJson(Map<String, dynamic> json) {
    return ReactionMessage(
      content: json['content'] as String,
      reference: json['reference'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = content;
    data['reference'] = reference;
    return data;
  }
}

class ReceiptMessage extends SendMessage {
  ReceiptMessage({
    required String content,
    required String reference,
  }) : super(type: MessageType.RECEIPT, content: content, reference: reference);

  factory ReceiptMessage.fromJson(Map<String, dynamic> json) {
    return ReceiptMessage(
      content: json['content'] as String,
      reference: json['reference'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = content;
    data['reference'] = reference;
    return data;
  }
}

class ReplyMessage extends SendMessage {
  ReplyMessage({
    required NestedContent content,
    required String reference,
  }) : super(
            type: MessageType.REPLY,
            replyContent: content,
            reference: reference);

  factory ReplyMessage.fromJson(Map<String, dynamic> json) {
    return ReplyMessage(
      content: NestedContent.fromJson(json['content']),
      reference: json['reference'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = replyContent.toJson();
    data['reference'] = reference;
    return data;
  }
}

class CompositeMessage extends SendMessage {
  CompositeMessage({
    required List<NestedContent> content,
  }) : super(type: MessageType.COMPOSITE, compositeContent: content);

  factory CompositeMessage.fromJson(Map<String, dynamic> json) {
    final List<dynamic> contentJson = json['content'];
    final List<NestedContent> content = contentJson
        .map((dynamic e) => NestedContent.fromJson(e as Map<String, dynamic>))
        .toList();
    return CompositeMessage(content: content);
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = compositeContent.map((e) => e.toJson()).toList();
    return data;
  }
}

/// Represents a message containing an image.
///
/// The image is represented by its data, name, and size.
class ImageMessage extends SendMessage {
  /// Creates a new instance of [ImageMessage].
  ///
  /// [content] is the actual data content of the image encoded in base64 format.
  ///
  /// [name] is the name of the image file.
  ///
  /// [size] is the size of the image file
  ImageMessage({
    required String content,
    String? name,
    String? size,
  }) : super(
          type: MessageType.IMAGE,
          content: jsonEncode({
            'content': content,
            'name': name,
            'size': size,
          }),
        );

  /// Creates a new instance of [ImageMessage] from a JSON map.
  ///
  /// [json] is the JSON map to create the instance from.
  factory ImageMessage.fromJson(Map<String, dynamic> json) {
    return ImageMessage(
      content: json['content'],
      name: json['name'],
      size: json['size'],
    );
  }
}

/// Represents a message containing a file.
///
/// The file is represented by its data, name, type, and size.
class FileMessage extends SendMessage {
  /// Creates a new instance of [FileMessage].
  ///
  /// [content] is the actual data content of the file encoded in base64 format.
  ///
  /// [name] is the name of the file.
  ///
  /// [type] is the MIME type or content type of the file (e.g., text/plain).
  ///
  /// [size] is the size of the file, represented as a string.
  FileMessage({
    required String content,
    String? name,
    String? type,
    String? size,
  }) : super(
          type: MessageType.FILE,
          content: jsonEncode({
            'content': content,
            'name': name,
            'type': type,
            'size': size,
          }),
        );

  /// Creates a new instance of [FileMessage] from a JSON map.
  ///
  /// [json] is the JSON map to create the instance from.
  factory FileMessage.fromJson(Map<String, dynamic> json) {
    return FileMessage(
      content: json['content'],
      name: json['name'],
      type: json['type'],
      size: json['size'],
    );
  }
}
