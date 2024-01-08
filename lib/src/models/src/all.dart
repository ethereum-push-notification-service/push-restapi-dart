// the type for the the response of the input data to be parsed
// ignore_for_file: constant_identifier_names, empty_constructor_bodies

import '../../../push_restapi_dart.dart';

class ApiNotificationType {
  late int payloadId;
  late String channel;
  late String epoch;
  late Payload payload;
  late String source;
}

class Payload {
  late Apns apns;
  late PayloadData data;
  late Android android;
  late Notification notification;
}

class Apns {
  late ApnsPayload payload;
  late FcmOptions fcmOptions;
}

class ApnsPayload {
  late Aps aps;
}

class Aps {
  late String category;
  late int mutableContent;
  late int contentAvailable;
}

class FcmOptions {
  late String image;
}

class Android {
  late AndroidNotification notification;
}

class AndroidNotification {
  late String icon;
  late String color;
  late String image;
  late bool defaultVibrateTimings;
}

class SendNotificationInputOptions {
  int? senderType;
  dynamic signer;
  NOTIFICATION_TYPE type;
  IDENTITY_TYPE identityType;
  NotificationOptions? notification;
  PayloadOptions? payload;
  dynamic recipients;
  String channel;
  Graph? graph;
  String? ipfsHash;
  String? chatId;
  String? pgpPrivateKey;
  String? pgpPublicKey;

  // Constructor with default values
  SendNotificationInputOptions({
    this.senderType = 0,
    this.signer,
    required this.type,
    required this.identityType,
    this.notification,
    this.payload,
    this.recipients,
    required this.channel,
    this.graph,
    this.ipfsHash,
    this.chatId,
    this.pgpPrivateKey,
    this.pgpPublicKey,
  });
}

class NotificationOptions {
  String title;
  String body;

  NotificationOptions({required this.title, required this.body});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }
}

class PayloadOptions {
  String? sectype; // Used for Secret Notification
  String title; // Payload title
  String body; // Payload body
  String cta; // Click To Action Link
  String img; // Img associated with notif payload
  bool? hidden; // Hidden Notif ( not shown in inbox )
  int? etime; // expiry time
  bool? silent; // silent ( No push back to delivery nodes )
  AdditionalMeta? additionalMeta;

  PayloadOptions(
      {this.sectype,
      required this.title,
      required this.body,
      required this.cta,
      required this.img,
      this.hidden,
      this.etime,
      this.silent,
      this.additionalMeta});

  Map<String, dynamic> toJson() {
    return {
      'sectype': sectype,
      'title': title,
      'body': body,
      'cta': cta,
      'img': img,
      'hidden': hidden,
      'etime': etime,
      'silent': silent,
      'additionalMeta': additionalMeta?.toJson(),
    };
  }
}

class AdditionalMeta {
  String type; // type = `ADDITIONAL_META_TYPE+VERSION` & VERSION > 0
  String data;
  String? domain;

  AdditionalMeta(
      {required this.type, required this.data, this.domain = DEFAULT_DOMAIN});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'domain': domain,
    };
  }
}

class NotificationPayload {
  NotificationOptions notification;
  PayloadData data;
  dynamic recipients;

  NotificationPayload({
    required this.notification,
    required this.data,
    required this.recipients,
  });

  Map<String, dynamic> toJson() {
    return {
      'notification': notification.toJson(),
      'data': data.toJson(),
      'recipients': recipients,
    };
  }
}

class PayloadData {
  late String acta;
  late String aimg;
  late String amsg;
  late String asub;
  late String type;
  late int? etime;
  late bool? hidden;
  late bool? silent;
  late String? sectype;
  AdditionalMeta? additionalMeta;

  PayloadData(
      {required this.acta,
      required this.aimg,
      required this.amsg,
      required this.asub,
      required this.type,
      this.etime,
      this.hidden,
      this.silent,
      this.sectype,
      this.additionalMeta});

