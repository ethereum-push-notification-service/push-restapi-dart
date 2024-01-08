import 'package:intl/intl.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../__lib.dart';

class SpaceItemTile extends ConsumerStatefulWidget {
  const SpaceItemTile({
    super.key,
    required this.item,
  });
  final SpaceFeeds item;

  @override
  ConsumerState<SpaceItemTile> createState() => _SpaceItemTileState();
}

class _SpaceItemTileState extends ConsumerState<SpaceItemTile> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final date = item.spaceInformation!.scheduleAt!;

    return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: Row(
          children: [
            Column(
              children: [
                KText(
                  '${DateFormat('hh:mma').format(date)}',
                  size: 14,
                  weight: FontWeight.w500,
                ),
                KText(
                  '${DateFormat('dd MMM yy').format(date)}',
                  weight: FontWeight.w300,
                )
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KText(
                    '${item.spaceInformation?.spaceName}',
                    weight: FontWeight.w600,
                    maxLines: 2,
                  ),
                  KText(
                    '${item.spaceId}',
                    maxLines: 2,
                    size: 10,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            action(item),
          ],
        ));
  }

  Widget action(SpaceFeeds item) {
    final localAddress = ref.read(accountProvider).pushWallet?.address;
    bool isHost =
        walletToPCAIP10(localAddress!) == item.spaceInformation?.spaceCreator;
    if (item.spaceInformation?.status == ChatStatus.PENDING) {
      if (isHost) {
        return TextButton(
            onPressed: () => onStart(item),
            child: KText(
              'Start',
              color: pushColor,
              size: 18,
              weight: FontWeight.w600,
            ));
      } else {
        return IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.notification_add,
            color: pushColor,
          ),
        );
      }
    } else if (item.spaceInformation?.status == ChatStatus.ACTIVE) {
      if (isHost) {
        return TextButton(
            onPressed: () {},
            child: KText(
              'Active',
              color: Colors.orange,
              size: 18,
              weight: FontWeight.w600,
            ));
      } else {
        return TextButton(
            onPressed: () => onJoin(item.spaceId!),
            child: KText(
              'Join',
              color: Colors.orange,
              size: 18,
              weight: FontWeight.w600,
            ));
      }
    } else if (item.spaceInformation?.status == ChatStatus.ENDED) {
      return TextButton(
          onPressed: () {},
          child: KText(
            'Ended',
            color: Colors.red,
            size: 18,
            weight: FontWeight.w600,
          ));
    } else {
      return SizedBox.shrink();
    }
  }

  onStart(SpaceFeeds item) {
    final localAddress = ref.read(accountProvider).pushWallet?.address;

    if (walletToPCAIP10(localAddress!) != item.spaceInformation?.spaceCreator) {
      showMyDialog(
        context: context,
        title: 'Cannot Start Space',
        message: 'Only Space Creator can start space',
      );
      return;
    }

    if (item.spaceInformation?.status != ChatStatus.PENDING) {
      showMyDialog(
          context: context,
          title: 'Error',
          message:
              'Unable to start the space as it is not in the pending state');
      return;
    }

    showLoadingDialog(context);
    ref
        .read(liveSpaceProvider.notifier)
        .start(
          spaceId: item.spaceId!,
          progressHook: (p0) {},
        )
        .then((value) {
      ref.read(yourSpacesProvider.notifier).onRefresh();
      //Remove loading dialog
      Navigator.pop(context);

      if (value == null) {
        showMyDialog(
            context: context, title: 'Error', message: 'Space not created');

        return;
      }
      pushScreen(LiveSpaceRoom(space: value));
    }).catchError(
      (err) {
        ref.read(yourSpacesProvider.notifier).onRefresh();

        //Remove loading dialog
        Navigator.pop(context);
      },
    );
  }

  onJoin(String spaceId) {
    showLoadingDialog(context);
    ref
        .read(liveSpaceProvider.notifier)
        .join(
          spaceId: spaceId,
        )
        .then((value) {
      Navigator.pop(context);
      if (value == null) {
        showMyDialog(context: context, title: 'Error', message: 'Cannot Join');
      } else {
        pushScreen(LiveSpaceRoom(space: value));
      }
    }).catchError((e) {
      Navigator.pop(context);
    });
  }
}
