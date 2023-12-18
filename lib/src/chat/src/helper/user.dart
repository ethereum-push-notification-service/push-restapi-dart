import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<ConnectedUser> getConnectedUserV2({
  required Wallet wallet,
  String? privateKey,
}) async {
  return getConnectedUserV2Core(wallet: wallet, privateKey: privateKey);
}

Future<ConnectedUser> getConnectedUserV2Core({
  required Wallet wallet,
  String? privateKey,
}) async {
  final user = await getUser(address: getAccountAddress(wallet));

  if (user != null && user.encryptedPrivateKey != null) {
    if (privateKey != null) {
      return ConnectedUser.fromUser(user: user, privateKey: privateKey);
    } else {
      final decryptedPrivateKey = await getDecryptedPrivateKey(
        address: wallet.address!,
        wallet: wallet,
        user: user,
      );

      return ConnectedUser.fromUser(
          user: user, privateKey: decryptedPrivateKey);
    }
  } else {
    final newUser =
        await createUser(signer: wallet.signer!, progressHook: (hook) {});
    final decryptedPrivateKey = await getDecryptedPrivateKey(
      address: wallet.address!,
      wallet: wallet,
      user: newUser,
    );
    return ConnectedUser.fromUser(
        user: newUser, privateKey: decryptedPrivateKey);
  }
}