  Map<String, dynamic> toJson() {
    return {
      'acta': acta,
      'aimg': aimg,
      'amsg': amsg,
      'asub': asub,
      'type': type,
      'etime': etime,
      'hidden': hidden,
      'silent': silent,
      'sectype': sectype,
      'additionalMeta': additionalMeta?.toJson(),
    };
  }
}

class Graph {
  late String id;
  late int counter;
}

class Member {
  late String wallet;
  late String publicKey;
}

class GroupDTO {
  List<MemberDTO> members;
  List<MemberDTO> pendingMembers;
  String? contractAddressERC20;
  int? numberOfERC20;
  String? contractAddressNFT;
  int? numberOfNFTTokens;
  String? verificationProof;
  String? groupImage;
  String? groupName;
  bool isPublic;
  String? groupDescription;
  String? groupCreator;
  String? chatId;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  String? groupType;
  String? meta;
  ChatStatus? status;

  GroupDTO({
    required this.members,
    required this.pendingMembers,
    this.contractAddressERC20,
    required this.numberOfERC20,
    this.contractAddressNFT,
    required this.numberOfNFTTokens,
    required this.verificationProof,
    this.groupImage,
    required this.groupName,
    required this.isPublic,
    this.groupDescription,
    required this.groupCreator,
    required this.chatId,
    this.scheduleAt,
    this.scheduleEnd,
    required this.groupType,
    this.status,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['members'] = members.map((member) => member.toJson()).toList();
    data['pendingMembers'] =
        pendingMembers.map((member) => member.toJson()).toList();
    data['contractAddressERC20'] = contractAddressERC20;
    data['numberOfERC20'] = numberOfERC20;
    data['contractAddressNFT'] = contractAddressNFT;
    data['numberOfNFTTokens'] = numberOfNFTTokens;
    data['verificationProof'] = verificationProof;
    data['groupImage'] = groupImage;
    data['groupName'] = groupName;
    data['isPublic'] = isPublic;
    data['groupDescription'] = groupDescription;
    data['groupCreator'] = groupCreator;
    data['chatId'] = chatId;
    data['scheduleAt'] = scheduleAt?.toIso8601String();
    data['scheduleEnd'] = scheduleEnd?.toIso8601String();
    data['groupType'] = groupType;
    data['meta'] = meta;
    data['status'] = chatStringFromChatStatus(status);
    return data;
  }

  GroupDTO.fromJson(Map<String, dynamic> json)
      : members = json['members'] == null
            ? []
            : (json['members'] as List)
                .map((member) => MemberDTO.fromJson(member))
                .toList(),
        pendingMembers = json['pendingMembers'] == null
            ? []
            : (json['pendingMembers'] as List)
                .map((member) => MemberDTO.fromJson(member))
                .toList(),
        contractAddressERC20 = json['contractAddressERC20'],
        numberOfERC20 = json['numberOfERC20'],
        contractAddressNFT = json['contractAddressNFT'],
        numberOfNFTTokens = json['numberOfNFTTokens'],
        verificationProof = json['verificationProof'],
        groupImage = json['groupImage'],
        groupName = json['groupName'],
        isPublic = json['isPublic'],
        groupDescription = json['groupDescription'],
        groupCreator = json['groupCreator'],
        chatId = json['chatId'],
        scheduleAt = json['scheduleAt'] != null
            ? DateTime.parse(json['scheduleAt'])
            : null,
        scheduleEnd = json['scheduleEnd'] != null
            ? DateTime.parse(json['scheduleEnd'])
            : null,
        groupType = json['groupType'],
        meta = json['meta'],
        status = json['status'] != null
            ? chatStatusFromString(json['status'])
            : null;
}

class SpaceDTO {
  List<SpaceMemberDTO> members;
  List<SpaceMemberDTO> pendingMembers;
  String? contractAddressERC20;
  int numberOfERC20;
  String? contractAddressNFT;
  int numberOfNFTTokens;
  String verificationProof;
  String? spaceImage;
  String spaceName;
  bool isPublic;
  String? spaceDescription;
  String spaceCreator;
  String spaceId;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  ChatStatus? status;
  String? meta;

