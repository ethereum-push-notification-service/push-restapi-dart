import 'package:push_restapi_dart/push_restapi_dart.dart';

void testFetchRequests() async {
  final result = await requests(
      toDecrypt: false,
      accountAddress: 'eip155:0x35B84d6848D16415177c64D64504663b998A6ab4');

  print(result);
  if (result != null && result.isNotEmpty) {
    print(
        'testFetchRequests messageContent: ${result.first.msg?.messageContent}');
  }
}

void testApproveRequests() async {
  final result = await approve(senderAddress: 'senderAddress');

  print(result);
}
