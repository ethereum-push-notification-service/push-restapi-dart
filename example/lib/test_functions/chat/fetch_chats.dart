import 'package:push_restapi_dart/push_restapi_dart.dart';

void testFetchChats() async {
  final result = await chats(
    accountAddress: 'eip155:0x35B84d6848D16415177c64D64504663b998A6ab4',
    toDecrypt: false,
  );

  print(result);
  if (result != null && result.isNotEmpty) {
    print('testFetchChats messageContent: ${result.first.msg?.messageContent}');
    print('testFetchChats messageContent: ${result.first.msg?.link}');
  }
}

testAES() {
  final ciphertextOriginal = "U2FsdGVkX18/SWOonW/UfODCpIrRFuOUKITIvRob3iE=";
  final key = "XxJNyUTlCFrrbTG";

  final decryptedMessage = "pong";

  final result = aesDecrypt(cipherText: ciphertextOriginal, secretKey: key);
  print('testAES: result $result, isCorrect: ${result == decryptedMessage}');
}

testSign() async {
  try {
    final result = await signMessageWithPGPCore(
      message: 'message',
      privateKeyArmored: 'privateKeyArmored',
    );

    print('testSign: result $result');
  } catch (e) {
    print('testSign: error ${e}');
  }
}
