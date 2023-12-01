import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart' as push;
import 'package:web3dart/web3dart.dart';

import '../../models/signer.dart';

void main() {
  group('Wallet', () {
    final Credentials randomCredentials = EthPrivateKey.fromHex(
        "c41b72d56258e50595baa969eb0949c5cee9926ac55f7bad21fe327236772e0c");
    final signer = Web3Signer(randomCredentials);

    final wallet = push.Wallet(
      address: '0xffa1af9e558b68bbc09ad74058331c100c135280',
      signer: signer,
    );

    test('.getAddress()', () {
      expect(signer.getAddress(), '0xffa1af9e558b68bbc09ad74058331c100c135280');
    });
    test('.getWallet', () async {
      expect(
        push.getWallet(
            address: '0xffa1af9e558b68bbc09ad74058331c100c135280',
            signer: signer),
        wallet,
      );
    });
    test('.getAccountAddress', () async {
      expect(
        push.getAccountAddress(wallet),
        '0xffa1af9e558b68bbc09ad74058331c100c135280',
      );
    });

    test('check for exception when address is null', () {
      expect(()=> push.getAccountAddress(push.Wallet()), throwsA(isA<Exception>()));
    });
  });
}
