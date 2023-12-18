import 'package:blockies/blockies.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

class SpaceModerationView extends ConsumerStatefulWidget {
  const SpaceModerationView({
    super.key,
  });

  @override
  ConsumerState<SpaceModerationView> createState() =>
      _SpaceModerationViewState();
}

class _SpaceModerationViewState extends ConsumerState<SpaceModerationView> {
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(liveSpaceProvider);

    final liveSpaceData = vm.liveSpaceData;

    final localAddress = ref.read(accountProvider).pushWallet?.address;
    bool isHost = localAddress == liveSpaceData.host.address;

    return DefaultTabController(
      length: 4,
      child: Container(
        height: 640,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.purple.withOpacity(.5),
                ]),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(36),
              topRight: Radius.circular(36),
            ),
            color: Colors.white),
        child: Column(
          children: [
            KText(
              'Moderate',
              weight: FontWeight.w600,
              size: 16,
            ),
            SizedBox(height: 16),
            TabBar(isScrollable: true, tabs: [
              Tab(
                text: 'Mic Requests',
              ),
              Tab(
                text: 'Pending Invites',
              ),
              Tab(
                text: 'Speakers',
              ),
              Tab(
                text: 'Listerners',
              ),
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  _MicRequestsTab(
                    micRequests: vm.micRequests,
                    ref: ref,
                  ),
                  _SpacePendingInvitesTab(
                    invites: vm.pendingInvites,
                    isUserHost: isHost,
                    spaceId: vm.data.spaceId,
                  ),
                  _SpaceSpeakersTab(
                    spaceId: vm.data.spaceId,
                    isUserHost: isHost,
                    speakers: liveSpaceData.speakers,
                  ),
                  _SpaceListernersTab(
                    spaceId: vm.data.spaceId,
                    isUserHost: isHost,
                    listerners: liveSpaceData.listeners,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MicRequestsTab extends StatelessWidget {
  const _MicRequestsTab({
    required this.micRequests,
    required this.ref,
  });

  final List<ListenerPeer> micRequests;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: micRequests.isEmpty
          ? Center(
              child: KText('No requests found'),
            )
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                final item = micRequests[index];
                return Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Blockies(
                            seed: item.address,
                            size: 4,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                          child: Column(
                        children: [
                          KText(item.address),
                          Align(
                            alignment: Alignment.topRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    showLoadingDialog();
                                    ref
                                        .read(liveSpaceProvider)
                                        .acceptPromotionRequest(
                                            promoteeAddress: item.address)
                                        .then((value) {
                                      pop();
                                    });
                                  },
                                  child: Text(
                                    "Promote to Speaker",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 14),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    ref
                                        .read(liveSpaceProvider)
                                        .rejectPromotionRequest(
                                            promoteeAddress: item.address);
                                  },
                                  child: Text(
                                    'Reject',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ))
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: 4),
              itemCount: micRequests.length),
    );
  }
}

class _SpaceListernersTab extends StatelessWidget {
  const _SpaceListernersTab({
    required this.listerners,
    required this.isUserHost,
    required this.spaceId,
  });

  final List<ListenerPeer> listerners;

  final bool isUserHost;
  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: listerners.isEmpty
                ? Center(
                    child: Text('No Listerner joined'),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: listerners.length,
                    itemBuilder: (context, index) {
                      final item = listerners[index];
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                  // shape: BoxShape.circle,
                                  ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Blockies(
                                  seed: item.address,
                                  size: 4,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                                child: Column(
                              children: [
                                KText(item.address),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Consumer(
                                    builder: (context, ref, child) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              ref
                                                  .read(liveSpaceProvider)
                                                  .inviteToPromote(
                                                      inviteeAddress:
                                                          item.address);

                                              showSuccessSnackbar(
                                                  'Invite sent to ${item.address}');
                                            } catch (e) {
                                              showErrorSnackbar(
                                                  'Error sending invite \n$e');
                                            }
                                          },
                                          child: Text(
                                            'Invite to Speak',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (isUserHost)
            MaterialButton(
              color: pushColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                pop();
                Get.bottomSheet(
                    SendSpaceInviteDialog(spaceId: spaceId, isSpeaker: false));
              },
              textColor: Colors.white,
              child: Center(child: Text('Send Space Invite')),
              padding: EdgeInsets.all(16),
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SpacePendingInvitesTab extends StatelessWidget {
  const _SpacePendingInvitesTab({
    required this.invites,
    required this.isUserHost,
    required this.spaceId,
  });

  final List<String> invites;

  final bool isUserHost;
  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: invites.isEmpty
                ? Center(
                    child: Text('No Pendeing Invites'),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: invites.length,
                    itemBuilder: (context, index) {
                      final item = invites[index];
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                  // shape: BoxShape.circle,
                                  ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Blockies(
                                  seed: item,
                                  size: 4,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                                child: Column(
                              children: [
                                KText(item),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Consumer(
                                    builder: (context, ref, child) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () async {},
                                          child: Text(
                                            'Cancel Invite',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SpaceSpeakersTab extends StatelessWidget {
  const _SpaceSpeakersTab({
    required this.speakers,
    required this.isUserHost,
    required this.spaceId,
  });

  final List<AdminPeer> speakers;

  final bool isUserHost;
  final String spaceId;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: speakers.isEmpty
                ? Center(
                    child: Text('No Speaker joined'),
                  )
                : ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    itemCount: speakers.length,
                    itemBuilder: (context, index) {
                      final item = speakers[index];
                      return Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              height: 64,
                              width: 64,
                              decoration: BoxDecoration(
                                  // shape: BoxShape.circle,
                                  ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Blockies(
                                  seed: item.address,
                                  size: 4,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                                child: Column(
                              children: [
                                KText(item.address),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Consumer(
                                    builder: (context, ref, child) => Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              showLoadingDialog();
                                              removeSpeakers(
                                                      spaceId: spaceId,
                                                      speakers: [item.address])
                                                  .then((value) {
                                                pop();
                                              });
                                            } catch (e) {
                                              pop();
                                            }
                                          },
                                          child: Text(
                                            'Remove speaker',
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ))
                          ],
                        ),
                      );
                    },
                  ),
          ),
          if (isUserHost)
            MaterialButton(
              color: pushColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: () {
                pop();
                Get.bottomSheet(SendSpaceInviteDialog(
                  spaceId: spaceId,
                  isSpeaker: true,
                ));
              },
              textColor: Colors.white,
              child: Center(child: Text('Send Space Invite')),
              padding: EdgeInsets.all(16),
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
