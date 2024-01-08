import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

import 'package:ethers/signers/wallet.dart' as ether;
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../models/signer.dart';
import 'package:uuid/uuid.dart';

void testUpdateSpace() async {
  final ethersWallet = ether.Wallet.fromPrivateKey(
      "c41b72d56258e50595baa969eb0949c5cee9926ac55f7bad21fe327236772e0c");

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  var uuid = Uuid();
  var spaceName = 'space-' + uuid.v4();
  final result = await push.createSpace(
      signer: signer,
      spaceName: spaceName,
      spaceDescription: "Testing dart",
      spaceImage: "INVALID_URL",
      listeners: ["eip155:0x9960D6B63B113303B9910A03ca5341B83CC52723"],
      speakers: ["eip155:0xffa1af9e558b68bbc09ad74058331c100c135280"],
      isPublic: true,
      scheduleAt: DateTime(2024, 01, 91));

  var spaceDTO = await push.updateSpace(
    signer: signer,
    spaceId: result!.spaceId,
    spaceName: spaceName,
    spaceDescription: 'YourSpaceDescription',
    spaceImage: 'VALID_URL',
    listeners: [
      'eip155:0x9960D6B63B113303B9910A03ca5341B83CC52723',
      signer.address
    ],
    speakers: [signer.address],
    scheduleAt: DateTime.now(),
    scheduleEnd: DateTime.now().add(Duration(days: 10)),
    status: ChatStatus.ACTIVE,
  );

  print(spaceDTO);
  if (spaceDTO != null) {
    print('testUpdateSpace response: ${result}');
  }
}
