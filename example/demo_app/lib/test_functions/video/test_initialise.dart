import 'package:push_restapi_dart/push_restapi_dart.dart' as push;
import 'package:riverpod/riverpod.dart';
import 'package:ethers/signers/wallet.dart' as ether;
import '../../models/signer.dart';

void testVideoInitialise() async {
  final ethersWallet = ether.Wallet.fromPrivateKey(
      "c41b72d56258e50595baa969eb0949c5cee9926ac55f7bad21fe327236772e0c");

  final signer = EthersSigner(
    ethersWallet: ethersWallet,
    address: ethersWallet.address!,
  );

  final videoProvider = Provider((ref) {
    return ref.read(push.PushVideoCallProvider.notifier).initializeVideo(
          callType: push.VIDEO_CALL_TYPE.PUSH_VIDEO,
          signer: signer,
          chainId: 1,
          pgpPrivateKey: 'private_key',
          data: push.initVideoCallData, // Provide initial data here
          onReceiveStream: (receivedStream, senderAddress, audio) async {
            // Implementation of onReceiveStream
          },
        );
  });
  print("video");
  print(videoProvider);
}