  SpaceDTO({
    required this.members,
    required this.pendingMembers,
    this.contractAddressERC20,
    required this.numberOfERC20,
    this.contractAddressNFT,
    required this.numberOfNFTTokens,
    required this.verificationProof,
    this.spaceImage,
    required this.spaceName,
    required this.isPublic,
    this.spaceDescription,
    required this.spaceCreator,
    required this.spaceId,
    this.scheduleAt,
    this.scheduleEnd,
    this.status,
    this.meta,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['members'] = members.map((member) => member.toJson()).toList();
    data['pendingMembers'] =
        pendingMembers.map((member) => member.toJson()).toList();
    data['contractAddressERC20'] = contractAddressERC20;
    data['numberOfERC20'] = numberOfERC20;
    data['contractAddressNFT'] = contractAddressNFT;
    data['numberOfNFTTokens'] = numberOfNFTTokens;
    data['verificationProof'] = verificationProof;
    data['spaceImage'] = spaceImage;
    data['spaceName'] = spaceName;
    data['isPublic'] = isPublic;
    data['spaceDescription'] = spaceDescription;
    data['spaceCreator'] = spaceCreator;
    data['spaceId'] = spaceId;
    data['scheduleAt'] = scheduleAt?.toIso8601String();
    data['scheduleEnd'] = scheduleEnd?.toIso8601String();
    data['status'] = status;
    return data;
  }

  SpaceDTO.fromJson(Map<String, dynamic> json)
      : members = (json['members'] as List)
            .map((member) => SpaceMemberDTO.fromJson(member))
            .toList(),
        pendingMembers = (json['pendingMembers'] as List)
            .map((member) => SpaceMemberDTO.fromJson(member))
            .toList(),
        contractAddressERC20 = json['contractAddressERC20'],
        numberOfERC20 = json['numberOfERC20'],
        contractAddressNFT = json['contractAddressNFT'],
        numberOfNFTTokens = json['numberOfNFTTokens'],
        verificationProof = json['verificationProof'],
        spaceImage = json['spaceImage'],
        spaceName = json['spaceName'],
        isPublic = json['isPublic'],
        spaceDescription = json['spaceDescription'],
        spaceCreator = json['spaceCreator'],
        spaceId = json['spaceId'],
        meta = json['meta'],
        scheduleAt = json['scheduleAt'] != null
            ? DateTime.parse(json['scheduleAt'])
            : null,
        scheduleEnd = json['scheduleEnd'] != null
            ? DateTime.parse(json['scheduleEnd'])
            : null,
        status = json['status'] != null
            ? chatStatusFromString(json['status'])
            : null;
}

class SpaceMemberDTO {
  String wallet;
  String publicKey;
  bool isSpeaker;
  String image;

  SpaceMemberDTO({
    required this.wallet,
    required this.publicKey,
    required this.isSpeaker,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet'] = wallet;
    data['publicKey'] = publicKey;
    data['isSpeaker'] = isSpeaker;
    data['image'] = image;
    return data;
  }

  SpaceMemberDTO.fromJson(Map<String, dynamic> json)
      : wallet = json['wallet'],
        publicKey = json['publicKey'],
        isSpeaker = json['isSpeaker'],
        image = json['image'];
}

class MemberDTO {
  String wallet;
  String? publicKey;
  bool isAdmin;
  String? image;

