import 'package:push_restapi_dart/push_restapi_dart.dart';

Future<void> notificationSocketConnection() async {
  final options = SocketInputOptions(
    user: '0x754E2C9f31D7DB279E9d4A9140e33ad8839E1FAd',
    env: ENV.staging,
    socketType: SOCKETTYPES.NOTIFICATION,
    socketOptions: SocketOptions(
      autoConnect: false,
      reconnectionAttempts: 0,
    ),
  );

  final pushSDKSocket = await createSocketConnection(options);
  if (pushSDKSocket == null) {
    throw Exception('PushSDKSocket | Notification Socket Connection Failed');
  }

  pushSDKSocket.connect();

  pushSDKSocket.on(
    EVENTS.CONNECT,
    (data) async {
      print(' NOTIFICATION EVENTS.CONNECT: $data');

      await Future.delayed(
          Duration(seconds: 5)); // Delay after connection is established
      pushSDKSocket.disconnect();
    },
  );
  // Listening Feeds ( Notifications received by user )
  pushSDKSocket.on(
    EVENTS.USER_FEEDS,
    (data) {
      print(' EVENTS.USER_FEEDS: $data');
    },
  );
  // Listening Spam Feeds ( Spam Notifications received by user )
  pushSDKSocket.on(
    EVENTS.USER_SPAM_FEEDS,
    (data) {
      print(' EVENTS.USER_SPAM_FEEDS: $data');
    },
  );
  pushSDKSocket.on(
    EVENTS.DISCONNECT,
    (data) {
      print(' NOTIFICATION EVENTS.DISCONNECT: $data');
    },
  );
}

Future<void> chatSocketConnection() async {
  final options = SocketInputOptions(
    user: '0x35B84d6848D16415177c64D64504663b998A6ab4',
    env: ENV.staging,
    socketType: SOCKETTYPES.CHAT,
    socketOptions: SocketOptions(
      autoConnect: false,
      reconnectionAttempts: 0,
    ),
  );

  final pushSDKSocket = await createSocketConnection(options);
  if (pushSDKSocket == null) {
    throw Exception('PushSDKSocket | Chat Socket Connection Failed');
  }

  pushSDKSocket.connect();

  pushSDKSocket.on(
    EVENTS.CONNECT,
    (data) async {
      print(' CHAT EVENTS.CONNECT: $data');

      await Future.delayed(
          Duration(seconds: 5)); // Delay after connection is established
      pushSDKSocket.disconnect();
    },
  );
  pushSDKSocket.on(
    EVENTS.CHAT_RECEIVED_MESSAGE,
    (data) {
      print(' EVENTS.CHAT_RECEIVED_MESSAGE: $data');
    },
  );
  pushSDKSocket.on(
    EVENTS.CHAT_GROUPS,
    (data) {
      print(' EVENTS.CHAT_GROUPS: $data');
    },
  );
  pushSDKSocket.on(
    EVENTS.DISCONNECT,
    (data) {
      print(' CHAT EVENTS.DISCONNECT: $data');
    },
  );
}

void main() async {
  notificationSocketConnection();
  chatSocketConnection();
  await Future.delayed(Duration(seconds: 7));
}
