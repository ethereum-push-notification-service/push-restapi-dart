import '../../../__lib.dart';

class HostedByYouTab extends ConsumerStatefulWidget {
  const HostedByYouTab({
    super.key,
  });

  @override
  ConsumerState<HostedByYouTab> createState() => _HostedByYouTabState();
}

class _HostedByYouTabState extends ConsumerState<HostedByYouTab> {
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(yourSpacesProvider);
    final filter = vm.filterList;
    final currentFilter = vm.filterType;
    final spaces = vm.hostedByYou;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Wrap(
            spacing: 10,
            children: List.generate(filter.length, (index) {
              final item = filter[index];
              return InkWell(
                onTap: item.onPressed,
                child: Chip(
                  backgroundColor:
                      currentFilter == item.count ? pushColor : Colors.grey,
                  label: KText(
                    item.title,
                    color: Colors.white,
                  ),
                ),
              );
            })),
        SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await vm.onRefresh();
            },
            child: vm.isBusy && (spaces ?? []).isEmpty
                ? Center(
                    child: LoadingDialog(),
                  )
                : spaces == null
                    ? Center(child: Text('Cannot load Spaces'))
                    : spaces.isEmpty
                        ? Center(
                            child: InkWell(
                              onTap: () {
                                pushScreen(CreateSpaceScreen());
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/space.svg'),
                                  SizedBox(height: 16),
                                  Text('Create a space'),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12),
                            itemCount: spaces.length,
                            itemBuilder: (context, index) {
                              return SpaceItemTile(item: spaces[index]);
                            },
                          ),
          ),
        ),
      ],
    );
  }
}
