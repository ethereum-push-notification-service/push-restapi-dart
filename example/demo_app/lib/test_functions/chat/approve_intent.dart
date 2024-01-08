import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ether;

void testApproveIntent() async {
  final ethersWallet = ether.Wallet.fromPrivateKey(
      "b9d00f786e1d024cfed08f696a775217ff75501f4aacef5ec0795fc4a2eb9df1");

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
  final result = await requests(
      toDecrypt: true,
      accountAddress: signer.address,
      pgpPrivateKey: pgpPrivateKey);
  print(result);
  approve(
      senderAddress: "0xaba32d63052de97Bc3bc749b7241cB4E2479c401",
      account: signer.address,
      signer: signer,
      pgpPrivateKey: pgpPrivateKey);
}
