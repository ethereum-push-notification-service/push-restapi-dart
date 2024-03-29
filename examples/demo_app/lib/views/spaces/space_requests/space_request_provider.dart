import '../../../__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

final spaceRequestsProvider =
    ChangeNotifierProvider((ref) => SpaceRequestsProvider(ref));

class SpaceRequestsProvider extends ChangeNotifier {
  final Ref ref;
  SpaceRequestsProvider(this.ref);

  List<SpaceFeeds>? _requests;
  List<SpaceFeeds>? get requestsList => _requests;

  String get localAddress => ref.read(accountProvider).pushUser!.account;
  PushAPI get pushUser => ref.read(accountProvider).pushUser!;

  bool isBusy = false;
  setBusy(bool state) {
    isBusy = state;
    notifyListeners();
  }

  Future loadRequests() async {
    setBusy(true);
    _requests = await spaceRequests(
      accountAddress: pushUser.account,
      pgpPrivateKey: pushUser.decryptedPgpPvtKey,
      toDecrypt: true,
    );

    setBusy(false);
  }

  addReqestFromSocket(SpaceFeeds req) {
    if (_requests != null) {
      _requests!.insert(0, req);
    } else {
      _requests = [req];
    }
    notifyListeners();
  }
}
