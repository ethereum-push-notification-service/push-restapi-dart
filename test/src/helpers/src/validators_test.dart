import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() {
  group(
    'Validators',
    () {
      test('isValidETHAddress', () {
        expect(isValidETHAddress('0xffa1af9e558b68bbc09ad74058331c100c135280'),
            true);
        expect(
            isValidETHAddress(
                'eip155:0x8ca107e6845b095599FDc1A937E6f16677a90325'),
            true);
      });

      test('isValidETHAddress NFT', () {
        expect(
            isValidETHAddress(
                'nft:eip155:5:0x42af3147f17239341477113484752D5D3dda997B:2:1683058528'),
            true);
      });
      test('isValidETHAddress [invalid address]', () {
        expect(isValidETHAddress('0xffa1af9e558b68bb31c00c135280'), false);
      });
      test('isValidCAIP10NFTAddress NFT', () {
        expect(
            isValidCAIP10NFTAddress(
                'nft:eip155:5:0x42af3147f17239341477113484752D5D3dda997B:2:1683058528'),
            true);
      });
      test('isValidCAIP10NFTAddress NFT', () {
        expect(
            isValidNFTCAIP10Address(
                'nft:eip155:5:0x42af3147f17239341477113484752D5D3dda997B:2:1683058528'),
            false);
      });
      test('isValidCAIP10NFTAddress NFT [invalid address]', () {
        expect(
            isValidCAIP10NFTAddress(
                'nft:eip155:5:0x42af3147f17239341477113484752D5D3dda997B:pp:1683058528'),
            false);
      });
      test('isGroup', () {
        expect(
          isGroup(
              '5077a85c711e9656ac733b1a0c947f6655beb7f7d93ade18e4c497ce6c16eba0'),
          true,
        );
      });
    },
  );
}
