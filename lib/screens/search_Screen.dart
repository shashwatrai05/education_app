import 'package:flutter/material.dart';
import 'package:education_app/service/firestore_service.dart';
import 'package:education_app/models/course_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Course> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  // Search listener: Called when the text in the search field changes
  void _onSearchTextChanged() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final results = await FirestoreService().getCoursesBySearch(query);
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Courses'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for courses',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(child: Text('No results found'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final course = _searchResults[index];
                        return ListTile(
                          leading: Image.network(course.imageUrl),
                          title: Text(course.title),
                          subtitle: Text(course.instructor),
                          onTap: () {
                            // Navigate to course details
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
