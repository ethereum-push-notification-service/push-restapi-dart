import 'dart:convert';

import '../../../push_restapi_dart.dart';

Future<User> createUser({
  required Signer signer,
  String version = ENCRYPTION_TYPE.PGP_V3,
  required Function(ProgressHookType) progressHook,
}) async {
  final wallet = getWallet(signer: signer);
  final String address = signer.getAddress();

  if (!isValidETHAddress(address)) {
    throw Exception('Invalid address!');
  }

  if (!ENCRYPTION_TYPE.isValidEncryptionType(version)) {
    throw Exception('Invalid version!');
  }

  final caip10 = walletToPCAIP10(address);
  var encryptionType = version;
  progressHook(PROGRESSHOOK['PUSH-CREATE-01'] as ProgressHookType);

  final keyPairs = await generateKeyPair();
  progressHook(PROGRESSHOOK['PUSH-CREATE-02'] as ProgressHookType);

  final publicKey = await preparePGPPublicKey(
    encryptionType: encryptionType,
    generatedPublicKey: keyPairs.publicKey,
    wallet: wallet,
  );
  progressHook(PROGRESSHOOK['PUSH-CREATE-03'] as ProgressHookType);
  EncryptedPrivateKeyModel encryptedPrivateKey = await encryptPGPKey(
    encryptionType: encryptionType,
    generatedPrivateKey: keyPairs.privateKey,
    wallet: wallet,
  );

  final data = {
    "caip10": caip10,
    "did": caip10,
    "publicKey": publicKey,
    "encryptedPrivateKey": jsonEncode(encryptedPrivateKey.toJson()),
    "signature": "pgp",
    "sigType": "pgp"
  };

  final result = await http.post(path: '/v2/users', data: data);

  if (result == null || result is String) {
    throw Exception(result ?? 'Unable to create account for $address');
  } else {
    return User.fromJson(result);
  }
}

Future<User?> createUserEmpty({required String accountAddress}) async {
  final caip10 = walletToPCAIP10(accountAddress);

  final data = {
    "caip10": caip10,
    "did": caip10,
    "publicKey": '',
    "encryptedPrivateKey": '',
    "signature": "pgp",
    "sigType": "pgp"
  };

  final result = await http.post(path: '/v2/users', data: data);

  if (result == null || result is String) {
    throw Exception(result ?? 'Unable to create account for $accountAddress');
  } else {
    return User.fromJson(result);
  }
}
