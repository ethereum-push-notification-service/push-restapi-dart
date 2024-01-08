import '../../../push_restapi_dart.dart';

class Profile {
  String? name;
  String? desc;
  String? picture;
  List<String>? blockedUsersList;

  Profile({
    this.name,
    this.desc,
    this.picture,
    this.blockedUsersList,
  });
}

Future<User?> profileUpdate({
  required String pgpPrivateKey,
  required String account,
  required Profile profile,
}) async {
  try {
    if (!isValidETHAddress(account)) {
      throw Exception('Invalid account!');
    }

    final user = await getUser(address: account);
    if (user == null || user.did == null) {
      throw Exception('User not Found!');
    }

    List<String>? blockedUsersList;

    if (profile.blockedUsersList != null) {
      for (var element in profile.blockedUsersList!) {
        // Check if the element is a valid CAIP-10 address
        if (!isValidETHAddress(element)) {
          throw Exception('Invalid address in the users: $element');
        }
      }
      blockedUsersList = await Future.wait(profile.blockedUsersList!
          .map((e) async => await getUserDID(address: e)));
    }

    final updatedProfile = {
      'name': profile.name ?? user.profile?.name,
      'desc': profile.desc ?? user.profile?.desc,
      'picture': profile.picture ?? user.profile?.picture,
      'blockedUsersList':
          profile.blockedUsersList != null ? blockedUsersList : [],
    };

    final hash = generateHash(updatedProfile);

    final signature = await sign(
      message: hash,
      privateKey: pgpPrivateKey,
    );

    final sigType = 'pgpv2';
    final verificationProof = '$sigType:$signature';

    final body = {
      ...updatedProfile,
      'verificationProof': verificationProof,
    };

    final result = await http.put(
      path: '/v2/users/${user.did}/profile',
      data: body,
    );

    if (result == null) {
      return null;
    }

    var updatedUser = User.fromJson(result);

    // updatedUser.publicKey = verifyProfileKeys(
    //   encryptedPrivateKey: updatedUser.encryptedPrivateKey!,
    //   publicKey: updatedUser.publicKey!,
    //   did: updatedUser.did!,
    //   caip10: updatedUser.wallets!,
    //   verificationProof: updatedUser.verificationProof!,
    // );

    return populateDeprecatedUser(user: updatedUser);
  } catch (err) {
    log('[Push SDK] - API - Error - API profileUpdate -: $err');
    rethrow;
  }
}
