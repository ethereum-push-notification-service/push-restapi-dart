import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ethers;

Future<void> testSendMediaEmbed() async {
  final ethersWallet = ethers.Wallet.fromMnemonic(
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

  final options = ChatSendOptions(
    account: ethersWallet.address,
    pgpPrivateKey: pgpPrivateKey,
    message: SendMessage(
        type: MessageType.MEDIA_EMBED,
        content:
            "https://media2.giphy.com/media/p0L1rezLH2Tja/giphy.gif?cid=c918c0ff667b3vbiu4i4e5d1t9sqssx8uvy10reprq8yds23&ep=v1_gifs_trending&rid=giphy.gif&ct=g"),
    to: '83e6aaf9fb44c5929ea965d2b0c4e98fd8b6094b72f51989123f81e6cf69f298',
  );

  final result = await send(options);

  print('testSend result = $result');
}
