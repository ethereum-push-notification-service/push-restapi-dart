import 'dart:math';

import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'package:web3dart/web3dart.dart' as web3;

import '../../__lib.dart';

testPushApi() async {
  final web3.Credentials randomCredentials =
      web3.EthPrivateKey.createRandom(Random.secure());
  final signer = Web3Signer(randomCredentials);
  final web3.Credentials randomCredentials2 =
      web3.EthPrivateKey.createRandom(Random.secure());
  final signer2 = Web3Signer(randomCredentials2);

  final alice = await PushAPI.initialize(signer: signer);
  final bob = await PushAPI.initialize(signer: signer2);

  print('Push api : ${alice.pgpPublicKey}');

  print('Push api bob: ${bob.pgpPublicKey}');
}
