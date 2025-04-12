import 'package:flutter/material.dart';
import 'package:localquest/Admin/AttractionEdit.dart';
import 'package:localquest/Admin/AttractionNew.dart';
import 'package:firebase_database/firebase_database.dart';

void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return AttractionNew();
  }));
}

void editAttraction(BuildContext context, Map<String, dynamic> attraction) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return AttractionEdit(attractionData: attraction);
  }));
}

class Manageattractiondata extends StatefulWidget {
  @override
  ManageattractiondataState createState() => ManageattractiondataState();
}

class ManageattractiondataState extends State<Manageattractiondata> {
  final databaseRef = FirebaseDatabase.instance.ref().child('Attractions');
  List<Map<String, dynamic>> attractions = [];
  List<Map<String, dynamic>> filteredAttractions = []; // Added this line
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAttractions();
    searchController.addListener(_filterAttractions);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterAttractions() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredAttractions = attractions.where((attraction) {
        final name = attraction['name']?.toString().toLowerCase() ?? '';
        final address = attraction['address']?.toString().toLowerCase() ?? '';
        final city = attraction['city']?.toString().toLowerCase() ?? '';
        final state = attraction['state']?.toString().toLowerCase() ?? '';
        final types = attraction['type'] is List
            ? (attraction['type'] as List).join(', ').toLowerCase()
            : '';
        final description = attraction['description']?.toString().toLowerCase() ?? '';

        return name.contains(query) ||
            address.contains(query) ||
            city.contains(query) ||
            state.contains(query) ||
            types.contains(query) ||
            description.contains(query);
      }).toList();
    });
  }

  void fetchAttractions() {
    setState(() {
      isLoading = true;
    });

    databaseRef.onValue.listen((event) {
      try {
        final attractionsData = <Map<String, dynamic>>[];
        final data = event.snapshot.value;

        if (data != null && data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value != null && value is Map<dynamic, dynamic>) {
              final attractionMap = <String, dynamic>{};
              value.forEach((k, v) {
                attractionMap[k.toString()] = v;
              });
              attractionMap['id'] = key.toString();
              attractionsData.add(attractionMap);
            }
          });
        }

        setState(() {
          attractions = attractionsData;
          filteredAttractions = attractionsData;
          isLoading = false;
        });
      } catch (e) {
        print("Error processing data: $e");
        setState(() {
          attractions = [];
          filteredAttractions = [];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print("Error fetching attractions: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void toggleHideAttraction(String id, bool isCurrentlyHidden) {
    databaseRef.child(id).update({'hide': !isCurrentlyHidden}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isCurrentlyHidden ? "Attraction unhidden" : "Attraction hidden")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update visibility: $error")),
      );
    });
  }

  void deleteAttraction(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Attraction"),
        content: Text("Are you sure you want to delete this attraction?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              databaseRef.child(id).remove().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Attraction deleted successfully")),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete attraction: $error")),
                );
              });
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Attraction Data"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              AddNew(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search attractions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAttractions.isEmpty
                ? Center(
              child: Text(
                searchController.text.isEmpty
                    ? "No attractions found"
                    : "No results found for '${searchController.text}'",
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemCount: filteredAttractions.length,
              itemBuilder: (context, index) {
                final attraction = filteredAttractions[index];
                final types = attraction['type'] is List
                    ? (attraction['type'] as List).join(', ')
                    : 'No type specified';

                List<Map<String, dynamic>> pricing = [];
                if (attraction['pricing'] is List) {
                  pricing = (attraction['pricing'] as List).map<Map<String, dynamic>>((item) {
                    return Map<String, dynamic>.from(
                      (item as Map).map((key, value) => MapEntry(key.toString(), value)),
                    );
                  }).toList();
                }

                List<String> images = [];
                if (attraction['images'] is List) {
                  images = List<String>.from(attraction['images']);
                }

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty)
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              return Container(
                                width: 200,
                                margin: EdgeInsets.only(right: 8),
                                child: Image.network(
                                  images[imgIndex],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Center(
                                        child: Icon(Icons.image_not_supported, size: 50),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    attraction['name'] ?? 'Unnamed Attraction',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        attraction['hide'] == true ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      tooltip: attraction['hide'] == true ? "Unhide" : "Hide",
                                      onPressed: () => toggleHideAttraction(attraction['id'], attraction['hide'] == true),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        editAttraction(context, attraction);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteAttraction(attraction['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${attraction['address'] ?? ''}, ${attraction['city'] ?? ''}, ${attraction['state'] ?? ''}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Types: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Expanded(
                                  child: Text(types),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (pricing.isNotEmpty) ...[
                              Text(
                                'Pricing:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4),
                              Column(
                                children: pricing.map((priceItem) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            priceItem['remark'] ?? 'Unknown',
                                            style: TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'MYR ${priceItem['price']?.toStringAsFixed(2) ?? '0.00'}',
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 8),
                            ],
                            Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              attraction['description'] ?? 'No description available',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((attraction['description'] ?? '').toString().length > 100)
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(attraction['name'] ?? 'Description'),
                                      content: SingleChildScrollView(
                                        child: Text(attraction['description'] ?? ''),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(ctx).pop(),
                                          child: Text("Close"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Text('Read More'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}