import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

import 'package:ethers/signers/wallet.dart' as ether;

import '../../__lib.dart';

testDecryptPGPKey() async {
  const mnemonic =
      'coconut slight random umbrella print verify agent disagree endorse october beyond bracket';
  final ethersWallet = ether.Wallet.fromMnemonic(mnemonic);
  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  print('walletMnemonic.address: ${ethersWallet.address}');
  final user = await push.getUser(address: ethersWallet.address!);

  if (user == null) {
    print('Cannot get user');
    return;
  }

  String? pgpPrivateKey = null;
  if (user.encryptedPrivateKey != null) {
    pgpPrivateKey = await push.decryptPGPKey(
      encryptedPGPPrivateKey: user.encryptedPrivateKey!,
      wallet: push.getWallet(signer: signer),
    );
  }

  print(pgpPrivateKey);
}
