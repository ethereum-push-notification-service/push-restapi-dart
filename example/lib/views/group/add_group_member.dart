import 'package:push_restapi_dart/push_restapi_dart.dart';

import '../../__lib.dart';

class AddGroupMember extends ConsumerStatefulWidget {
  const AddGroupMember({
    super.key,
    required this.chatId,
    required this.isAdmin,
  });
  final String? chatId;
  final bool isAdmin;

  @override
  ConsumerState<AddGroupMember> createState() => _AddGroupMemberState();
}

class _AddGroupMemberState extends ConsumerState<AddGroupMember> {
  TextEditingController controller = TextEditingController();

  String get type => widget.isAdmin ? 'Admin' : 'Member';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group $type '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 24),
            InputField(
              label: 'Address',
              hintText: '0xB6E3Dc6b35..............',
              controller: controller,
            ),
            SizedBox(height: 24),
            MaterialButton(
              color: pushColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: onAdd,
              textColor: Colors.white,
              child: Center(child: Text('Submit')),
              padding: EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }

  onAdd() async {
    try {
      final address = controller.text.trim();

      if (!isValidETHAddress(address)) {
        showMyDialog(
            context: context,
            title: 'Add new $type',
            message: 'Invalid Address');
        return;
      }
      var result;

      showLoadingDialog();
      if (widget.isAdmin) {
        result = await addAdmins(
          chatId: widget.chatId!,
          admins: [address],
        );
      } else {
        result = await addMembers(
          chatId: widget.chatId!,
          members: [address],
        );
      }
      pop();
      if (result == null) {
        showMyDialog(
          context: context,
          title: 'Add new $type',
          message: 'Failed to add $address to group',
        );
      } else {
        ref.read(chatRoomProvider).getLatestGroupMembers();
        controller.clear();
        setState(() {});
        showMyDialog(
          context: context,
          title: 'Add new $type',
          message: 'Added $address to group successfully',
        );
      }
    } catch (e) {
      pop();
      showMyDialog(
        context: context,
        title: 'Add new $type',
        message: '$e',
      );
    }
  }
}
