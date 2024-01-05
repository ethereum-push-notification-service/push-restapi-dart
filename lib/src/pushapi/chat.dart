// ignore_for_file: library_prefixes

import '../../push_restapi_dart.dart';
import '../chat/chat.dart' as PUSH_CHAT;
import '../user/user.dart' as PUSH_USER;

class Chat {
  late final Signer? _signer;

  late final String _account;
  late final String? _decryptedPgpPvtKey;
  void Function(ProgressHookType)? progressHook;

  Chat({
    Signer? signer,
    required String account,
    String? decryptedPgpPvtKey,
    String? pgpPublicKey,
    required this.progressHook,
  }) {
    _signer = signer;
    _account = account;
    _decryptedPgpPvtKey = decryptedPgpPvtKey;

    _userAPI = UserAPI(account: account);
    group = GroupAPI(
        account: account,
        progressHook: progressHook,
        decryptedPgpPvtKey: _decryptedPgpPvtKey,
        pgpPublicKey: pgpPublicKey,
        signer: _signer);
  }

  late final UserAPI _userAPI;
  bool get _hasSigner => _signer != null;

  late final GroupAPI group;

  Future<List<Feeds>?> list({
    required ChatListType type,
    int page = 1,
    int limit = 10,
    String? overrideAccount,
  }) async {
    switch (type) {
      case ChatListType.CHATS:
        return PUSH_CHAT.chats(
          accountAddress: overrideAccount ?? _account,
          limit: limit,
          page: page,
          pgpPrivateKey: _decryptedPgpPvtKey,
          toDecrypt: _hasSigner,
        );
      case ChatListType.REQUESTS:
        return PUSH_CHAT.requests(
          accountAddress: overrideAccount ?? _account,
          limit: limit,
          page: page,
          pgpPrivateKey: _decryptedPgpPvtKey,
          toDecrypt: _hasSigner,
        );
    }
  }

  Future<Message?> latest({required String target}) async {
    final threadHash = await PUSH_CHAT.conversationHash(
      conversationId: target,
      accountAddress: _account,
    );
    if (threadHash == null) {
      return null;
    }

    return PUSH_CHAT.latest(
      threadhash: threadHash,
      accountAddress: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      toDecrypt: _hasSigner,
    );
  }

  Future<List<Message>?> history({
    required String target,
    String? reference,
    int limit = FetchLimit.DEFAULT,
  }) async {
    if (reference == null) {
      final threadHash = await PUSH_CHAT.conversationHash(
        conversationId: target,
        accountAddress: _account,
      );
      reference = threadHash;
    }

    if (reference == null) {
      return [];
    }

    return PUSH_CHAT.history(
      threadhash: reference,
      limit: limit,
      accountAddress: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      toDecrypt: _hasSigner,
    );
  }

  Future<MessageWithCID?> send(
      {required String recipient, required SendMessage options}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final chatOptions = ChatSendOptions(
      to: recipient,
      message: options,
      account: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
    );

    return PUSH_CHAT.send(chatOptions);
  }

  Future<List<Message>> decrypt(
      {required List<Message> messagePayloads}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }
    return PUSH_CHAT.decryptConversation(
      messages: messagePayloads,
      connectedUser: await _userAPI.info(),
      pgpPrivateKey: _decryptedPgpPvtKey!,
    );
  }

  Future<String?> accept({required String target}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }
    return PUSH_CHAT.approve(
      senderAddress: target,
      account: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      signer: _signer,
    );
  }

  Future<String?> reject({required String target}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }
    return PUSH_CHAT.reject(
      senderAddress: target,
      account: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      signer: _signer,
    );
  }

  Future<User?> block({required List<String> users}) async {
    if (!_hasSigner || _decryptedPgpPvtKey == null) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final user = await PUSH_USER.getUser(address: _account);

    for (var element in users) {
      if (!isValidETHAddress(element)) {
        throw Exception('Invalid address in the users: $element');
      }
    }

    if (user!.profile!.blockedUsersList == null) {
      user.profile?.blockedUsersList = [];
    }

    user.profile?.blockedUsersList =
        <String>{...user.profile!.blockedUsersList!, ...users}.toList();

    if (_decryptedPgpPvtKey == null) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    return PUSH_USER.profileUpdate(
      pgpPrivateKey: _decryptedPgpPvtKey!,
      account: _account,
      profile: Profile(
          name: user.profile!.name,
          desc: user.profile!.desc,
          picture: user.profile!.picture,
          blockedUsersList: user.profile?.blockedUsersList),
    );
  }

  Future<User?> unblock({required List<String> users}) async {
    if (!_hasSigner || _decryptedPgpPvtKey == null) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final user = await PUSH_USER.getUser(address: _account);

    for (var element in users) {
      if (!isValidETHAddress(element)) {
        throw Exception('Invalid address in the users: $element');
      }
    }

    if (user!.profile!.blockedUsersList == null) {
      return user;
    }

    final userDIDs =
        await Future.wait(users.map((e) async => await getUserDID(address: e)));

    user.profile!.blockedUsersList = user.profile!.blockedUsersList!
        .where((element) => !userDIDs.contains(element))
        .toList();

    return PUSH_USER.profileUpdate(
      pgpPrivateKey: _decryptedPgpPvtKey!,
      account: _account,
      profile: Profile(
          name: user.profile!.name,
          desc: user.profile!.desc,
          picture: user.profile!.picture,
          blockedUsersList: user.profile?.blockedUsersList),
    );
  }
}

