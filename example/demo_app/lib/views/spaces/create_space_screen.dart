import 'package:example/__lib.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';
import 'package:unique_names_generator/unique_names_generator.dart';

class CreateSpaceScreen extends ConsumerStatefulWidget {
  const CreateSpaceScreen({super.key});

  @override
  ConsumerState<CreateSpaceScreen> createState() => _CreateSpaceScreenState();
}

class _CreateSpaceScreenState extends ConsumerState<CreateSpaceScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController listenerController = TextEditingController();
  TextEditingController speakerController = TextEditingController();

  List<String> speakers = [];
  List<String> listeners = [];

  bool isLoading = false;
  updateLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }

  DateTime _dateTime = DateTime.now().toUtc().add(Duration(minutes: 5));

  createRandom() async {
    showLoadingDialog(context);
    try {
      final generator = UniqueNamesGenerator(
        config: Config(dictionaries: [names, animals, colors]),
      );
      String spaceName = 'Space ${generator.generate()} '.replaceAll('_', ' ');
      if (spaceName.length > 50) {
        spaceName = spaceName.substring(0, 45);
      }

      final result = await createSpace(
        spaceName: spaceName,
        spaceDescription: "Testing dart for description for $spaceName",
        listeners: [],
        speakers: [],
        isPublic: true,
        scheduleAt: DateTime.now().toUtc().add(
              Duration(minutes: 1),
            ),
      );
      if (result != null) {
        ref.read(yourSpacesProvider).onRefresh();
      }
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Space'),
        actions: [
          TextButton(
              onPressed: createRandom,
              child: KText(
                'Random',
                color: Colors.white,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text('Speakers'),
                  Wrap(
                    children: List.generate(
                      speakers.length,
                      (index) => Chip(label: Text(speakers[index])),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Listeners'),
                  Wrap(
                    children: List.generate(
                      listeners.length,
                      (index) => Chip(label: Text(listeners[index])),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(
                    color: Colors.black,
                  ),
                  SizedBox(height: 16),
                  InputField(
                    controller: nameController,
                    label: 'Space Name',
                  ),
                  SizedBox(height: 16),
                  InputField(
                    controller: descriptionController,
                    label: 'Space Description',
                  ),
                  SizedBox(height: 16),
                  InputField(
                    controller: speakerController,
                    label: 'Add Speaker Address',
                    suffixIcon: IconButton(
                      onPressed: onAddSpeaker,
                      icon: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(height: 16),
                  InputField(
                    controller: listenerController,
                    label: 'Add Member Address',
                    suffixIcon: IconButton(
                      onPressed: onAddMember,
                      icon: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(height: 16),
                  DataView(
                    label: 'Start Time',
                    value: _dateTime.toString(),
                  ),
                ],
              ),
            ),
            MaterialButton(
              color: pushColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: onCreateSpace,
              textColor: Colors.white,
              child: Center(
                  child:
                      isLoading ? CircularProgressIndicator() : Text('Create')),
              padding: EdgeInsets.all(16),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  onCreateSpace() async {
    updateLoading(true);
    final result = await createSpace(
      spaceName: nameController.text.trim(),
      spaceDescription: descriptionController.text.trim(),
      listeners: listeners,
      speakers: speakers,
      scheduleAt: _dateTime,
    );
    if (result == null) {
      showMyDialog(
          context: context, title: 'Error', message: 'Space not created');
    } else {
      ref.read(yourSpacesProvider.notifier).onRefresh();
      showMyDialog(
        context: context,
        title: 'Success',
        message: 'Space created successfully',
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }

    updateLoading(false);
  }

  onAddMember() {
    final address = listenerController.text.trim();
    listeners.add(address);
    listenerController.clear();
    setState(() {});
  }

  onAddSpeaker() {
    final address = speakerController.text.trim();
    speakers.add(address);
    speakerController.clear();
    setState(() {});
  }
}

Future<void> showMyDialog({
  required BuildContext context,
  required String title,
  required String message,
  void Function()? onClose,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: onClose ??
                () {
                  Navigator.of(context).pop();
                },
          ),
        ],
      );
    },
  );
}

class InputField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const InputField({
    super.key,
    this.controller,
    this.hintText,
    this.keyboardType,
    required this.label,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(),
          label: Text(label),
          suffixIcon: suffixIcon),
    );
  }
}
