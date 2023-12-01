import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() async {
  group(
    'Converters Funtions',
    () {
      test('walletToPCAIP10', () {
        expect(walletToPCAIP10('0x8ca107e6845b095599FDc1A937E6f16677a90325'),
            'eip155:0x8ca107e6845b095599FDc1A937E6f16677a90325');
      });
    
      test('pCAIP10ToWallet', () {
        expect(
            pCAIP10ToWallet(
                'eip155:0x8ca107e6845b095599FDc1A937E6f16677a90325'),
            '0x8ca107e6845b095599FDc1A937E6f16677a90325');
      });
    },
  );
}
