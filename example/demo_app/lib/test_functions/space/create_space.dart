import 'package:example/__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

import 'package:ethers/signers/wallet.dart' as ether;
import 'package:unique_names_generator/unique_names_generator.dart';

import '../../models/signer.dart';

void testCreateSpace() async {
  final ethersWallet = ether.Wallet.fromPrivateKey(
      "c41b72d56258e50595baa969eb0949c5cee9926ac55f7bad21fe327236772e0c");

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

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

  await push.initPush(
    wallet: push.Wallet(
      address: ethersWallet.address!,
      pgpPrivateKey: pgpPrivateKey,
    ),
    env: push.ENV.staging,
  );

  final generator = UniqueNamesGenerator(
    // Config.fallback() can also be used
    config: Config(dictionaries: [names, animals, colors]),
  );

  String spaceName = 'Space ${generator.generate()} '.replaceAll('_', ' ');
  if (spaceName.length > 50) {
    spaceName = spaceName.substring(0, 45);
  }

  final result = await push.createSpace(
    signer: signer,
    spaceName: spaceName,
    spaceDescription: "Testing dart for description for $spaceName",
    spaceImage:
        "https://res.cloudinary.com/drdjegqln/image/upload/v1686227557/Push-Logo-Standard-Dark_xap7z5.png",
    listeners: ["eip155:0x9960D6B63B113303B9910A03ca5341B83CC52723"],
    speakers: [
      "eip155:0xffa1af9e558b68bbc09ad74058331c100c135280",
      '0xB6E3Dc6b35A294f6Bc8de33969185A615e8596D3',
      '0x8ca107e6845b095599FDc1A937E6f16677a90325',
    ],
    isPublic: true,
    scheduleAt: DateTime.now().toUtc().add(
          Duration(minutes: 1),
        ),
  );

  print(result);
  if (result != null) {
    print('testCreateSpace response: spaceId = ${result.spaceId}');
    // testStartSpace(result.spaceId);
  }
}
