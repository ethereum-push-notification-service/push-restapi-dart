import '../../../push_restapi_dart.dart';

class ModifyRolesType {
  String chatId;
  String newRole;
  List<String> members;
  String? account;
  Signer? signer;
  String? pgpPrivateKey;
  bool? overrideSecretKeyGeneration;

  ModifyRolesType({
    required this.chatId,
    required this.newRole,
    this.members = const <String>[],
    this.account,
    this.signer,
    this.pgpPrivateKey,
    this.overrideSecretKeyGeneration,
  });
}

Future<GroupInfoDTO?> modifyRoles({required ModifyRolesType options}) async {
  if (options.account == null && options.signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }

  if (options.members.isEmpty) {
    throw Exception('Members array cannot be empty!');
  }

  final upsertPayload = UpsertDTO(
    members: options.newRole == 'MEMBER' ? options.members : [],
    admins: options.newRole == 'ADMIN' ? options.members : [],
  );

  return updateGroupMembers(
    chatId: options.chatId,
    account: options.account,
    pgpPrivateKey: options.pgpPrivateKey,
    upsert: upsertPayload,
    signer: options.signer,
  );
}
