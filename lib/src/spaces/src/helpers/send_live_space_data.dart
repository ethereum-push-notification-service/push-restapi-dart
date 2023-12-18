import 'package:push_restapi_dart/push_restapi_dart.dart';

Future sendLiveSpaceData({
  required String messageType,
  required LiveSpaceData updatedLiveSpaceData,
  required String content,
  required List<String> affectedAddresses,
  required String spaceId,
}) async {
  if (messageType != MessageType.META &&
      messageType != MessageType.USER_ACTIVITY) {
    throw Exception(
        "Live space data supports only META, USER_ACTIVITY message types");
  }

  final message = messageType == MessageType.META
      ? MetaMessage(
          info: Info(
            affected: affectedAddresses,
            arbitrary: updatedLiveSpaceData.toJson(),
          ),
          content: content,
        )
      : UserActivityMessage(
          info: Info(
            affected: affectedAddresses,
            arbitrary: updatedLiveSpaceData.toJson(),
          ),
          content: content,
        );

  final options = ChatSendOptions(
    messageType: messageType,
    message: message,
    to: spaceId,
  );

  return send(options);
}
