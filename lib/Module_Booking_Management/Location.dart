import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_User_Account/Favourite.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

void SavedIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => Favourite()));
}

void MytripsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => History()));
}

void AttractionsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => Location()));
}

void ProfileIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => Profile()));
}

class Location extends StatefulWidget {
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final databaseRef = FirebaseDatabase.instance.ref().child('Attractions');
  List<Map<String, dynamic>> attractions = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredAttractions = [];
  // Map to track favorite status of attractions
  Map<String, bool> favoriteStatus = {};

  @override
  void initState() {
    super.initState();
    fetchAttractions();
    loadFavoriteStatuses();
  }

  // Load favorite statuses for all attractions
  void loadFavoriteStatuses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('favorites');

    // Listen for changes in favorites
    favoritesRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map;
        setState(() {
          favoriteStatus = {};
          values.forEach((key, value) {
            favoriteStatus[key.toString()] = true;
          });
        });
      } else {
        setState(() {
          favoriteStatus = {};
        });
      }
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
            if (value != null && value is Map<dynamic, dynamic> && value['hide'] != true) {
              // Convert each attraction data to Map<String, dynamic>
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
          isLoading = false;
        });
      } catch (e) {
        print("Error processing data: $e");
        setState(() {
          attractions = [];
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

  void _searchAttractions(String query) {
    final results = attractions.where((attraction) {
      final name = attraction['name']?.toString().toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredAttractions = results;
    });
  }

  void _toggleFavorite(Map<String, dynamic> attraction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please sign in to save favourites')),
      );
      return;
    }

    final attractionId = attraction['id'];

    // Create a reference to the user's favorites
    final userFavoritesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('favorites')
        .child(attractionId);

    try {
      // Optimistically update UI immediately
      setState(() {
        favoriteStatus[attractionId] = !(favoriteStatus[attractionId] ?? false);
      });

      final snapshot = await userFavoritesRef.once();
      if (snapshot.snapshot.value != null) {
        // Already favorited - remove it
        await userFavoritesRef.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from favourites')),
        );
      } else {
        // Add to favorites - store just the attraction ID or the whole object
        await userFavoritesRef.set({
          'id': attraction['id'],
          'name': attraction['name'],
          'image': attraction['image'],
          'timestamp': ServerValue.timestamp,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added to favourites')),
        );
      }
    } catch (e) {
      // Revert the UI change if there was an error
      setState(() {
        favoriteStatus[attractionId] = !(favoriteStatus[attractionId] ?? false);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attractions List"),
        backgroundColor: Color(0xFF0816A7),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchAttractions,
                  decoration: InputDecoration(
                    hintText: "Search",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : attractions.isEmpty
                ? Center(child: Text("No attractions found"))
                : Builder(
              builder: (context) {
                final displayList = _searchController.text.isEmpty ? attractions : filteredAttractions;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final attraction = displayList[index];
                    final attractionId = attraction['id'];
                    final isFavorite = favoriteStatus[attractionId] ?? false;
                    final types = attraction['type'] is List
                        ? (attraction['type'] as List).join(', ')
                        : 'No type specified';

                    // Get pricing information
                    List<Map<String, dynamic>> pricing = [];
                    if (attraction['pricing'] is List) {
                      pricing = (attraction['pricing'] as List).map<Map<String, dynamic>>((item) {
                        return Map<String, dynamic>.from(
                          (item as Map).map((key, value) => MapEntry(key.toString(), value)),
                        );
                      }).toList();
                    }

                    // Get images
                    List<String> images = [];
                    if (attraction['images'] is List) {
                      images = List<String>.from(attraction['images']);
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
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
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _toggleFavorite(attraction),
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
                                // Types
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
                                // Price information
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
                                  // Description (limited to 3 lines)
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
                                        // Show full description dialog
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border(
            top: BorderSide(color: Colors.black, width: 0.5), // Top border
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(  // Wrap in GestureDetector for navigation
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Favourite()),
                );
              },
              child: Column(  //Saved
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, color: Colors.white),
                  Text("Saved", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => History()),
                );
              },
              child: Column(  //Mytrips
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_bag, color: Colors.white),
                  Text("My Trips", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Homepage()),
                );
              },
              child: Column(  //Home
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.white),
                  Text("Home", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Location()),
                );
              },
              child: Column(  //Attraction
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.park, color: Color(0xFF0816A7)),
                  Text("Attractions", style: TextStyle(color: Color(0xFF0816A7))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
              child: Column(  //Profile
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, color: Colors.white),
                  Text("Profile", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}