import 'dart:convert';

import '../../../push_restapi_dart.dart';

class Wallet {
  String? _address;
  Signer? signer;
  String? pgpPrivateKey;

  Wallet({
    String? address,
    this.signer,
    this.pgpPrivateKey,
  }) {
    _address = address;
  }

  String? get address => _address ?? signer?.getAddress();
}

abstract class Signer {
  Future<String> getEip191Signature(String message);
  Future<String> getEip712Signature(String message);
  String getAddress();

  /// Returns the signed-message.
  Future<String> signMessage(String message);
}

class ConnectedUser extends User {
  final String? privateKey;

  ConnectedUser({
    required this.privateKey,
  });

  static ConnectedUser fromUser({required User user, String? privateKey}) {
    var connectedUser = ConnectedUser(privateKey: privateKey);
    connectedUser.did = user.did;
    connectedUser.profile = user.profile;
    connectedUser.name = user.name;
    connectedUser.about = user.about;
    connectedUser.verificationProof = user.verificationProof;
    connectedUser.publicKey = user.publicKey;
    connectedUser.msgSent = user.msgSent;
    connectedUser.maxMsgPersisted = user.maxMsgPersisted;
    connectedUser.wallets = user.wallets;
    connectedUser.encryptedPrivateKey = user.encryptedPrivateKey;
    return connectedUser;
  }
}

class CreateUser extends User {
  final String? decryptedPrivateKey;

  CreateUser({
    required this.decryptedPrivateKey,
  });

  static CreateUser fromUser(
      {required User user, String? decryptedPrivateKey}) {
    var createdUser = CreateUser(decryptedPrivateKey: decryptedPrivateKey);
    createdUser.did = user.did;
    createdUser.profile = user.profile;
    createdUser.name = user.name;
    createdUser.about = user.about;
    createdUser.verificationProof = user.verificationProof;
    createdUser.publicKey = user.publicKey;
    createdUser.msgSent = user.msgSent;
    createdUser.maxMsgPersisted = user.maxMsgPersisted;
    createdUser.wallets = user.wallets;
    createdUser.encryptedPrivateKey = user.encryptedPrivateKey;
    return createdUser;
  }
}

class User {
  int? msgSent;
  int? maxMsgPersisted;
  String? wallets;
  String? encryptedPrivateKey;
  String? publicKey;

  String? verificationProof;
  String? did;
  UserProfile? profile;
  String? name;
  String? about;
  String? profilePicture;
  int? numMsg;
  int? allowedNumMsg;
  String? encryptionType;
  String? signature;
  String? sigType;
  String? encryptedPassword;
  String? nftOwner;
  String? linkedListHash;
  List<dynamic>? nfts;

  User({
    this.did,
    this.profile,
    this.name,
    this.about,
    this.verificationProof,
  });

  User.fromJson(Map<String, dynamic> json) {
    did = json['did'];
    wallets = json['wallets'];
    publicKey = json['publicKey'];
    encryptedPrivateKey = json['encryptedPrivateKey'];
    verificationProof = json['verificationProof'];
    msgSent = json['msgSent'];
    maxMsgPersisted = json['maxMsgPersisted'];
    profile =
        json['profile'] != null ? UserProfile.fromJson(json['profile']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['did'] = did;
    data['wallets'] = wallets;
    data['publicKey'] = publicKey;
    data['encryptedPrivateKey'] = encryptedPrivateKey;
    data['verificationProof'] = verificationProof;
    data['msgSent'] = msgSent;
    data['maxMsgPersisted'] = maxMsgPersisted;
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    return data;
  }

  EncryptedPrivateKeyModel? get parsedPrivateKey {
    if (encryptedPrivateKey == null) {
      return null;
    }
    final jsonDecodePrivateKey = jsonDecode(encryptedPrivateKey!);
    return EncryptedPrivateKeyModel.fromJson(jsonDecodePrivateKey);
  }
}

class UserProfile {
  String? name;
  String? desc;
  String? picture;
  List<String>? blockedUsersList;
  String? profileVerificationProof;

  UserProfile({
    this.name,
    this.desc,
    this.picture,
    this.blockedUsersList,
    this.profileVerificationProof,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      desc: json['desc'],
      picture: json['picture'],
      blockedUsersList: List<String>.from(json['blockedUsersList'] ?? []),
      profileVerificationProof: json['profileVerificationProof'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'picture': picture,
      'blockedUsersList': blockedUsersList,
      'profileVerificationProof': profileVerificationProof,
    };
  }
}
