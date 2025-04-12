import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

@override
void MytripsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return History();
  }));
}

@override
void AttractionsIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Location();
  }));
}

@override
void ProfileIcon(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Profile();
  }));
}

class Favourite extends StatefulWidget {
  @override
  _FavouriteState createState() => _FavouriteState();
}

class _FavouriteState extends State<Favourite> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  void _fetchFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final favoritesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('favorites');

    favoritesRef.onValue.listen((event) async {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map;
        List<Map<String, dynamic>> fetchedFavorites = [];

        // Get full attraction details from the Attractions node
        for (var entry in values.entries) {
          final attractionSnapshot = await FirebaseDatabase.instance
              .ref()
              .child('Attractions')
              .child(entry.key)
              .once();

          if (attractionSnapshot.snapshot.value != null) {
            fetchedFavorites.add({
              'id': entry.key,
              ...Map<String, dynamic>.from(attractionSnapshot.snapshot.value as Map),
            });
          }
        }

        setState(() {
          favorites = fetchedFavorites;
          isLoading = false;
        });
      } else {
        setState(() {
          favorites = [];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print("Error fetching favorites: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void _removeFavorite(String attractionId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('favorites')
          .child(attractionId)
          .remove();

      setState(() {
        favorites.removeWhere((item) => item['id'] == attractionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favourites')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved List"),
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                ),
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : favorites.isEmpty
                ? Center(child: Text("No favourites yet"))
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final attraction = favorites[index];
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
                            Text(
                              attraction['name'] ?? 'Unnamed Attraction',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${attraction['city'] ?? ''}, ${attraction['state'] ?? ''}',
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
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.favorite, color: Colors.red),
                        onPressed: () => _removeFavorite(attraction['id']),
                      ),
                    ],
                  ),
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
                  Icon(Icons.favorite, color: Color(0xFF0816A7)),
                  Text("Saved", style: TextStyle(color: Color(0xFF0816A7))),
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
                  Icon(Icons.park, color: Colors.white),
                  Text("Attractions", style: TextStyle(color: Colors.white)),
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
