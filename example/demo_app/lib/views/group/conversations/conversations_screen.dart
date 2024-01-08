import 'dart:typed_data';

import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

class ConversationsScreen extends ConsumerStatefulWidget {
  const ConversationsScreen({super.key});

  @override
  ConsumerState<ConversationsScreen> createState() =>
      _ConversationsScreenState();
}

class _ConversationsScreenState extends ConsumerState<ConversationsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(conversationsProvider).loadChats();
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      // floatingActionButton: MaterialButton(
      //   height: 64,
      //   color: pushColor,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //   onPressed: () {
      //     pushScreen(StartP2PChatScreen());
      //   },
      //   textColor: Colors.white,
      //   child: Text('Start New Chat'),
      //   padding: EdgeInsets.all(16),
      // ),
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final vm = ref.watch(conversationsProvider);
          final spaces = vm.conversations;
          if (vm.isBusy && spaces.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await vm.loadChats();
            },
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 32),
              separatorBuilder: (context, index) => Divider(),
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                final item = spaces[index];
                final image =
                    item.groupInformation?.groupImage ?? item.profilePicture;

                return ListTile(
                  onTap: () {
                    pushScreen(ChatRoomScreen(room: item));
                  },
                  leading: ProfileImage(imageUrl: image),
                  title: Text(
                      '${item.groupInformation?.groupName ?? item.intentSentBy}'),
                  subtitle: Text(
                    item.msg?.messageType == MessageType.TEXT
                        ? item.msg?.messageContent ?? 'Send first message'
                        : '${item.msg?.messageType} was sent by ${item.msg?.fromDID}',
                    maxLines: 1,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  const ProfileImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
  });
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purpleAccent),
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(
          Icons.person,
          color: pushColor,
        ),
      );
    }
    try {
      if (imageUrl!.startsWith('https://')) {
        return Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purpleAccent),
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(
                imageUrl!,
              ),
              fit: BoxFit.cover,
            ),
          ),
        );
      }

      final UriData? data = Uri.parse(imageUrl!).data;

      Uint8List myImage = data!.contentAsBytes();

      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purpleAccent),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: MemoryImage(
              myImage,
            ),
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purpleAccent),
          shape: BoxShape.circle,
          color: pushColor,
        ),
      );
    }
  }
}
