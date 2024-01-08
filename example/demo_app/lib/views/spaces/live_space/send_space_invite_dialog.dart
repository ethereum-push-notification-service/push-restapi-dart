import 'package:flutter/cupertino.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../../__lib.dart';

class SendSpaceInviteDialog extends StatefulWidget {
  const SendSpaceInviteDialog(
      {super.key, required this.spaceId, required this.isSpeaker});
  final String spaceId;
  final bool isSpeaker;

  @override
  State<SendSpaceInviteDialog> createState() => _SendSpaceInviteDialogState();
}

class _SendSpaceInviteDialogState extends State<SendSpaceInviteDialog> {
  TextEditingController controller = TextEditingController();
  bool isSpeaker = false;

  onSend() async {
    try {
      final address = controller.text.trim();

      if (!isValidETHAddress(address)) {
        showMyDialog(
            context: context, title: 'Send invite', message: 'Invalid Address');
        return;
      }

      showLoadingDialog();

      if (isSpeaker) {
        await addSpeakers(spaceId: widget.spaceId, speakers: [address]);
      } else {
        await addListeners(spaceId: widget.spaceId, listeners: [address]);
      }

      pop();
      pop();
      showSuccessSnackbar('Invite sent successfully');
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    setState(() {
      isSpeaker = widget.isSpeaker;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
            'Send Space Invite',
            weight: FontWeight.w600,
          ),
          Expanded(
            child: ListView(
              children: [
                SizedBox(height: 24),
                InputField(
                  label: 'Address',
                  hintText: '0xB6E3Dc6b35..............',
                  controller: controller,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    KText(
                      'Listerner',
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    CupertinoSwitch(
                      value: isSpeaker,
                      onChanged: (value) {
                        setState(() {
                          isSpeaker = value;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    KText(
                      'Speaker',
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(height: 24),
                MaterialButton(
                  color: pushColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  onPressed: onSend,
                  textColor: Colors.white,
                  child: Center(child: Text('Send')),
                  padding: EdgeInsets.all(16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
