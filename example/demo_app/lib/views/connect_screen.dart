import 'package:blockies/blockies.dart';

import '../__lib.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({
    super.key,
    required this.accounts,
    required this.vm,
  });

  final List<DemoUser> accounts;
  final AccountProvider vm;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Align(
                      alignment: Alignment.topCenter,
                      child: SvgPicture.asset(AppAssets.ASSETS_PUSHLOGO_SVG)),
                  SizedBox(height: 64),
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final item = accounts[index];
                        return InkWell(
                          onTap: () {
                            vm.connectWallet(item.mnemonic);
                          },
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
                                    child: Blockies(seed: item.address),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: KText(
                                    item.address,
                                    size: 16,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemCount: accounts.length,
                    ),
                  ),
                  /*  Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: List.generate(
                      accounts.length,
                      (index) => InkWell(
                        onTap: () {
                          vm.connectWallet(accounts[index]);
                        },
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_4_rounded,
                                size: 32,
                              ),
                              Text('User ${index + 1}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 32,
                  ),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
