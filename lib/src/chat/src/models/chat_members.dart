import '../../../../push_restapi_dart.dart';

class GroupMemberRole {
  static const admin = "admin";
  static const member = "member";

  static bool isValidRole(String role) {
    return [member, admin].contains(role);
  }
}

class ChatMemberProfile {
  String address;
  bool intent;
  String role;
  UserV2? userInfo;

  ChatMemberProfile({
    required this.address,
    required this.intent,
    required this.role,
    required this.userInfo,
  }) {
    if (!GroupMemberRole.isValidRole(role)) {
      throw Exception('Invalid role');
    }
  }

  factory ChatMemberProfile.fromJson(Map<String, dynamic> json) {
    return ChatMemberProfile(
      address: json['address'],
      intent: json['intent'],
      role: json['role'],
      userInfo:
          json['userInfo'] == null ? null : UserV2.fromJson(json['userInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'intent': intent,
      'role': role,
      'userInfo': userInfo?.toJson(),
    };
  }
}

class UserV2 {
  int msgSent;
  int maxMsgPersisted;
  String did;
  String wallets;
  UserProfile profile;
  String? encryptedPrivateKey;
  String? publicKey;
  String? verificationProof;
  String? origin;

  UserV2({
    required this.msgSent,
    required this.maxMsgPersisted,
    required this.did,
    required this.wallets,
    required this.profile,
    this.encryptedPrivateKey,
    this.publicKey,
    this.verificationProof,
    this.origin,
  });

  factory UserV2.fromJson(Map<String, dynamic> json) {
    return UserV2(
      msgSent: json['msgSent'],
      maxMsgPersisted: json['maxMsgPersisted'],
      did: json['did'],
      wallets: json['wallets'],
      profile: UserProfile.fromJson(json['profile']),
      encryptedPrivateKey: json['encryptedPrivateKey'],
      publicKey: json['publicKey'],
      verificationProof: json['verificationProof'],
      origin: json['origin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msgSent': msgSent,
      'maxMsgPersisted': maxMsgPersisted,
      'did': did,
      'wallets': wallets,
      'profile': profile.toJson(),
      'encryptedPrivateKey': encryptedPrivateKey,
      'publicKey': publicKey,
      'verificationProof': verificationProof,
      'origin': origin,
    };
  }
}
