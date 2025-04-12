import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:localquest/Model/attraction_model.dart';

class Searchresult extends StatefulWidget {
  final String? initialQuery;

  const Searchresult({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchresultState createState() => _SearchresultState();
}

class _SearchresultState extends State<Searchresult> {
  final TextEditingController _searchController = TextEditingController();
  List<Attraction> _searchResults = [];
  bool _isSearching = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Attractions');

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchAttractions(widget.initialQuery!);
    }
  }

  Future<void> _searchAttractions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final snapshot = await _dbRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final results = data.entries
            .where((entry) =>
        (entry.value['name'] as String?)?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .map((entry) => Attraction.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
            entry.key as String))
            .toList();

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching attractions: $e')),
      );
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
        title: Text("Search Result"),
        backgroundColor: Color(0xFF0816A7),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(17.0),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: 35,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search attractions...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _searchAttractions(_searchController.text),
                      ),
                    ),
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    onSubmitted: (value) => _searchAttractions(value),
                  ),
                ),
              ),
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            if (_searchResults.isNotEmpty)
              ..._searchResults.map((attraction) => _buildAttractionCard(attraction)),
            if (_searchResults.isEmpty && !_isSearching && _searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No attractions found'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractionCard(Attraction attraction) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              attraction.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(attraction.description),
            SizedBox(height: 8),
            Text('${attraction.city}, ${attraction.state}'),
            SizedBox(height: 8),
            Text('Adult Price: RM${attraction.adultPrice.toStringAsFixed(2)}'),
            Text('Child Price: RM${attraction.kidPrice.toStringAsFixed(2)}'),
            SizedBox(height: 8),
            Wrap(
              spacing: 5,
              children: attraction.types
                  .map((type) => Chip(label: Text(type)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}