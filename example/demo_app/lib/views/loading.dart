import '../__lib.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({super.key});

  @override
  LoadingDialogState createState() => LoadingDialogState();
}

class LoadingDialogState extends State<LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: SvgPicture.asset(
        AppAssets.ASSETS_LOADING_STATE_SVG,
        height: 76,
        width: 76,
      ),
    );
  }
}

void showLoadingDialog([BuildContext? context]) {
  showDialog(
    context: context ?? Get.context!,
    barrierDismissible: false,
    barrierColor: const Color.fromRGBO(173, 173, 173, 0.23),
    builder: (BuildContext context) {
      return const Center(
        child: LoadingDialog(),
      );
    },
  );
}
