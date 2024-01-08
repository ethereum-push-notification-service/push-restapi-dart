import '../../../../push_restapi_dart.dart';

void createGroupRequestValidator({
  required String groupName,
  required String groupDescription,
  required List<String> members,
  required List<String> admins,
  String? contractAddressNFT,
  int? numberOfNFTs,
  String? contractAddressERC20,
  int? numberOfERC20,
}) {
  if (groupName.isEmpty) {
    throw Exception('groupName cannot be null or empty');
  }

  if (groupName.length > 50) {
    throw Exception('groupName cannot be more than 50 characters');
  }

  if (groupDescription.length > 150) {
    throw Exception('groupDescription cannot be more than 150 characters');
  }

  for (int i = 0; i < members.length; i++) {
    if (!isValidETHAddress(members[i])) {
      throw Exception('Invalid member address!');
    }
  }

  for (int i = 0; i < admins.length; i++) {
    if (!isValidETHAddress(admins[i])) {
      throw Exception('Invalid admin address!');
    }
  }

  if (contractAddressNFT != null &&
      contractAddressNFT.isNotEmpty &&
      !isValidNFTCAIP10Address(contractAddressNFT)) {
    throw Exception('Invalid contractAddressNFT address!');
  }

  if (numberOfNFTs != null && numberOfNFTs < 0) {
    throw Exception('numberOfNFTs cannot be negative number');
  }

  if (contractAddressERC20 != null &&
      contractAddressERC20.isNotEmpty &&
      !isValidNFTCAIP10Address(contractAddressERC20)) {
    throw Exception('Invalid contractAddressERC20 address!');
  }

  if (numberOfERC20 != null && numberOfERC20 < 0) {
    throw Exception('numberOfERC20 cannot be negative number');
  }
}

void updateGroupRequestValidator(
  String chatId,
  String groupName,
  String groupDescription,
  String? groupImage,
  List<String> members,
  List<String> admins,
  String address,
) {
  if (chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }

  if (groupName.isEmpty) {
    throw Exception('groupName cannot be null or empty');
  }

  if (groupName.length > 50) {
    throw Exception('groupName cannot be more than 50 characters');
  }

  if (groupDescription.length > 150) {
    throw Exception('groupDescription cannot be more than 150 characters');
  }

  if (members.isNotEmpty) {
    for (int i = 0; i < members.length; i++) {
      if (!isValidETHAddress(members[i])) {
        throw Exception('Invalid member address in members list!');
      }
    }
  }

  if (admins.isNotEmpty) {
    for (int i = 0; i < admins.length; i++) {
      if (!isValidETHAddress(admins[i])) {
        throw Exception('Invalid member address in admins list!');
      }
    }
  }

  if (!isValidETHAddress(address)) {
    throw Exception('Invalid address field!');
  }
}

void validateGroupMemberUpdateOptions({
  required String chatId,
  required UpsertDTO upsert,
  required List<String> remove,
}) {
  if (chatId.isEmpty) {
    throw Exception('chatId cannot be null or empty');
  }

  // Validating upsert object
  final allowedRoles = ['members', 'admins'];

  upsert.toJson().forEach((role, value) {
    if (!allowedRoles.contains(role)) {
      throw Exception(
          'Invalid role: $role. Allowed roles are ${allowedRoles.join(', ')}.');
    }

    if (value != null && value is List<String> && value.length > 1000) {
      throw Exception('$role array cannot have more than 1000 addresses.');
    }

    value.forEach((address) => {
          if (!isValidETHAddress(address))
            {throw Exception('Invalid address found in $role list.')}
        });
  });

  // Validating remove array
  if (remove.length > 1000) {
    throw Exception('Remove array cannot have more than 1000 addresses.');
  }
  for (var address in remove) {
    if (!isValidETHAddress(address)) {
      throw Exception('Invalid address found in remove list.');
    }
  }
}

Future validateSendOptions(ComputedOptions options) async {
  if (options.account == null && options.signer == null) {
    throw Exception('At least one from account or signer is necessary!');
  }

  final wallet = getWallet(address: options.account, signer: options.signer);

  if (!isValidETHAddress(wallet.address!)) {
    throw Exception('Invalid address ${wallet.address!}');
  }

  if (options.pgpPrivateKey == null && options.signer == null) {
    throw Exception(
        "Unable to decrypt keys. Please ensure that either 'signer' or 'pgpPrivateKey' is properly defined.");
  }

  if (options.messageType != MessageType.COMPOSITE &&
      options.messageType != MessageType.REPLY &&
      options.messageObj?.content.isEmpty) {
    throw Exception('Cannot send empty message');
  }

  //TODO implement validateMessageObj
}

void validateScheduleDates({
  DateTime? scheduleAt,
  DateTime? scheduleEnd,
}) {
  if (scheduleAt != null) {
    final now = DateTime.now();

    if (scheduleAt.isBefore(now)) {
      throw Exception('Schedule start time must be in the future.');
    }

    if (scheduleEnd != null) {
      if (scheduleEnd.isBefore(now)) {
        throw Exception('Schedule end time must be in the future.');
      }

      if (scheduleAt.isAfter(scheduleEnd)) {
        throw Exception('Schedule start time must be earlier than end time.');
      }
    }
  }
}
