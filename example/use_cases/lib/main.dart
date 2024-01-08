import 'package:flutter/material.dart';
import 'package:use_cases/chats/chat.dart';

void main() async {
  runApp(const MainApp());

  log(r'''

          ░█████╗░██╗░░██╗░█████╗░████████╗
          ██╔══██╗██║░░██║██╔══██╗╚══██╔══╝
          ██║░░╚═╝███████║███████║░░░██║░░░
          ██║░░██╗██╔══██║██╔══██║░░░██║░░░
          ╚█████╔╝██║░░██║██║░░██║░░░██║░░░
          ░╚════╝░╚═╝░░╚═╝╚═╝░░╚═╝░░░╚═╝░░░
        ''');

  await runChatClassUseCases();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Push'),
        ),
      ),
    );
  }
}
