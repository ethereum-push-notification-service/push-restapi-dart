import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

final chatRoomProvider = ChangeNotifierProvider((ref) => ChatRoomProvider(ref));

class ChatRoomProvider extends ChangeNotifier {
  final Ref ref;

  ChatRoomProvider(this.ref) {
    controller.addListener(() {
      notifyListeners();
    });
  }

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
  Feeds _room = Feeds();
  Feeds get room => _room;

  String messageType = MessageType.TEXT;

  setCurrentChat(Feeds room) {
    final chatId = room.chatId!;
    _room = room;
    _messageList = _localMessagesCache[chatId] ?? [];
    _currentChatid = chatId;
    controller.clear();

    notifyListeners();
    getRoomMessages();

    if (room.groupInformation != null) {
      getLatesGroupInfo();
    }
  }

  Message? replyTo;
  setReplyMessage(Message? message) {
    replyTo = message;
    notifyListeners();
  }

  onRefreshRoom({
    GroupInfoDTO? groupData,
  }) async {
    if (groupData != null && groupData.chatId == _currentChatid) {
      _room.groupInformation =
          GroupDTO.fromJson(groupData.toJson()); //groupData;
      notifyListeners();
    }

    getRoomMessages();

    getLatesGroupInfo();
  }

  Future getRoomMessages() async {
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

    ///limit to 90
    if (_messageList.length >= 90) {
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
      String content = controller.text.trim();
      if (content.isEmpty && selectedFile == null) {
        return;
      }

      final currentUser = ref.read(accountProvider).pushWallet;

      SendMessage? messageAttachment;
      String? attachmentContent;

      if (selectedFile != null && messageType == MessageType.IMAGE) {
        final img = base64Encode(selectedFile!.readAsBytesSync());
        attachmentContent = jsonEncode({'content': img});
        messageAttachment = ImageMessage(
          content: img,
          name: selectedFile?.uri.pathSegments.last,
        );
      }

      var options;

      if (replyTo == null) {
        options = ChatSendOptions(
          message: messageAttachment,
          messageContent: content,
          receiverAddress: currentChatId,
        );
      } else {
        options = ChatSendOptions(
          message: ReplyMessage(
              content: NestedContent(type: messageType, content: content),
              reference: jsonEncode(replyTo!.toJson())),
          receiverAddress: currentChatId,
        );
      }

      _messageList.insert(
        0,
        Message(
          fromCAIP10: '',
          toCAIP10: '',
          fromDID: walletToPCAIP10('${currentUser?.address}'),
          toDID: '',
          messageType: messageType,
          messageContent: attachmentContent ?? content,
          messageObj: MessageObject(
            reference: replyTo == null ? null : jsonEncode(replyTo!.toJson()),
            content: Content(
              messageObj: MessageObj(content: attachmentContent ?? content),
              messageType: messageType,
            ),
          ).toJson(),
          signature: '',
          sigType: '',
          encType: '',
          encryptedSecret: '',
          timestamp: DateTime.now().microsecondsSinceEpoch,
        ),
      );

      clearFields();

      updateSending(true);
      final message = await send(options);
      updateSending(false);
      print('onSendMessage...5..after send..${message?.toJson()}');
      if (message != null) {
        getRoomMessages();
      }
    } catch (e) {
      updateSending(false);
      print(e);
    }
  }

  Future getLatesGroupInfo() async {
    final result = await getGroup(chatId: _currentChatid);
    _room.groupInformation = result;
    notifyListeners();
  }

  GroupDTO? get groupInformation => _room.groupInformation;

  List<MemberDTO> get admins {
    return groupInformation?.members
            .where((element) => element.isAdmin == true)
            .toList() ??
        [];
  }

  List<MemberDTO> get members =>
      groupInformation?.members
          .where((element) => element.isAdmin != true)
          .toList() ??
      [];

  List<MemberDTO> get pendingMembers => groupInformation?.pendingMembers ?? [];

  String get currentUser => ref.read(accountProvider).pushWallet?.address ?? '';

  bool get isUserAdmin =>
      admins.map((e) => e.wallet).contains(walletToPCAIP10(currentUser));

  File? _selectedFile;
  File? get selectedFile => _selectedFile;
  Future onSelectFile() async {
    Get.bottomSheet(AttachmentDialog(
      onSelect: (File? file, String type) async {
        pop();
        if (file != null) {
          _selectedFile = file;
          controller.clear();
          messageType = type;
          notifyListeners();
        }
      },
    ));
  }

  clearSelectedFile() async {
    _selectedFile = null;
    messageType = MessageType.TEXT;
    notifyListeners();
  }

  clearFields() {
    _selectedFile = null;
    controller.clear();
    messageType = MessageType.TEXT;
    replyTo = null;
    notifyListeners();
  }
}

class AttachmentDialog extends StatelessWidget {
  const AttachmentDialog({
    super.key,
    required this.onSelect,
  });

  final Function(File?, String) onSelect;

  @override
  Widget build(BuildContext context) {
    final options = [
      NavItem(
        icon: Icons.camera_alt_rounded,
        title: '${MessageType.IMAGE} (Camera)',
        onPressed: () async {
          final file =
              await AppFilePicker.pickImage(source: ImageSource.camera);
          onSelect(file, MessageType.IMAGE);
        },
      ),
      NavItem(
        icon: Icons.photo_library_rounded,
        title: '${MessageType.IMAGE} (Gallery)',
        onPressed: () async {
          final file =
              await AppFilePicker.pickImage(source: ImageSource.gallery);
          onSelect(file, MessageType.IMAGE);
        },
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          SizedBox(height: 24),
          Text(
            'Select Attachment',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          ...options.map(
            (e) => InkWell(
              onTap: e.onPressed,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.grey.withOpacity(.5)))),
                child: Row(
                  children: [
                    Icon(e.icon),
                    SizedBox(width: 16),
                    Text(e.title),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
