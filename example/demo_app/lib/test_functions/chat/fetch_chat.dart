import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

void testFetchP2PChat() async {
  final result = await push.chat(
    recipient: '0x9960D6B63B113303B9910A03ca5341B83CC52723',
  );

  print(result);
  if (result != null) {
    print('testFetchChats messageContent: ${result.msg?.messageContent}');
  }
}
