import 'package:push_restapi_dart/push_restapi_dart.dart' as push;

void testFetchLatestChat() async {
  final result = await push.latest(
    threadhash: 'bafyreieoui4h44ncoi5vuekcisfjbt4on5sh3eyl3ujbrj5ulqn6mruz3m',
  );

  print(result);
  if (result != null) {
    print('testFetchChats messageContent: ${result.messageContent}');
  }
}

void testChatHistory() async {
  final result = await push.history(
    toDecrypt: true,
    threadhash: 'bafyreieoui4h44ncoi5vuekcisfjbt4on5sh3eyl3ujbrj5ulqn6mruz3m',
  );

  print(result);
  if (result != null) {
    print('testChatHistory messageContent: ${result.first.messageContent}');
  }
}
