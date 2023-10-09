import '../../../__lib.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

final requestsProvider = ChangeNotifierProvider((ref) => RequestsProvider(ref));

class RequestsProvider extends ChangeNotifier {
  final Ref ref;
  RequestsProvider(this.ref);

  List<Feeds>? _requests;
  List<Feeds>? get requestsList => _requests;

  bool isBusy = false;
  setBusy(bool state) {
    isBusy = state;
    notifyListeners();
  }

  loadRequests() async {
    setBusy(true);
    _requests = await requests(toDecrypt: true);

    setBusy(false);
  }

  addReqestFromSocket(Feeds req) {
    if (_requests != null) {
      _requests!.add(req);
    } else {
      _requests = [req];
    }
    notifyListeners();
  }
}
