import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() {
  group('Crypto functions', () {
    final plainText = 'push.org';
    final hexValue = '707573682e6f7267';
    final bytesValue = [112, 117, 115, 104, 46, 111, 114, 103];

    test('stringToHex', () {
      expect(stringToHex(plainText), hexValue);
    });

    test('hexToBytes', () {
      expect(hexToBytes(hexValue), bytesValue);
    });

    test('bytesToHex', () {
      expect(bytesToHex(bytesValue), hexValue);
    });

    test('bytes to String', () {
      expect(utf8.decode(bytesValue), plainText);
    });
  });
}
