import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ethers;

Future<void> testSendReply() async {
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

  String groupId =
      '83e6aaf9fb44c5929ea965d2b0c4e98fd8b6094b72f51989123f81e6cf69f298';

  String hash = await conversationHash(
          conversationId: groupId, accountAddress: ethersWallet.address) ??
      '';

  String referenceLink = '';
  if (hash != '') {
    referenceLink = (await latest(
          threadhash: hash,
          accountAddress: ethersWallet.address,
          pgpPrivateKey: pgpPrivateKey,
        ))
            ?.link ??
        '';
  }

  final options = ChatSendOptions(
    account: ethersWallet.address,
    pgpPrivateKey: pgpPrivateKey,
    message: ReplyMessage(
        content: NestedContent(
            type: MessageType.TEXT,
            content: "reply message sent from the Dart SDK"),
        reference: referenceLink),
    to: groupId,
  );

  final result = await send(options);

  print('testSend result = $result');
}
