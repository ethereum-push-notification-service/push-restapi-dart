import '../../../../push_restapi_dart.dart';

class ChatSendOptions {
  SendMessage? message;

  /// @deprecated - Use message.content instead
  String? messageContent;

  /// @deprecated - Use message.type instead
  String? messageType;

  /// Message Receiver's Account ( DID )
  String to;

  /// Message Sender's Account ( DID )
  /// In case account is not provided, it will be derived from signer
  String? account;

  /// Message Sender's Signer
  /// Used for deriving account if not provided
  /// Used for decrypting pgpPrivateKey if not provided
  Signer? signer;

  /// Message Sender's decrypted pgp private key
  /// Used for signing message
  String? pgpPrivateKey;

  ChatSendOptions(
      {this.message,
      this.messageContent,
      this.messageType,
      required this.to,
      this.account,
      this.pgpPrivateKey}) {
    assert(MessageType.isValidMessageType(
        message?.type ?? messageType ?? MessageType.TEXT));
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message?.toJson(),
      'messageContent': messageContent,
      'messageType': messageType,
      'receiverAddress': to,
      'accountAddress': account,
      'pgpPrivateKey': pgpPrivateKey
    };
  }
}

class ComputedOptions {
  String messageType;
  dynamic messageObj;
  String to;
  String? account;
  Signer? signer;
  String? pgpPrivateKey;

  ComputedOptions(
      {required this.messageType,
      required this.to,
      this.signer,
      this.messageObj,
      this.account,
      this.pgpPrivateKey});

  Map<String, dynamic> toJson() {
    return {
      'messageType': messageType,
      'messageObj': messageObj,
      'to': to,
      'accountAddress': account,
      'pgpPrivateKey': pgpPrivateKey
    };
  }
}
