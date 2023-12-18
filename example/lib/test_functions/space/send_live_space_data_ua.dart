import 'package:example/models/signer.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'package:ethers/signers/wallet.dart' as ether;

Future<void> testSendLiveSpaceDataUA() async {
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

  final affectedAddresses = ['0x5C34b69f1ccb13691d8752AF740eaD6FB04B522e'];
  final updatedLiveSpaceData = LiveSpaceData(
      host: AdminPeer(address: ethersWallet.address!),
      // coHosts: [
      //   AdminPeer(address: ethersWallet.address!)
      // ],
      speakers: [
        AdminPeer(address: ethersWallet.address!)
      ],
      listeners: [
        ListenerPeer(address: '0x5C34b69f1ccb13691d8752AF740eaD6FB04B522e')
      ]);

  final content = CHAT.UA_LISTENER_JOIN;
  final userActivityMessage = UserActivityMessage(
      info: Info(
          affected: affectedAddresses,
          arbitrary: updatedLiveSpaceData.toJson()),
      content: content);

  final options = ChatSendOptions(
    account: ethersWallet.address,
    pgpPrivateKey: pgpPrivateKey,
    message: userActivityMessage,
    to: 'spaces:cff80fae9b898b9f5d679bfa7ef4dfcb7d31b9d1c12e032f4ec6d84a575e62cb',
  );

  final result = await send(options);

  print('testSendLiveSpaceData result = $result');
}
