import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

final yourSpacesProvider =
    ChangeNotifierProvider((ref) => YourSpacesProvider(ref));

class YourSpacesProvider extends ChangeNotifier {
  final Ref ref;
  YourSpacesProvider(this.ref) {
    filterType = filterList.first.count;
  }

  List<SpaceFeeds>? _spaces;
  List<SpaceFeeds>? get spacesList {
    switch (filterType) {
      case 0:
        return _spaces;
      case 1:
        return _spaces
            ?.where((element) =>
                element.spaceInformation?.status == ChatStatus.ACTIVE)
            .toList();
      case 2:
        return _spaces
            ?.where((element) =>
                element.spaceInformation?.status == ChatStatus.PENDING)
            .toList();

      default:
        return _spaces;
    }
  }

  String get localAddress => ref.read(accountProvider).pushWallet!.address!;

  List<SpaceFeeds>? get forYou {
    return spacesList
        ?.where((element) =>
            element.spaceInformation?.spaceCreator !=
            walletToPCAIP10(localAddress))
        .toList();
  }

  List<SpaceFeeds>? get hostedByYou {
    return spacesList
        ?.where((element) =>
            element.spaceInformation?.spaceCreator ==
            walletToPCAIP10(localAddress))
        .toList();
  }

  List<NavItem> get filterList => [
        NavItem(
          count: 0,
          title: 'All',
          onPressed: () {
            filterType = 0;
            notifyListeners();
          },
        ),
        NavItem(
          count: 1,
          title: 'Live',
          onPressed: () {
            filterType = 1;
            notifyListeners();
          },
        ),
        NavItem(
          count: 2,
          title: 'Scheduled',
          onPressed: () {
            filterType = 2;
            notifyListeners();
          },
        ),
      ];

  late int filterType;

  bool isBusy = false;
  setBusy(bool state) {
    isBusy = state;
    notifyListeners();
  }

  onRefresh() async {
    setBusy(true);
    _spaces = await spaces(toDecrypt: true, limit: 5);

    setBusy(false);
  }

  addReqestFromSocket(SpaceFeeds req) {
    if (_spaces != null) {
      _spaces!.insert(0, req);
    } else {
      _spaces = [req];
    }
    notifyListeners();
  }
}
