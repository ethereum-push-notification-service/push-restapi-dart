import 'dart:convert';
import 'dart:io';

import '../../../__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

class EditGroupInfoScreen extends ConsumerStatefulWidget {
  const EditGroupInfoScreen({super.key});

  @override
  ConsumerState<EditGroupInfoScreen> createState() =>
      _EditGroupInfoScreenState();
}

class _EditGroupInfoScreenState extends ConsumerState<EditGroupInfoScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  GroupInfoDTO? groupInfo;

  PushAPI get pushUser => ref.read(accountProvider).pushUser!;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        groupInfo = ref.read(chatRoomProvider).groupInformation;
        nameController.text = groupInfo!.groupName;
        descriptionController.text = groupInfo!.groupDescription;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Group Info'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        children: [
          SizedBox(height: 64),
          InkWell(
            onTap: () {
              onSelectFile();
            },
            child: (selectedFile != null)
                ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image:
                            DecorationImage(image: FileImage(selectedFile!))),
                  )
                : ProfileImage(
                    imageUrl: groupInfo?.groupImage,
                    size: 100,
                  ),
          ),
          SizedBox(height: 16),
          InputField(
            controller: nameController,
            label: 'Group Name',
          ),
          SizedBox(height: 16),
          InputField(
            controller: descriptionController,
            label: 'Group Description',
          ),
          SizedBox(height: 64),
          MaterialButton(
            color: pushColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: onSubmit,
            textColor: Colors.white,
            child: Text('Save'),
            padding: EdgeInsets.all(16),
          ),
        ],
      ),
    );
  }

  File? _selectedFile;
  File? get selectedFile => _selectedFile;
  Future onSelectFile() async {
    Get.bottomSheet(AttachmentDialog(
      onSelect: (File? file, String type) async {
        pop();
        if (file != null) {
          setState(() {
            _selectedFile = file;
          });
        }
      },
    ));
  }

  String composeImage() {
    final img = base64Encode(selectedFile!.readAsBytesSync());
    return 'data:image/png;base64,$img';
  }

  onSubmit() async {
    try {
      showLoadingDialog();
      await pushUser.chat.group.update(
        chatId: groupInfo!.chatId,
        options: GroupUpdateOptions(
          name: nameController.text.trim(),
          image: selectedFile != null ? composeImage() : groupInfo!.groupImage!,
          description: descriptionController.text.trim(),
        ),
      );

      await ref.read(chatRoomProvider).getLatestGroupInfo();
      pop();
      pop();
    } catch (e) {
      pop();
    }
  }
}
