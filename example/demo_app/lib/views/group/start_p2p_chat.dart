import 'package:example/__lib.dart';

class StartP2PChatScreen extends StatefulWidget {
  const StartP2PChatScreen({super.key});

  @override
  State<StartP2PChatScreen> createState() => _StartP2PChatScreenState();
}

class _StartP2PChatScreenState extends State<StartP2PChatScreen> {
  TextEditingController addressController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start new chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputField(
              label: 'Recipient Address',
              controller: addressController,
            ),
            SizedBox(height: 16),
            InputField(
              label: 'Message',
              controller: addressController,
            ),
            SizedBox(height: 64),
            MaterialButton(
              color: pushColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onPressed: onSendMessage,
              textColor: Colors.white,
              child: Center(
                  child:
                      isLoading ? CircularProgressIndicator() : Text('Create')),
              padding: EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }

  onSendMessage() async {
    final address = addressController.text.trim();
    final message = messageController.text.trim();

    if (address.isEmpty || message.isEmpty) {
      return;
    }
  }

  bool isLoading = false;
  updateLoading(bool state) {
    setState(() {
      isLoading = state;
    });
  }
}
