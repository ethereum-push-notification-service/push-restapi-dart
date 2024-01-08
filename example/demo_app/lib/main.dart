import '__lib.dart';

void main() async {
  testPushApi();
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

final pushColor = Color(0xFFD43A94);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primaryColor: pushColor,
        appBarTheme: AppBarTheme(backgroundColor: pushColor),
        tabBarTheme: TabBarTheme(
          labelColor: pushColor,
          indicatorColor: pushColor,
          unselectedLabelColor: pushColor,
          indicator: BoxDecoration(
            border: Border(bottom: BorderSide(color: pushColor, width: 2)),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
