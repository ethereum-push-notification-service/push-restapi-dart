import '../__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:ethers/signers/wallet.dart' as ether;

final accountProvider = ChangeNotifierProvider((ref) => AccountProvider(ref));

class AccountProvider extends ChangeNotifier {
  final Ref ref;

  AccountProvider(this.ref);

  Wallet? pushWallet;

  final mnemonic1 =
      'glory science timber unknown happy doctor walnut grain question float coffee trip';
  final mnemonic2 =
      'label mobile gas salt service gravity nose bomb marine online say twice';
  final mnemonic3 =
      'priority feed chair canoe news gym cost permit sea worry modify save';
  final mnemonic4 =
      'roast exclude blame mixture dune neither vital liquid winter summer nation solution';
  final mnemonic5 =
      'picnic crystal plug narrow siege need beach sphere radar wide ship trust';

  List<DemoUser> get accounts => [
        DemoUser(
            mnemonic: mnemonic1,
            address: '0xD3FD4422210E69Fe8cD790a546Cbb5d7DCe904Ce'),
        DemoUser(
            mnemonic: mnemonic2,
            address: '0x8ca107e6845b095599FDc1A937E6f16677a90325'),
        DemoUser(
            mnemonic: mnemonic3,
            address: '0x9e16C5B631C3328843fA7d2acc8edd100f21693a'),
        DemoUser(
            mnemonic: mnemonic4,
            address: '0x87bBCDe9DF530bC106B1D958e23b61c33b7Ee194'),
        DemoUser(
            mnemonic: mnemonic5,
            address: '0x29b8276AA5bc432e03745eF275ded9074faB5970'),
      ];

  connectWallet(String mnemonic) async {
    try {
      showLoadingDialog();
      final ethersWallet = ether.Wallet.fromMnemonic(mnemonic);
      final signer = EthersSigner(
        ethersWallet: ethersWallet,
        address: ethersWallet.address!,
      );

      print('walletMnemonic.address: ${ethersWallet.address}');
      final user = await getUser(address: ethersWallet.address!);

      if (user == null) {
        pop();
        print('Cannot get user');
        return;
      }

      String? pgpPrivateKey = null;
      if (user.encryptedPrivateKey != null) {
        pgpPrivateKey = await decryptPGPKey(
          encryptedPGPPrivateKey: user.encryptedPrivateKey!,
          wallet: getWallet(signer: signer),
        );
      }

      print('pgpPrivateKey: $pgpPrivateKey');

      pushWallet = Wallet(
        address: ethersWallet.address,
        signer: signer,
        pgpPrivateKey: pgpPrivateKey,
      );
      notifyListeners();

      pop();

      initPush(
        wallet: pushWallet,
        env: ENV.staging,
      );
      creatSocketConnection();

      //Spaces
      ref.read(popularSpaceProvider).loadSpaces();
      ref.read(spaceRequestsProvider).loadRequests();
      ref.read(yourSpacesProvider.notifier).onRefresh();

      //CHAT
      ref.read(requestsProvider).loadRequests();
      ref.read(conversationsProvider).reset();
    } catch (e) {
      pop();
    }
  }

