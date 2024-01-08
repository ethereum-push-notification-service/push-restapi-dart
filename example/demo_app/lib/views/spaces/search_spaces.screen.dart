import 'package:flutter/material.dart';

class SearchSpacesScreen extends StatefulWidget {
  const SearchSpacesScreen({super.key});

  @override
  State<SearchSpacesScreen> createState() => _SearchSpacesScreenState();
}

class _SearchSpacesScreenState extends State<SearchSpacesScreen> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [],
          ),
        ),
      ),
    );
  }
}
