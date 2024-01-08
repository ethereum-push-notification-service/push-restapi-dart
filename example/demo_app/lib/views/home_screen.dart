import 'package:blockies/blockies.dart';
import 'package:clipboard/clipboard.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../__lib.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = 0;

  onCopy() {
    final pushWallet = ref.read(accountProvider).pushWallet!;

    FlutterClipboard.copy(pushWallet.address!).then((value) {
      showSuccessSnackbar('Address copied successfully');
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(accountProvider);
    final accounts = vm.accounts;

    Wallet? pushWallet = vm.pushWallet;
    return pushWallet == null
        ? ConnectScreen(accounts: accounts, vm: vm)
        : Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              selectedItemColor: pushColor,
              onTap: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.multitrack_audio_outlined),
                    label: 'Spaces'),
                BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Chat')
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        SvgPicture.asset(
                          AppAssets.ASSETS_PUSHLOGO_SVG,
                          width: 70,
                        ),
                        Expanded(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                ref.read(accountProvider).logOut();
                              },
                              child: Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: onCopy,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            border: Border.all(color: pushColor),
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Blockies(seed: '${pushWallet.address}'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(child: KText(pushWallet.address ?? '')),
                            SizedBox(width: 12),
                            Icon(
                              Icons.copy,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: currentIndex == 0 ? SpacesTab() : ChatsTab(),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

pop([BuildContext? context]) {
  Navigator.pop(context ?? Get.context!);
}

Future pushScreen(Widget screen) async {
  return await Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => screen,
      ));
}

class NavItem {
  final String title;
  final String type;
  final int count;
  final dynamic icon;
  final Function() onPressed;

  NavItem({
    required this.title,
    required this.onPressed,
    this.count = 0,
    this.type = '',
    this.icon,
  });
}

class BlockiesAvatar extends StatelessWidget {
  const BlockiesAvatar(
      {super.key, required this.address, this.size = 60, this.radius = 12});
  final String address;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Blockies(seed: '${address}'),
      ),
    );
  }
}
