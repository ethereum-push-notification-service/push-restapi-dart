import 'package:another_flushbar/flushbar.dart';

import '../__lib.dart';

void showErrorSnackbar(
  String message,
) {
  showSnackBar(
    Get.context!,
    'Error',
    message,
  );
}

void showSuccessSnackbar(
  String message,
) {
  showSnackBar(
    Get.context!,
    'Push',
    message,
  );
}

void showSnackBar(
  BuildContext context,
  String? title,
  String? msg, {
  int duration = 3,
  TextAlign align = TextAlign.start,
}) {
  final Flushbar<void> flushBar = Flushbar<void>(
    titleText: title == null
        ? null
        : KText(
            title,
            textAlign: align,
            size: 14,
            color: Colors.white,
            weight: FontWeight.w600,
          ),
    messageText: msg == null
        ? null
        : KText(
            msg,
            textAlign: align,
            size: 14,
            color: Colors.white,
            weight: FontWeight.w400,
          ),
    margin: EdgeInsets.all(6),
    borderRadius: BorderRadius.circular(12),
    flushbarStyle: FlushbarStyle.FLOATING,
    flushbarPosition: FlushbarPosition.TOP,
    duration: Duration(seconds: duration),
    backgroundColor: title == 'Error' ? Colors.red : const Color(0xff28C24E),
  );

  if (!flushBar.isShowing()) {
    flushBar.show(context);
  }
}

class KText extends StatelessWidget {
  final String text;
  final FontWeight? weight;
  final double size;

  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextDecoration? decoration;

  const KText(
    this.text, {
    Key? key,
    this.weight,
    this.size = 14,
    this.color,
    this.textAlign,
    this.maxLines,
    this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      style: TextStyle(
        fontFamily: 'circular',
        fontWeight: weight ?? FontWeight.w400,
        fontSize: size,
        color: color,
        decoration: decoration,
      ),
    );
  }
}
