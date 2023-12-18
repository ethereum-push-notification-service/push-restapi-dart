import 'package:openpgp/openpgp.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

String removeVersionFromPublicKey(String key) {
  List<String> lines = key.split('\n');

  lines.removeWhere((line) => line.trim().startsWith('Version:'));

  return lines.join('\n');
}

Future<KeyPair> generateKeyPair() async {
  try {
    final keyOptions = KeyOptions()
      ..algorithm = Algorithm.RSA
      ..rsaBits = 2048;

    final keyPair =
        await OpenPGP.generate(options: Options()..keyOptions = keyOptions);
    keyPair.privateKey = removeVersionFromPublicKey(keyPair.privateKey);
    keyPair.publicKey = removeVersionFromPublicKey(keyPair.publicKey);
    return keyPair;
  } catch (error) {
    print(error);
    throw Exception(error);
  }
}

Future<String> sign({
  required String message,
  required String privateKey,
}) async {
  final signatureWithVersion = await OpenPGP.sign(message, privateKey, "");
  return removeVersionFromPublicKey(signatureWithVersion);
}

Future<String> pgpEncrypt({
  required String plainText,
  required List<String> keys,
}) async {
  final combinedPGPKey = keys.join();

  final encrypted = await OpenPGP.encrypt(
    plainText,
    combinedPGPKey,
  );
  return encrypted;
}

Future<String> pgpDecrypt({
  required String cipherText,
  required String privateKeyArmored,
}) async {
  try {
    return OpenPGP.decrypt(cipherText, privateKeyArmored, '');
  } catch (e) {
    log('pgpDecrypt Error $e');
    rethrow;
  }
}

Future<void> verifySignature(
    {required String messageContent,
    required String signatureArmored,
    required String publicKeyArmored}) async {
  try {
    await OpenPGP.verify(
      signatureArmored,
      messageContent,
      publicKeyArmored,
    );
  } catch (e) {
    log('verifySignature Error ${e.toString()}');
  }
}
