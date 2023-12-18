import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

class ChatRequestScreen extends ConsumerStatefulWidget {
  const ChatRequestScreen({super.key});

  @override
  ConsumerState<ChatRequestScreen> createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends ConsumerState<ChatRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
        actions: [
          InkWell(
            onTap: () {
              ref.read(requestsProvider).loadRequests();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          )
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final vm = ref.watch(requestsProvider);
          final requestsList = vm.requestsList;
          if (vm.isBusy && (requestsList ?? []).isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (requestsList == null) {
            return Center(child: Text('Cannot load Requests'));
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 32),
            separatorBuilder: (context, index) => Divider(),
            itemCount: requestsList.length,
            itemBuilder: (context, index) {
              final item = requestsList[index];
              final image = item.groupInformation?.groupImage ??
                  item.profilePicture ??
                  '';

              return ListTile(
                onTap: () {
                  onAccetRequests(item.chatId!);
                },
                leading: ProfileImage(imageUrl: image),
                title: Text(
                    '${item.groupInformation?.groupName ?? item.intentSentBy}'),
                subtitle: Text(
                  item.msg?.messageContent ?? 'Send first message',
                  maxLines: 1,
                ),
              );
            },
          );
        },
      ),
    );
  }

  onAccetRequests(String senderAddress) async {
    try {
      showLoadingDialog(context);
      final result = await approve(senderAddress: senderAddress);
      print('onAccetRequests: $result');
      pop(context);
      showMyDialog(
        context: context,
        title: 'Approve Request',
        message: result ?? 'Approve failed',
      );
    } catch (e) {
      print('onAccetRequests: Errors $e');
      showMyDialog(
        context: context,
        title: 'Approve Request Error',
        message: '$e',
      );
      pop(context);
    }

    ref.read(requestsProvider).loadRequests();
  }
}