  io.Socket? pushSDKSocket;
  Future<void> creatSocketConnection() async {
    try {
      final options = SocketInputOptions(
        user: pushWallet!.address!,
        env: ENV.staging,
        socketType: SOCKETTYPES.CHAT,
        socketOptions: SocketOptions(
          autoConnect: true,
          reconnectionAttempts: 3,
        ),
      );

      pushSDKSocket = await createSocketConnection(options);
      if (pushSDKSocket == null) {
        throw Exception('PushSDKSocket Connection Failed');
      }

      pushSDKSocket!.connect();

      pushSDKSocket!.on(
        EVENTS.CONNECT,
        (data) async {
          print(' NOTIFICATION EVENTS.CONNECT: $data');
        },
      );
      // To get messages in realtime
      pushSDKSocket!.on(EVENTS.CHAT_RECEIVED_MESSAGE, (message) {
        print('CHAT NOTIFICATION EVENTS.CHAT_RECEIVED_MESSAGE: $message');
        ref.read(conversationsProvider).onReceiveSocket(message);
      });

      pushSDKSocket!.on(EVENTS.SPACES, (groupInfo) {
        print('SPACES NOTIFICATION EVENTS.SPACES: $groupInfo');

        final type = (groupInfo as Map<String, dynamic>)['eventType'];

        if (type == 'stop') {
          //Refresh Hosted by you and For you tabs to reflect ended spaces
          ref.read(yourSpacesProvider).onRefresh();
        }

        if (type == 'create') {
          //This is a fix to complement the structure of the space retured by socket
          var spaceFeed = SpaceFeeds.fromJson(groupInfo);
          spaceFeed.spaceInformation = SpaceDTO.fromJson(groupInfo);

          ref.read(spaceRequestsProvider).addReqestFromSocket(spaceFeed);
          return;
        }
      });

      // To get group creation or updation events
      pushSDKSocket!.on(EVENTS.CHAT_GROUPS, (groupInfo) {
        print('CHAT NOTIFICATION EVENTS.CHAT_GROUPS: $groupInfo');

        final type = (groupInfo as Map<String, dynamic>)['eventType'];
        final recipients = (groupInfo['to'] as List?) ?? [];
        final from = groupInfo['from'];

        if ((type == 'create' &&
                from != walletToPCAIP10(pushWallet!.address!)) ||
            (type == 'request' &&
                recipients.contains(walletToPCAIP10(pushWallet!.address!)))) {
          ref.read(requestsProvider).addReqestFromSocket(
                Feeds(
                  chatId: groupInfo['chatId'],
                  intentSentBy: groupInfo['groupName'] ?? groupInfo['from'],
                ),
              );
          return;
        }
        ref.read(conversationsProvider).onReceiveSocket(groupInfo);
      });

      // To get realtime updates for spaces
      pushSDKSocket!.on(
        EVENTS.SPACES_MESSAGES,
        (data) async {
          final message = data as Map<String, dynamic>;
          print(
              'SPACES NOTIFICATION EVENTS.SPACES_MESSAGES messageCategory ${message['messageCategory']} messageType ${message['messageType']}');
          for (var element in message.keys) {
            print('$element -> ${message[element]}');
          }

          // Check if the message is a chat meta message or chat user activity message
          if (message['messageCategory'] == 'Chat' &&
              (message['messageType'] == MessageType.META ||
                  message['messageType'] == MessageType.USER_ACTIVITY)) {
            ref.read(liveSpaceProvider).onReceiveMetaMessage(message);
          }

          //Check if space was ended
          if (message['messageCategory'] == 'Chat' &&
              message['messageContent'] == CHAT.META_SPACE_END &&
              message["fromDID"] != walletToPCAIP10(pushWallet!.address!)) {
            ref
                .read(liveSpaceProvider)
                .onReceiveSpaceEndedData(message["chatId"]);
          }
          //Check if promotion invite was sent
          if (message['messageCategory'] == 'Chat' &&
              message['messageContent'] ==
                  CHAT.META_SPACE_LISTENER_PROMOTE_INVITE) {
            try {
              final invitedUsers = message["messageObj"]["info"]['affected'];

              if (invitedUsers.contains(pushWallet?.address)) {
                ref
                    .read(liveSpaceProvider)
                    .onReceivePromotionInvite(message["chatId"]);
              }
            } catch (e) {}
          }

          if (message['messageCategory'] == 'Chat' &&
              (message['messageType'] == MessageType.REACTION)) {
            try {
              final reaction = data['messageObj']['content'];
              final reactionFrom = data['fromDID'];

              ref
                  .read(liveSpaceProvider)
                  .onReceiveReaction(reaction: reaction, from: reactionFrom);
            } catch (e) {
              print(e);
            }
          }
        },
      );

      pushSDKSocket!.on(
        EVENTS.DISCONNECT,
        (data) {
          print(' NOTIFICATION EVENTS.DISCONNECT: $data');
        },
      );
    } catch (e) {
      print(e);
    }
  }

  logOut() {
    pushWallet = null;
    if (pushSDKSocket != null) {
      pushSDKSocket!.close();
      pushSDKSocket = null;
    }

    notifyListeners();
  }
}

class DemoUser {
  final String mnemonic, address;

  DemoUser({
    required this.mnemonic,
    required this.address,
  });
}
