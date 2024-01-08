import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ethers;

// send a message in a wallet to wallet chat
void testSend() async {
  final ethersWallet = ethers.Wallet.fromMnemonic(
      'label mobile gas salt service gravity nose bomb marine online say twice');
  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  print('walletMnemonic.address: ${ethersWallet.address}');
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

  print('pgpPrivateKey: $pgpPrivateKey');

  final options = ChatSendOptions(
    account: ethersWallet.address,
    pgpPrivateKey: pgpPrivateKey,
    messageContent: 'Testing send() from Dart SDK for w2w chat',
    to: '0x69e666767Ba3a661369e1e2F572EdE7ADC926029',
  );

  final result = await send(options);

  print('testSend result = $result');
}
