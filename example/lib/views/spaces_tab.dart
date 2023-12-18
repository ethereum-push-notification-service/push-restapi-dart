import '../__lib.dart';

class SpacesTab extends ConsumerStatefulWidget {
  const SpacesTab({super.key});

  @override
  ConsumerState<SpacesTab> createState() => _SpacesTabState();
}

class _SpacesTabState extends ConsumerState<SpacesTab> {
  @override
  Widget build(BuildContext context) {
    final requestsCount =
        ref.watch(spaceRequestsProvider).requestsList?.length ?? 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                pushScreen(SearchSpacesScreen());
              },
              child: Icon(
                Icons.search,
                color: pushColor,
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                pushScreen(CreateSpaceScreen());
              },
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: pushColor, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/talk.png',
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    KText(
                      'Create Space',
                      color: Colors.white,
                      size: 18,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            InkWell(
              onTap: () {
                Get.bottomSheet(SpaceInvitesDailog());
              },
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.multitrack_audio_outlined,
                      size: 30,
                    ),
                  ),
                  if (requestsCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Text(
                          requestsCount.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
            child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(
                          text: 'Popular',
                        ),
                        Tab(
                          text: 'For You',
                        ),
                        Tab(
                          text: 'Hosted by you',
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          PopularTab(),
                          ForYouTab(),
                          HostedByYouTab(),
                        ],
                      ),
                    ),
                  ],
                )))
      ],
    );
  }
}
