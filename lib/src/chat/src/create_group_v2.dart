import '../../../push_restapi_dart.dart';

class ChatCreateGroupTypeV2 extends EnvOptionsType {
  String? account;
  Signer? signer;
  String? pgpPrivateKey;

  // Profile
  late String groupName;
  late String groupDescription;
  String? groupImage;
  dynamic rules;
  late bool isPublic;
  late String groupType;
  late GroupConfig config;
  late List<String> members;
  late List<String> admins;

  ChatCreateGroupTypeV2({
    this.account,
    this.signer,
    this.pgpPrivateKey,
    required this.groupName,
    required this.groupDescription,
    this.groupImage,
    this.rules,
    required this.isPublic,
    this.groupType = 'default',
    required this.config,
    this.members = const <String>[],
    this.admins = const <String>[],
  });
}

class GroupConfig {
  String? meta;
  DateTime? scheduleAt;
  DateTime? scheduleEnd;
  String? status;

  GroupConfig({
    this.meta,
    this.scheduleAt,
    this.scheduleEnd,
    this.status,
  });
}

Future<GroupInfoDTO?> createGroupV2(
    {required ChatCreateGroupTypeV2 options}) async {
  return createGroupCoreV2(options: options);
}

Future<GroupInfoDTO?> createGroupCoreV2(
    {required ChatCreateGroupTypeV2 options}) async {
  try {
    options.account ??= getCachedWallet()?.address;
    options.signer ??= getCachedWallet()?.signer;
    options.pgpPrivateKey ??= getCachedWallet()?.pgpPrivateKey;

    if (options.account == null && options.signer == null) {
      throw Exception('At least one from account or signer is necessary!');
    }
    final wallet = getWallet(address: options.account, signer: options.signer);
    final connectedUser = await getConnectedUserV2(
      wallet: wallet,
      privateKey: options.pgpPrivateKey,
    );

    /**
     * VALIDATIONS
     */
    createGroupV2OptionsValidator(options: options);

    final convertedMembers = await Future.wait(
        options.members.map((item) => getUserDID(address: item)));
    final convertedAdmins = await Future.wait(
        options.admins.map((item) => getUserDID(address: item)));

    /**
     * PROFILE VERIFICATION PROOF
     */
    final profileVerificationBody = {
      'groupName': options.groupName,
      'groupDescription': options.groupDescription,
      'groupImage': options.groupImage,
      'rules': options.rules ?? {},
      'isPublic': options.isPublic,
      'groupType': options.groupType,
    };

    final profileHash = generateHash(profileVerificationBody);
    final profileSignature = await sign(
      message: profileHash,
      privateKey: connectedUser.privateKey!,
    );

    final profileVerificationProof =
        'pgpv2:$profileSignature:${connectedUser.did}';

    /**
     * CONFIG VERIFICATION PROOF
     */

    final configVerificationBody = {
      'meta': options.config.meta,
      'scheduleAt': options.config.scheduleAt,
      'scheduleEnd': options.config.scheduleEnd,
      'status': options.config.status,
    };

    final configHash = generateHash(configVerificationBody);
    final configSignature = await sign(
      message: configHash,
      privateKey: connectedUser.privateKey!,
    );

    final configVerificationProof =
        'pgpv2:$configSignature:${connectedUser.did}';

    /**
     * IDEMPOTENT VERIFICATION PROOF
     */
    final idempotentVerificationBody = {
      'members': convertedMembers,
      'admins': convertedAdmins,
    };

    final idempotentHash = generateHash(idempotentVerificationBody);
    final idempotentSignature = await sign(
      message: idempotentHash,
      privateKey: connectedUser.privateKey!,
    );
    final String idempotentVerificationProof =
        'pgpv2:$idempotentSignature:${connectedUser.did}';

    final body = {
      'groupName': options.groupName,
      'groupDescription': options.groupDescription,
      'groupImage': options.groupImage,
      'rules': options.rules ?? {},
      'isPublic': options.isPublic,
      'groupType': options.groupType,
      'profileVerificationProof': profileVerificationProof,
      'config': {
        'meta': options.config.meta,
        'scheduleAt': options.config.scheduleAt,
        'scheduleEnd': options.config.scheduleEnd,
        'status': options.config.status,
        'configVerificationProof': configVerificationProof,
      },
      'members': convertedMembers,
      'admins': convertedAdmins,
      'idempotentVerificationProof': idempotentVerificationProof,
    };

    final result = await http.post(
      path: '/v2/chat/groups',
      data: body,
    );

    if (result == null || result is String) {
      throw Exception(result);
    }
    return GroupInfoDTO.fromJson(result);
  } catch (e) {
    log("[Push SDK] - API  - Error - API createGroup -: $e ");
    rethrow;
  }
}

void createGroupV2OptionsValidator({required ChatCreateGroupTypeV2 options}) {
  if (options.groupName.isEmpty) {
    throw Exception('groupName cannot be null or empty');
  }

  if (options.groupName.length > 50) {
    throw Exception('groupName cannot be more than 50 characters');
  }

  if (options.groupDescription.length > 150) {
    throw Exception('groupDescription cannot be more than 150 characters');
  }

  for (int i = 0; i < options.members.length; i++) {
    if (!isValidETHAddress(options.members[i])) {
      throw Exception('Invalid member address!');
    }
  }

  for (int i = 0; i < options.admins.length; i++) {
    if (!isValidETHAddress(options.admins[i])) {
      throw Exception('Invalid admin address!');
    }
  }

  validateScheduleDates(
      scheduleAt: options.config.scheduleAt,
      scheduleEnd: options.config.scheduleEnd);
}
