import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

import 'package:ethers/signers/wallet.dart' as ether;

import '../../models/signer.dart';

Future testCreateGroupPublic() async {
  final ethersWallet = ether.Wallet.fromPrivateKey(
      "c41b72d56258e50595baa969eb0949c5cee9926ac55f7bad21fe327236772e0c");

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  final result = await push.createGroup(
      signer: signer,
      groupName: "Test Flutter SDK Public group",
      groupDescription: "Testing dart",
      members: ["0x9960D6B63B113303B9910A03ca5341B83CC52723"],
      admins: ["0xffa1af9e558b68bbc09ad74058331c100c135280"],
      isPublic: true);

  print(result);
  if (result != null) {
    print('testCreateGroup response: ${result.chatId}');
  }
}
