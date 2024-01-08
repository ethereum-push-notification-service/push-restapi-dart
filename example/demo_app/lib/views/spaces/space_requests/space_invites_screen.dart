import 'package:example/__lib.dart';

class SpaceInvitesDailog extends ConsumerStatefulWidget {
  const SpaceInvitesDailog({super.key});

  @override
  ConsumerState<SpaceInvitesDailog> createState() => _SpaceInvitesDailogState();
}

class _SpaceInvitesDailogState extends ConsumerState<SpaceInvitesDailog> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(spaceRequestsProvider).loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final requests = ref.watch(spaceRequestsProvider).requestsList;
          if (requests == null) {
            return SizedBox(
                height: 300,
                width: double.infinity,
                child: Text('Cannot load Invites'));
          }
          if (requests.isEmpty) {
            return SizedBox(
                height: 300,
                width: double.infinity,
                child: Column(
                  children: [
                    SvgPicture.asset('assets/space.svg'),
                    Text('No Invites found'),
                  ],
                ));
          }
          return Column(
            children: [
              SizedBox(height: 16),
              KText(
                'Space Invites',
                color: pushColor,
                size: 20,
                weight: FontWeight.w600,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: ref.read(spaceRequestsProvider).loadRequests,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) =>
                        SpaceItemTile(item: requests[index]),
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemCount: requests.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
