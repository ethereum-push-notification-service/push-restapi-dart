import 'dart:convert';
import '../../../push_restapi_dart.dart';

String walletToPCAIP10(String account) {
  if (account.contains("eip155:") && account.split(':').length == 2) {
    return account;
  }
  if (isValidCAIP10NFTAddress(account) || validateCAIP(account)) {
    return account;
  }
  return 'eip155:$account';
}

String pCAIP10ToWallet(String wallet) {
  if (isValidCAIP10NFTAddress(wallet)) return wallet;
  wallet = wallet.replaceFirst('eip155:', '');
  return wallet;
}

SpaceDTO groupDtoToSpaceDto(GroupDTO groupDto) {
  Map<String, dynamic> groupData = groupDto.toJson();

  return SpaceDTO(
    members: (groupData['members'] as List<dynamic>)
        .map((member) => SpaceMemberDTO(
              wallet: member['wallet'],
              publicKey: member['publicKey'],
              isSpeaker: member['isAdmin'],
              image: member['image'],
            ))
        .toList(),
    pendingMembers: (groupData['pendingMembers'] as List<dynamic>)
        .map((pendingMember) => SpaceMemberDTO(
              wallet: pendingMember['wallet'],
              publicKey: pendingMember['publicKey'],
              isSpeaker: pendingMember['isAdmin'],
              image: pendingMember['image'],
            ))
        .toList(),
    contractAddressERC20: groupData['contractAddressERC20'],
    numberOfERC20: groupData['numberOfERC20'],
    contractAddressNFT: groupData['contractAddressNFT'],
    numberOfNFTTokens: groupData['numberOfNFTTokens'],
    verificationProof: groupData['verificationProof'],
    spaceImage: groupData['groupImage'],
    spaceName: groupData['groupName'],
    isPublic: groupData['isPublic'],
    spaceDescription: groupData['groupDescription'],
    spaceCreator: groupData['groupCreator'],
    spaceId: groupData['chatId'],
    scheduleAt: groupData['scheduleAt'] != null
        ? DateTime.parse(groupData['scheduleAt'])
        : null,
    scheduleEnd: groupData['scheduleEnd'] != null
        ? DateTime.parse(groupData['scheduleEnd'])
        : null,
    status: groupData['status'] != null
        ? chatStatusFromString(groupData['status'])
        : null,
    meta: groupDto.meta,
  );
}

SpaceDTO groupInfoDtoToSpaceDto(GroupInfoDTO groupDto) {
  return SpaceDTO(
    members: [],
    pendingMembers: [],
    contractAddressERC20: null,
    numberOfERC20: -1,
    numberOfNFTTokens: -1,
    verificationProof: '',
    spaceImage: groupDto.groupImage,
    spaceName: groupDto.groupName,
    isPublic: groupDto.isPublic,
    spaceDescription: groupDto.groupDescription,
    spaceCreator: groupDto.groupCreator,
    spaceId: groupDto.chatId,
    scheduleAt: groupDto.scheduleAt,
    scheduleEnd: groupDto.scheduleEnd,
    status: groupDto.status,
    meta: groupDto.meta,
  );
}

List<String> convertToWalletAddressList(List<MemberDTO> memberList) {
  return memberList.map((member) => member.wallet).toList();
}

List<String> convertToWalletAddressListV2(List<SpaceMemberDTO> memberList) {
  return memberList.map((member) => member.wallet).toList();
}

List<String> getMembersList(
    List<MemberDTO> members, List<MemberDTO> pendingMembers) {
  final allMembers = [...members, ...pendingMembers];
  return convertToWalletAddressList(allMembers);
}

List<String> getSpacesMembersList(
    List<SpaceMemberDTO> members, List<SpaceMemberDTO> pendingMembers) {
  final allMembers = [...members, ...pendingMembers];
  return convertToWalletAddressListV2(allMembers);
}

List<String> getAdminsList(
    List<MemberDTO>? members, List<MemberDTO>? pendingMembers) {
  final adminsFromMembers = members != null
      ? convertToWalletAddressList(
          members.where((admin) => admin.isAdmin).toList())
      : <String>[];

  final adminsFromPendingMembers = pendingMembers != null
      ? convertToWalletAddressList(
          pendingMembers.where((admin) => admin.isAdmin).toList())
      : <String>[];

  final adminList = [...adminsFromMembers, ...adminsFromPendingMembers];
  return adminList;
}

List<String> getSpaceAdminsList(
    List<SpaceMemberDTO>? members, List<SpaceMemberDTO>? pendingMembers) {
  final adminsFromMembers = members != null
      ? convertToWalletAddressListV2(
          members.where((admin) => admin.isSpeaker).toList())
      : <String>[];

  final adminsFromPendingMembers = pendingMembers != null
      ? convertToWalletAddressListV2(
          pendingMembers.where((admin) => admin.isSpeaker).toList())
      : <String>[];

  final adminList = [...adminsFromMembers, ...adminsFromPendingMembers];
  return adminList;
}

String getPublicKeyFromString(String pgpPublicKeyString) {
  if (pgpPublicKeyString.isEmpty) {
    return pgpPublicKeyString;
  }
  dynamic pgpPublicKeyJson;
  try {
    pgpPublicKeyJson = jsonDecode(pgpPublicKeyString);
    pgpPublicKeyJson = pgpPublicKeyJson["key"] ?? pgpPublicKeyString;
    return pgpPublicKeyJson;
  } catch (error) {
    return pgpPublicKeyString;
  }
}
