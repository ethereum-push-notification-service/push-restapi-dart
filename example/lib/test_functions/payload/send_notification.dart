import 'dart:math';
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;
import 'package:web3dart/web3dart.dart' as web3;

import '../../__lib.dart';

void testSendVideoCallNotification() async {
  // 1. Create Random Wallet Signer
  final web3.Credentials randomCredentials =
      web3.EthPrivateKey.createRandom(Random.secure());
  final signer = Web3Signer(randomCredentials);

  // 2. Create Random Addresses
  final String randomAddress1 =
      Web3Signer(web3.EthPrivateKey.createRandom(Random.secure())).getAddress();
  final String randomAddress2 =
      Web3Signer(web3.EthPrivateKey.createRandom(Random.secure())).getAddress();

  // 3. Create a Push Profile for the signer
  final user = await push.createUser(
    signer: signer,
    progressHook: (push.ProgressHookType progress) {
      print(progress.progressInfo);
    },
  );

  // 4. Create a Grp
  final group = await push.createGroup(
      signer: signer,
      groupName: "qwertyGrp1",
      groupDescription: "qwertyDesc1",
      groupImage: "Some Random Grp Image",
      members: [randomAddress1, randomAddress2],
      admins: [],
      isPublic: false);

  // 5. Decrypt keys in Grp
  final pgpPrivateKey = await push.decryptPGPKey(
    encryptedPGPPrivateKey: user?.encryptedPrivateKey as String,
    wallet: push.getWallet(signer: signer),
  );

  // 6. Send Video Call Notification to grp Members
  push.sendNotification(push.SendNotificationInputOptions(
    senderType: 1,
    signer: signer,
    pgpPrivateKey: pgpPrivateKey,
    pgpPublicKey: user?.publicKey,
    chatId: group?.chatId,
    type: push.NOTIFICATION_TYPE.BROADCAST, // broadcast
    identityType: push.IDENTITY_TYPE.DIRECT_PAYLOAD, // direct payload
    notification: push.NotificationOptions(
      title: "VC TITLE:",
      body: "VC BODY",
    ),
    payload: push.PayloadOptions(
      title: "payload title",
      body: "sample msg body",
      cta: '',
      img: '',
      additionalMeta: push.AdditionalMeta(
        type: '1+1',
        data: 'Random DATA',
        domain: 'push.org',
      ),
    ),
    recipients: signer.getAddress(), // recipient address
    channel: signer.getAddress(), // your channel address)
  ));
}
