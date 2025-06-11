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
  Map<String, bool> favoriteStatus = {};

  // Filter variables
  String? selectedState;
  String? selectedType;
  List<String> availableStates = [];
  List<String> availableTypes = [];

  @override
  void initState() {
    super.initState();
    fetchAttractions();
    loadFavoriteStatuses();
  }

  void loadFavoriteStatuses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('favorites');

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
        Set<String> states = {};
        Set<String> types = {};

        if (data != null && data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value != null && value is Map<dynamic, dynamic> && value['hide'] != true) {
              final attractionMap = <String, dynamic>{};
              value.forEach((k, v) {
                attractionMap[k.toString()] = v;
              });
              attractionMap['id'] = key.toString();
              attractionsData.add(attractionMap);

              // Collect unique states and types for filters
              if (attractionMap['state'] != null) {
                states.add(attractionMap['state'].toString());
              }
              if (attractionMap['type'] is List) {
                for (var type in attractionMap['type']) {
                  types.add(type.toString());
                }
              }
            }
          });
        }

        setState(() {
          attractions = attractionsData;
          availableStates = states.toList()..sort();
          availableTypes = types.toList()..sort();
          isLoading = false;
          _applyFilters();
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

  void _applyFilters() {
    List<Map<String, dynamic>> results = attractions;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      results = results.where((attraction) {
        final name = attraction['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Apply state filter
    if (selectedState != null) {
      results = results.where((attraction) {
        return attraction['state']?.toString() == selectedState;
      }).toList();
    }

    // Apply type filter
    if (selectedType != null) {
      results = results.where((attraction) {
        if (attraction['type'] is List) {
          return (attraction['type'] as List).contains(selectedType);
        }
        return false;
      }).toList();
    }
    results.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));

    setState(() {
      filteredAttractions = results;
    });
  }

  double _getLowestPrice(Map<String, dynamic> attraction) {
    List<Map<String, dynamic>> pricing = [];
    if (attraction['pricing'] is List) {
      pricing = (attraction['pricing'] as List).map<Map<String, dynamic>>((item) {
        return Map<String, dynamic>.from(
          (item as Map).map((key, value) => MapEntry(key.toString(), value)),
        );
      }).toList();
    }

    if (pricing.isEmpty) return 0.0;

    double lowest = double.infinity;
    for (var priceItem in pricing) {
      final price = priceItem['price'];
      if (price != null) {
        double priceValue = price is double ? price : double.tryParse(price.toString()) ?? 0.0;
        if (priceValue < lowest) {
          lowest = priceValue;
        }
      }
    }
    return lowest == double.infinity ? 0.0 : lowest;
  }

  String _getMainType(Map<String, dynamic> attraction) {
    if (attraction['type'] is List && (attraction['type'] as List).isNotEmpty) {
      return (attraction['type'] as List).first.toString();
    }
    return 'Attraction';
  }

  void _showAttractionDetails(Map<String, dynamic> attraction) {
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

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: Text(attraction['name'] ?? 'Attraction Details'),
                backgroundColor: Color(0xFF0816A7),
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Images
                      if (images.isNotEmpty)
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              return Container(
                                width: 250,
                                margin: EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
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
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 16),

                      // Location
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
                      SizedBox(height: 16),

                      // Pricing
                      if (pricing.isNotEmpty) ...[
                        Text(
                          'Pricing:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: pricing.map((priceItem) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      priceItem['remark'] ?? 'Unknown',
                                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                                    ),
                                  ),
                                  Text(
                                    'MYR ${priceItem['price']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0816A7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 16),
                      ],

                      // Description
                      Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        attraction['description'] ?? 'No description available',
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

    final userFavoritesRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid)
        .child('favorites')
        .child(attractionId);

    try {
      setState(() {
        favoriteStatus[attractionId] = !(favoriteStatus[attractionId] ?? false);
      });

      final snapshot = await userFavoritesRef.once();
      if (snapshot.snapshot.value != null) {
        await userFavoritesRef.remove();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed from favourites')),
        );
      } else {
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
        title: Text("Attractions List",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF0816A7),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
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
                  onChanged: (value) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: "Search attraction name...",
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),

          // Filter Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // State Filter
                Expanded(
                  child: Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Filter by State', style: TextStyle(fontSize: 12)),
                        value: selectedState,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All States', style: TextStyle(fontSize: 12)),
                          ),
                          ...availableStates.map((state) => DropdownMenuItem<String>(
                            value: state,
                            child: Text(state, style: TextStyle(fontSize: 12)),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedState = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),

                // Type Filter
                Expanded(
                  child: Container(
                    height: 35,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Filter by Type', style: TextStyle(fontSize: 12)),
                        value: selectedType,
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Types', style: TextStyle(fontSize: 12)),
                          ),
                          ...availableTypes.map((type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 12)),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                          });
                          _applyFilters();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Results
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAttractions.isEmpty
                ? Center(child: Text("No attractions found"))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredAttractions.length,
              itemBuilder: (context, index) {
                final attraction = filteredAttractions[index];
                final attractionId = attraction['id'];
                final isFavorite = favoriteStatus[attractionId] ?? false;
                final lowestPrice = _getLowestPrice(attraction);
                final mainType = _getMainType(attraction);

                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attraction['name'] ?? 'Unnamed Attraction',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${attraction['city'] ?? ''}, ${attraction['state'] ?? ''}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                                size: 24,
                              ),
                              onPressed: () => _toggleFavorite(attraction),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mainType,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Spacer(),
                            if (lowestPrice > 0)
                              Text(
                                'From MYR ${lowestPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0816A7),
                                ),
                              )
                            else
                              Text(
                                'Free Entry',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),

                        SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showAttractionDetails(attraction),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0816A7),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text('View Details'),
                          ),
                        ),
                      ],
                    ),
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
            top: BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Favourite()),
                );
              },
              child: Column(
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
              child: Column(
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
              child: Column(
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
              child: Column(
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
              child: Column(
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