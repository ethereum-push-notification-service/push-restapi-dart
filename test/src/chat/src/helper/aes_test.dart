import 'package:flutter_test/flutter_test.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

void main() {
  group('test aes functions', () {
    test('.generateRandomSecret', () {
      expect(generateRandomSecret(-1), '');
      expect(generateRandomSecret(6).length, 6);

      final secret1 = generateRandomSecret(6);
      final secret2 = generateRandomSecret(6);

      expect(secret1 == secret2, false);
    });
    test('.generateRandomSecretNonZero', () {
      expect(generateRandomSecretNonZero(6).length, 6);

      final secret1 = generateRandomSecretNonZero(6);
      final secret2 = generateRandomSecretNonZero(6);

      expect(secret1 == secret2, false);
    });

    test('.createUint8ListFromString', () {
      final plainText = 'push.org';
      final bytesValue = [112, 117, 115, 104, 46, 111, 114, 103];
      expect(createUint8ListFromString(plainText), bytesValue);
    });

    test('test aesDecrypt and aesEncrypt', () async {
      final plainText = 'push.org- The Communication Protocol of Web3';
      final secretKey = generateRandomSecret(15);
      final cipherText =
          await aesEncrypt(plainText: plainText, secretKey: secretKey);
      final decipherText =
          aesDecrypt(cipherText: cipherText, secretKey: secretKey);
      expect(decipherText == plainText, true);
    });

    test('test aes encrypt error when invalid secret key is used', () async {
      expect(() => aesDecrypt(cipherText: '231212', secretKey: '1212'),
          throwsA(isA<Exception>()));
    });
  });
}
