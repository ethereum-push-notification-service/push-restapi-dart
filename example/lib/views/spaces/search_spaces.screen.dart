import 'package:example/__lib.dart';
import 'package:flutter/material.dart';
import 'package:push_restapi_dart/push_restapi_dart.dart';

class SearchSpacesScreen extends StatefulWidget {
  const SearchSpacesScreen({super.key});

  @override
  State<SearchSpacesScreen> createState() => _SearchSpacesScreenState();
}

class _SearchSpacesScreenState extends State<SearchSpacesScreen> {
  TextEditingController controller = TextEditingController();

  List<SpaceDTO> _spaces = [];

  bool isSearching = false;

  Future _searchSpace() async {
    try {
      final term = controller.text.trim();
      if (term.isEmpty) {
        setState(() {
          _spaces.clear();
          isSearching = false;
        });

        return;
      }
      setState(() {
        isSearching = true;
      });
      final result = await searchSpaces(searchTerm: term);

      setState(() {
        _spaces = result;
        isSearching = false;
      });
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: pop,
                child: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              SearchBar(
                controller: controller,
                hintText: 'enter space name',
                trailing: [
                  IconButton(
                    onPressed: isSearching
                        ? null
                        : () {
                            _searchSpace();
                          },
                    icon: Icon(Icons.search),
                  )
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                  child: isSearching
                      ? Center(child: LoadingDialog())
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 16),
                          itemCount: _spaces.length,
                          itemBuilder: (context, index) {
                            final item = SpaceFeeds(
                                spaceId: _spaces[index].spaceId,
                                spaceInformation: _spaces[index]);
                            return SpaceItemTile(item: item);
                          },
                        ))
            ],
          ),
        ),
      ),
    );
  }
}
