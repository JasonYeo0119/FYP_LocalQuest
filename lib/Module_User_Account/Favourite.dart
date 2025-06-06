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
  List<Map<String, dynamic>> filteredFavorites = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  // Filter variables
  String? selectedState;
  String? selectedType;
  List<String> availableStates = [];
  List<String> availableTypes = [];

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
        Set<String> states = {};
        Set<String> types = {};

        // Get full attraction details from the Attractions node
        for (var entry in values.entries) {
          final attractionSnapshot = await FirebaseDatabase.instance
              .ref()
              .child('Attractions')
              .child(entry.key)
              .once();

          if (attractionSnapshot.snapshot.value != null) {
            final attractionData = {
              'id': entry.key,
              ...Map<String, dynamic>.from(attractionSnapshot.snapshot.value as Map),
            };
            fetchedFavorites.add(attractionData);

            // Collect unique states and types for filters
            if (attractionData['state'] != null) {
              states.add(attractionData['state'].toString());
            }
            if (attractionData['type'] is List) {
              for (var type in attractionData['type']) {
                types.add(type.toString());
              }
            }
          }
        }

        setState(() {
          favorites = fetchedFavorites;
          availableStates = states.toList()..sort();
          availableTypes = types.toList()..sort();
          isLoading = false;
          _applyFilters();
        });
      } else {
        setState(() {
          favorites = [];
          filteredFavorites = [];
          availableStates = [];
          availableTypes = [];
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

  void _applyFilters() {
    List<Map<String, dynamic>> results = favorites;

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
      filteredFavorites = results;
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
                                      style: TextStyle(fontWeight: FontWeight.w500),
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
        _applyFilters(); // Reapply filters after removal
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
        title: Text("Saved List",
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
                    hintText: "Search saved attraction name...",
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
          if (favorites.isNotEmpty)
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
          if (favorites.isNotEmpty) SizedBox(height: 16),

          // Results
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredFavorites.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    favorites.isEmpty ? "No favourites yet" : "No matches found",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (favorites.isEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      "Start exploring attractions and save your favorites!",
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFavorites.length,
              itemBuilder: (context, index) {
                final attraction = filteredFavorites[index];
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
                              icon: Icon(Icons.favorite, color: Colors.red, size: 24),
                              onPressed: () => _removeFavorite(attraction['id']),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFF0816A7).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mainType,
                                style: TextStyle(
                                  color: Color(0xFF0816A7),
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
                                'Price varies',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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