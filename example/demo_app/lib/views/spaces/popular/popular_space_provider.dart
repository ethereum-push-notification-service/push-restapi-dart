import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

final popularSpaceProvider =
    ChangeNotifierProvider((ref) => PopularSpaceProvider(ref));

class PopularSpaceProvider extends ChangeNotifier {
  final Ref ref;
  PopularSpaceProvider(this.ref) {
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

  loadSpaces() async {
    setBusy(true);
    _spaces = await trending();

    setBusy(false);
  }
}
