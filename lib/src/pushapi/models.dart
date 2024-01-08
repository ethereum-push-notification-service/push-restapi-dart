// ignore_for_file: constant_identifier_names

import '../../push_restapi_dart.dart';

class PushAPIInitializeOptions {
  void Function(ProgressHookType)? progressHook;
  String? account;
  String? version;
  Map<String, Map<String, String>>? versionMeta;
  bool autoUpgrade;
  String? origin;
  bool showHttpLog;

  PushAPIInitializeOptions(
      {this.progressHook,
      this.account,
      this.version = Constants.ENC_TYPE_V3,
      this.versionMeta,
      this.autoUpgrade = true,
      this.origin,
      this.showHttpLog = false});
}

// class ChatListType {
//   static const String CHATS = 'CHATS';
//   static const String REQUESTS = 'REQUESTS';

//   static bool isValidChatListType(String type) {
//     return [CHATS, REQUESTS].contains(type);
//   }
// }

enum ChatListType { CHATS, REQUESTS }

class GroupCreationOptions {
  String description;
  String? image;
  List<String> members;
  List<String> admins;
  bool private;
  dynamic rules;

  GroupCreationOptions({
    required this.description,
    this.image,
    this.members = const <String>[],
    this.admins = const <String>[],
    this.private = false,
    this.rules,
  });
}

class GetGroupParticipantsOptions {
  int page;
  int limit;
  FilterOptions? filter;

  GetGroupParticipantsOptions({
    this.page = 1,
    this.limit = 20,
    this.filter,
  });
}

class FilterOptions {
  bool? pending;
  String? role;

  FilterOptions({
    this.pending,
    this.role,
  });
}

class GroupCountInfo {
  int participants;
  int pending;

  GroupCountInfo({
    required this.participants,
    required this.pending,
  });
}

class ParticipantStatus {
  bool pending;
  String role;
  bool participant;

  ParticipantStatus({
    required this.pending,
    required this.role,
    required this.participant,
  });
}

class GroupUpdateOptions {
  String? name;
  String? description;
  String? image;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  ChatStatus? status;
  String? meta;
  dynamic rules;

  GroupUpdateOptions({
    this.name,
    this.description,
    this.image,
    this.scheduleAt,
    this.scheduleEnd,
    this.status,
    this.meta,
    this.rules,
  });
}
