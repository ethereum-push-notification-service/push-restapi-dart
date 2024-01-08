import 'dart:math';

import 'package:ethers/signers/wallet.dart' as ethers;
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;
import 'package:web3dart/web3dart.dart' as web3;

import '../../__lib.dart';

void testCreateUserFromMnemonics() async {
  const mnemonic =
      'wink cancel juice stem alert gesture rally pupil evidence top night fury';
  final ethersWallet = ethers.Wallet.fromMnemonic(mnemonic);
  final walletSigner = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  try {
    final result = await push.createUser(
      signer: walletSigner,
      progressHook: (push.ProgressHookType progress) {
        print(progress.progressInfo);
      },
    );

    print(result);
  } catch (e) {
    print(e);
  }
}

void testCreateRandomUser() async {
  var random = Random.secure();
  final web3.Credentials randomCredentials =
      web3.EthPrivateKey.createRandom(random);

  final w = Web3Signer(randomCredentials);

  try {
    final result = await push.createUser(
      signer: w,
      progressHook: (push.ProgressHookType progress) {
        print(progress.progressInfo);
      },
    );

    print(result.did);
  } catch (e) {
    print(e);
  }
}

void testCreateEmptyRandomUser() async {
  var random = Random.secure();
  final web3.Credentials randomCredentials =
      web3.EthPrivateKey.createRandom(random);

  final w = Web3Signer(randomCredentials);

  try {
    final result = await push.createUserEmpty(accountAddress: w.getAddress());

    print(result?.did);
  } catch (e) {
    print(e);
  }
}