  MemberDTO({
    required this.wallet,
    required this.publicKey,
    required this.isAdmin,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wallet'] = wallet;
    data['publicKey'] = publicKey;
    data['isAdmin'] = isAdmin;
    data['image'] = image;
    return data;
  }

  MemberDTO.fromJson(Map<String, dynamic> json)
      : wallet = json['wallet'],
        publicKey = json['publicKey'],
        isAdmin = json['isAdmin'],
        image = json['image'];
}

enum ChatStatus {
  ACTIVE,
  PENDING,
  ENDED,
}

ChatStatus chatStatusFromString(String status) {
  switch (status) {
    case 'ACTIVE':
      return ChatStatus.ACTIVE;
    case 'PENDING':
      return ChatStatus.PENDING;
    case 'ENDED':
      return ChatStatus.ENDED;
    default:
      throw ArgumentError('Invalid string for ChatStatus');
  }
}

String? chatStringFromChatStatus(ChatStatus? status) {
  if (status == null) {
    return null;
  }
  switch (status) {
    case ChatStatus.ACTIVE:
      return 'ACTIVE';
    case ChatStatus.PENDING:
      return 'PENDING';
    case ChatStatus.ENDED:
      return 'ENDED';
    default:
      throw ArgumentError('Invalid ChatStatus');
  }
}

class Subscribers {
  late int itemcount;
  late List<String> subscribers;
}

class MessageIPFSWithCID extends Message {
  late String cid;

  MessageIPFSWithCID(
      {required super.fromCAIP10,
      required super.toCAIP10,
      required super.fromDID,
      required super.toDID,
      required super.messageType,
      required super.messageContent,
      required super.signature,
      required super.sigType,
      required super.encType,
      required super.encryptedSecret});
}

class AccountEnvOptionsType extends EnvOptionsType {
  late String account;
}

class ChatOptionsType extends AccountEnvOptionsType {
  String? messageContent;
  String? messageType;
  late String receiverAddress;
  String? pgpPrivateKey;
  late ConnectedUser connectedUser;
  String? apiKey;
}

class ConversationHashOptionsType extends AccountEnvOptionsType {
  late String conversationId;
}

class UserInfo {
  late String wallets;
  late String publicKey;
  late String name;
  late String image;
  late bool isAdmin;
}

class EnvOptionsType {
  String? env;
}

// class WalletType {
//   String? account;
//   Object? signer;
//   // SignerType? signer;
// }

class EncryptedPrivateKeyTypeV1 {}
// class EncryptedPrivateKeyTypeV1 extends EthEncryptedData {}

class EncryptedPrivateKeyTypeV2 {
  late String ciphertext;
  String? version;
  String? salt;
  late String nonce;
  String? preKey;
  EncryptedPrivateKeyTypeV2? encryptedPassword;
}

class EncryptedPrivateKeyModel {
  EncryptedPrivateKeyModel({
    this.ciphertext,
    this.nonce,
    this.version,
    this.encryptedPassword,
    this.ephemPublicKey,
    this.salt,
    this.preKey,
  });
  String? version;
  String? nonce;
  String? ephemPublicKey;
  String? ciphertext;
  String? salt;
  String? preKey;
  dynamic encryptedPassword;

  toJson() {
    return {
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (salt != null) 'salt': salt,
      if (nonce != null) 'nonce': nonce,
      if (version != null) 'version': version,
      if (preKey != null) 'preKey': preKey,
    };
  }

  static EncryptedPrivateKeyModel fromJson(Map<String, dynamic> json) {
    return EncryptedPrivateKeyModel(
      version: json['version'],
      nonce: json['nonce'],
      ephemPublicKey: json['ephemPublicKey'],
      ciphertext: json['ciphertext'],
      salt: json['salt'],
      preKey: json['preKey'],
    );
  }
}

class ProgressHookType {
  String progressId;
  String progressTitle;
  String progressInfo;
  String level;

  ProgressHookType({
    required this.progressId,
    required this.progressTitle,
    required this.progressInfo,
    required this.level,
  });
}

typedef ProgressHookTypeFunction = ProgressHookType Function(
    List<dynamic> args);

class VideoConnectInputOptions {
  late dynamic signalData;
}

class EnableVideoInputOptions {
  late bool state;
}

class EnableAudioInputOptions {
  late bool state;
}