class GroupAPI {
  late final Signer? _signer;

  late final String _account;
  late final String? _decryptedPgpPvtKey;
  void Function(ProgressHookType)? progressHook;

  GroupAPI({
    Signer? signer,
    required String account,
    String? decryptedPgpPvtKey,
    String? pgpPublicKey,
    required this.progressHook,
  }) {
    _signer = signer;
    _account = account;
    _decryptedPgpPvtKey = decryptedPgpPvtKey;

    participants = GroupParticipantsAPI();
  }

  bool get _hasSigner => _signer != null;

  late final GroupParticipantsAPI participants;

  Future<GroupInfoDTO?> create({
    required String name,
    required GroupCreationOptions options,
  }) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final groupParam = ChatCreateGroupTypeV2(
      account: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      signer: _signer,
      groupName: name,
      groupDescription: options.description,
      groupImage: options.image,
      rules: options.rules,
      isPublic: !options.private,
      groupType: 'default',
      config: GroupConfig(),
      admins: options.admins,
      members: options.members,
    );

    return PUSH_CHAT.createGroupV2(options: groupParam);
  }

  Future<GroupAccess> permissions({required String chatId}) async {
    return PUSH_CHAT.getGroupAccess(chatId: chatId, did: _account);
  }

  Future<GroupInfoDTO> info({required String chatId}) async {
    return PUSH_CHAT.getGroupInfo(chatId: chatId);
  }

  Future<GroupDTO> update({
    required String chatId,
    required GroupUpdateOptions options,
  }) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final group = await PUSH_CHAT.getGroupInfo(chatId: chatId);

    final updateGroupProfileOptions = ChatUpdateGroupProfileType(
      chatId: chatId,
      groupName: options.name ?? group.groupName,
      groupDescription: options.description ?? group.groupDescription,
      groupImage: options.image ?? group.groupImage,
      pgpPrivateKey: _decryptedPgpPvtKey,
      rules: options.rules ?? group.rules,
      signer: _signer,
      account: _account,
    );

    final updateGroupConfigOptions = ChatUpdateConfigProfileType(
      chatId: chatId,
      account: _account,
      meta: options.meta,
      pgpPrivateKey: _decryptedPgpPvtKey,
      scheduleAt: options.scheduleAt,
      scheduleEnd: options.scheduleEnd,
      signer: _signer,
      status: options.status,
    );

    await updateGroupProfile(options: updateGroupProfileOptions);
    return await updateGroupConfig(
      options: updateGroupConfigOptions,
    );
  }

  ///role: 'ADMIN' | 'MEMBER';
  Future<GroupInfoDTO?> add({
    required String chatId,
    required String role,
    required List<String> accounts,
  }) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final validRoles = ['ADMIN', 'MEMBER'];
    if (!validRoles.contains(role)) {
      throw Exception('Invalid role provided.');
    }

    if (accounts.isEmpty) {
      throw Exception('accounts array cannot be empty!');
    }

    for (var account in accounts) {
      if (!isValidETHAddress(account)) {
        throw Exception('Invalid account address: $account');
      }
    }

    if (role == 'ADMIN') {
      return PUSH_CHAT.addAdmins(
        chatId: chatId,
        admins: accounts,
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    } else {
      return PUSH_CHAT.addMembers(
        chatId: chatId,
        members: accounts,
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    }
  }

  ///role: 'ADMIN' | 'MEMBER';
  Future remove({
    required String chatId,
    required String role,
    required List<String> accounts,
  }) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final validRoles = ['ADMIN', 'MEMBER'];
    if (!validRoles.contains(role)) {
      throw Exception('Invalid role provided.');
    }

    if (accounts.isEmpty) {
      throw Exception('accounts array cannot be empty!');
    }

    for (var account in accounts) {
      if (!isValidETHAddress(account)) {
        throw Exception('Invalid account address: $account');
      }
    }

    var adminsToRemove = <String>[];
    var membersToRemove = <String>[];

    for (var account in accounts) {
      final status =
          await PUSH_CHAT.getGroupMemberStatus(chatId: chatId, did: account);
      if (status.isAdmin) {
        adminsToRemove.add(account);
      } else {
        membersToRemove.add(account);
      }
    }

    if (adminsToRemove.isNotEmpty) {
      await PUSH_CHAT.removeAdmins(
        chatId: chatId,
        admins: adminsToRemove,
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    }

    if (membersToRemove.isNotEmpty) {
      await PUSH_CHAT.removeMembers(
        chatId: chatId,
        members: membersToRemove,
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    }

    return info(chatId: chatId);
  }

  ///role: 'ADMIN' | 'MEMBER';
  Future<GroupInfoDTO?> modify({
    required String chatId,
    required String role,
    required List<String> accounts,
  }) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final validRoles = ['ADMIN', 'MEMBER'];
    if (!validRoles.contains(role)) {
      throw Exception('Invalid role provided.');
    }

    if (accounts.isEmpty) {
      throw Exception('accounts array cannot be empty!');
    }

    for (var account in accounts) {
      if (!isValidETHAddress(account)) {
        throw Exception('Invalid account address: $account');
      }
    }

    return PUSH_CHAT.modifyRoles(
      options: ModifyRolesType(
        chatId: chatId,
        newRole: role,
        account: _account,
        members: accounts,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      ),
    );
  }

  Future<GroupInfoDTO> join({required String target}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final status = await PUSH_CHAT.getGroupMemberStatus(
      chatId: target,
      did: _account,
    );

    if (status.isPending) {
      await PUSH_CHAT.approve(
        senderAddress: target,
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    } else if (!status.isMember) {
      await PUSH_CHAT.addMembers(
        chatId: target,
        members: [_account],
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    }

    return await info(chatId: target);
  }

  Future<GroupInfoDTO> leave({required String target}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    final status = await PUSH_CHAT.getGroupMemberStatus(
      chatId: target,
      did: _account,
    );

    if (status.isAdmin) {
      await PUSH_CHAT.removeAdmins(
        chatId: target,
        admins: [_account],
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    } else if (!status.isMember) {
      await PUSH_CHAT.removeMembers(
        chatId: target,
        members: [_account],
        account: _account,
        pgpPrivateKey: _decryptedPgpPvtKey,
        signer: _signer,
      );
    }

    return await info(chatId: target);
  }

  Future<void> reject({required String target}) async {
    if (!_hasSigner) {
      throw Exception(PushAPI.ensureSignerMessage());
    }

    await PUSH_CHAT.reject(
      senderAddress: target,
      account: _account,
      pgpPrivateKey: _decryptedPgpPvtKey,
      signer: _signer,
    );
  }
}

class GroupParticipantsAPI {
  void Function(ProgressHookType)? progressHook;

  GroupParticipantsAPI();

  Future<List<ChatMemberProfile>> list({
    required String chatId,
    required GetGroupParticipantsOptions options,
  }) async {
    return PUSH_CHAT.getGroupMembers(
      options: FetchChatGroupInfoType(
        chatId: chatId,
        limit: options.limit,
        page: options.limit,
        pending: options.filter?.pending,
        role: options.filter?.role,
      ),
    );
  }

  Future<GroupCountInfo> count({required String chatId}) async {
    final count = await PUSH_CHAT.getGroupMemberCount(chatId: chatId);

    return GroupCountInfo(
      participants: count.overallCount - count.pendingCount,
      pending: count.pendingCount,
    );
  }

  Future<ParticipantStatus> status({
    required String chatId,
    required String accountId,
  }) async {
    final status =
        await PUSH_CHAT.getGroupMemberStatus(chatId: chatId, did: accountId);
    return ParticipantStatus(
      pending: status.isPending,
      role: status.isAdmin ? 'ADMIN' : 'MEMBER',
      participant: status.isMember,
    );
  }
}
