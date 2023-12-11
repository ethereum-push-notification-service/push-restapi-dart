import '../../../../push_restapi_dart.dart';

class GroupInfoDTO {
  String groupName;
  String? groupImage;
  String groupDescription;
  bool isPublic;
  String groupCreator;
  String chatId;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  String? groupType;
  ChatStatus? status;
  dynamic rules;
  String? meta;
  String? sessionKey;
  String? encryptedSecret;

  GroupInfoDTO({
    required this.groupName,
    this.groupImage,
    required this.groupDescription,
    required this.isPublic,
    required this.groupCreator,
    required this.chatId,
    this.scheduleAt,
    this.scheduleEnd,
    this.groupType,
    this.status,
    this.rules,
    this.meta,
    this.sessionKey,
    this.encryptedSecret,
  });

  factory GroupInfoDTO.fromJson(Map<String, dynamic> json) {
    return GroupInfoDTO(
      groupName: json['groupName'],
      groupImage: json['groupImage'],
      groupDescription: json['groupDescription'],
      isPublic: json['isPublic'],
      groupCreator: json['groupCreator'],
      chatId: json['chatId'],
      scheduleAt: json['scheduleAt'] != null
          ? DateTime.parse(json['scheduleAt'])
          : null,
      scheduleEnd: json['scheduleEnd'] != null
          ? DateTime.parse(json['scheduleEnd'])
          : null,
      groupType: json['groupType'],
      status:
          json['status'] != null ? chatStatusFromString(json['status']) : null,
      rules: json['rules'],
      meta: json['meta'],
      sessionKey: json['sessionKey'],
      encryptedSecret: json['encryptedSecret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'groupImage': groupImage,
      'groupDescription': groupDescription,
      'isPublic': isPublic,
      'groupCreator': groupCreator,
      'chatId': chatId,
      'scheduleAt': scheduleAt?.toIso8601String(),
      'scheduleEnd': scheduleEnd?.toIso8601String(),
      'groupType': groupType,
      'rules': rules,
      'status': chatStringFromChatStatus(status),
      'meta': meta,
      'sessionKey': sessionKey,
      'encryptedSecret': encryptedSecret,
    };
  }
}
