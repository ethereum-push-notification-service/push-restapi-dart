import 'package:push_restapi_dart/push_restapi_dart.dart';

import 'dart:math' as m;

import '../../../__lib.dart';

final liveSpaceProvider = ChangeNotifierProvider<LiveSpaceProvider>((ref) {
  return LiveSpaceProvider(ref);
});

class LiveSpaceProvider extends PushSpaceNotifier {
  final Ref ref;

  LiveSpaceProvider(this.ref);

  List<ListenerPeer> get micRequests =>
      data.liveSpaceData.listeners.where((e) => e.handRaised).toList();

  get random => m.Random();
  get tween => Tween<Offset>(
        begin: Offset(random.nextDouble() * .5, random.nextDouble()),
        end: Offset(0, (random.nextDouble() * -1) - 1),
      ).chain(CurveTween(curve: Curves.linear));

  List<String> reactions = [];

  onReceiveReaction({required String reaction, required String from}) {
    reactions.insert(0, '$from   $reaction');

    notifyListeners();

    Future.delayed(
      Duration(seconds: 4),
      () {
        if (reactions.isNotEmpty) {
          reactions.removeLast();
        }

        notifyListeners();
      },
    );
  }

  onReceiveSpaceEndedData(String spaceId) async {
    if (spaceId == data.spaceId) {
      showLoadingDialog();
      showSuccessSnackbar('Host has ended the space');
      leave().then((value) {
        showMyDialog(
          context: Get.context!,
          title: 'Space',
          message: 'Space Ended by Host',
          onClose: () {
            pop();
            pop();
            pop();
          },
        );
      });

      //Reload Space invites, Spaces for you and by you
      ref.read(yourSpacesProvider).onRefresh();
      ref.read(spaceRequestsProvider).loadRequests();
    }
  }
}
