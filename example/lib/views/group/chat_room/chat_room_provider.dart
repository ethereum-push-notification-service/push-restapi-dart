import 'package:example/views/account_provider.dart';

import '../../../__lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

final chatRoomProvider = ChangeNotifierProvider((ref) => ChatRoomProvider(ref));

class ChatRoomProvider extends ChangeNotifier {
  final Ref ref;

  ChatRoomProvider(this.ref);

  bool isLoading = false;
  updateLoading(bool state) {
    isLoading = state;
    notifyListeners();
  }

  List<Message> _messageList = <Message>[];
  List<Message> get messageList => _messageList;
  Map<String, List<Message>> _localMessagesCache = {};

  String _currentChatid = '';

  String get currentChatId => _currentChatid;
  setCurrentChatId(String chatId) {
    _messageList = _localMessagesCache[chatId] ?? [];
    _currentChatid = chatId;
    notifyListeners();
    getRoomMessages();
  }

  getRoomMessages() async {
    updateLoading(true);
    String? hash = await conversationHash(conversationId: currentChatId);

    List<Message>? messages = null;
    if (hash != null) {
      messages = await history(
        limit: FetchLimit.MAX,
        threadhash: hash,
        toDecrypt: true,
      );
    }

    updateLoading(false);

    if (messages != null) {
      _messageList = messages;
      _localMessagesCache[currentChatId] = _messageList;
      getOlderMessages();
    } else {
      _messageList = _localMessagesCache[currentChatId] ?? [];
    }
    notifyListeners();
  }

  getOlderMessages() async {
    if (currentChatId != messageList.last.toCAIP10) {
      return;
    }
    final hash = _messageList.last.link;
    if (hash != null) {
      final messages = await history(
        limit: FetchLimit.MAX,
        threadhash: hash,
        toDecrypt: true,
      );

      if (messages != null) {
        _messageList += messages;
        _localMessagesCache[currentChatId] = _messageList;
        notifyListeners();
        getOlderMessages();
      }
    }
  }

  bool isSending = false;
  updateSending(bool state) {
    isSending = state;
    notifyListeners();
  }

  TextEditingController controller = TextEditingController();
  onSendMessage() async {
    try {
      final content = controller.text.trim();
      if (content.isEmpty) {
        return;
      }

      final currentUser = ref.read(accountProvider).pushWallet;
      final options = ChatSendOptions(
          messageContent: content, receiverAddress: currentChatId);
      _messageList.insert(
        0,
        Message(
            fromCAIP10: '',
            toCAIP10: '',
            fromDID: walletToPCAIP10('${currentUser?.address}'),
            toDID: '',
            messageType: '',
            messageContent: content,
            signature: '',
            sigType: '',
            encType: '',
            encryptedSecret: '',
            timestamp: DateTime.now().microsecondsSinceEpoch),
      );
      controller.clear();

      updateSending(true);
      final message = await send(options);
      updateSending(false);

      if (message != null) {
        getRoomMessages();
      }
    } catch (e) {
      updateSending(false);
    }
  }
}