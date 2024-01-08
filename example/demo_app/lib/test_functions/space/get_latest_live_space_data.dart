import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ether;

Future<void> testGetLatestLiveSpaceData() async {
  final ethersWallet = ether.Wallet.fromMnemonic(
      'label mobile gas salt service gravity nose bomb marine online say twice');

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  final user = await getUser(address: ethersWallet.address!);

  if (user == null) {
    print('Cannot get user');
    return;
  }

  String? pgpPrivateKey = null;
  if (user.encryptedPrivateKey != null) {
    pgpPrivateKey = await decryptPGPKey(
      encryptedPGPPrivateKey: user.encryptedPrivateKey!,
      wallet: getWallet(signer: signer),
    );
  }

  final result = await getLatestLiveSpaceData(
      accountAddress: ethersWallet.address!,
      pgpPrivateKey: pgpPrivateKey,
      spaceId:
          'spaces:cff80fae9b898b9f5d679bfa7ef4dfcb7d31b9d1c12e032f4ec6d84a575e62cb');

  print('testGetLatestLiveSpaceData result = ${result.toJson()}');
}
