import 'dart:convert';
import 'dart:math' as math;
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'package:encrypt/encrypt.dart' as encrypt;

String generateRandomSecret(int length) {
  final random = math.Random.secure();
  final characters =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final charactersLength = characters.length;
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(characters[random.nextInt(charactersLength)]);
  }
  return buffer.toString();
}

// AES 256 bits encryption with pkcs7 padding
Future<String> aesEncrypt(
    {required String plainText, required String secretKey}) async {
  try {
    final salt = generateRandomSecretNonZero(8);
    var keyndIV = deriveKeyAndIV(secretKey, salt);
    final key = encrypt.Key(keyndIV.first);
    final iv = encrypt.IV(keyndIV.last);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    Uint8List encryptedBytesWithSalt = Uint8List.fromList(
        createUint8ListFromString("Salted__") + salt + encrypted.bytes);
    return base64.encode(encryptedBytesWithSalt);
  } catch (error) {
    rethrow;
  }
}

Uint8List generateRandomSecretNonZero(int seedLength) {
  final random = Random.secure();
  const int randomMax = 245;
  final Uint8List uint8list = Uint8List(seedLength);
  for (int i = 0; i < seedLength; i++) {
    uint8list[i] = random.nextInt(randomMax) + 1;
  }
  return uint8list;
}

String aesDecrypt({required String cipherText, required String secretKey}) {
  try {
    Uint8List encryptedBytesWithSalt = base64.decode(cipherText);

    Uint8List encryptedBytes =
        encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
    final salt = encryptedBytesWithSalt.sublist(8, 16);
    var keyndIV = deriveKeyAndIV(secretKey, salt);
    final key = encrypt.Key(keyndIV.first);
    final iv = encrypt.IV(keyndIV.last);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final decrypted =
        encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
    return decrypted;
  } catch (error) {
    rethrow;
  }
}

List<Uint8List> deriveKeyAndIV(String passphrase, Uint8List salt) {
  var password = createUint8ListFromString(passphrase);
  Uint8List concatenatedHashes = Uint8List(0);
  Uint8List currentHash = Uint8List(0);
  bool enoughBytesForKey = false;
  Uint8List preHash = Uint8List(0);

  while (!enoughBytesForKey) {
    if (currentHash.isNotEmpty) {
      preHash = Uint8List.fromList(currentHash + password + salt);
    } else {
      preHash = Uint8List.fromList(password + salt);
    }
    final p = md5.convert(List.from(preHash));

    currentHash = Uint8List.fromList(p.bytes);
    concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
    if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
  }

  var keyBtyes = concatenatedHashes.sublist(0, 32);
  var ivBtyes = concatenatedHashes.sublist(32, 48);
  return [keyBtyes, ivBtyes];
}

Uint8List createUint8ListFromString(String s) {
  var ret = Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}
