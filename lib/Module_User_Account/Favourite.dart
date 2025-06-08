import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_Booking_Management/History.dart';
import 'package:localquest/Module_Booking_Management/Location.dart';
import 'package:localquest/Module_User_Account/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localquest/Module_Booking_Management/Attractiondetails.dart';
import 'package:localquest/Module_Booking_Management/Hoteldetails.dart';
import 'package:localquest/Model/attraction_model.dart';
import 'package:localquest/Model/hotel.dart';
import '../services/mock_hotel_service.dart';

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
      print("No user logged in");
      setState(() {
        isLoading = false;
      });
      return;
    }

    print("Current user ID: ${user.uid}");

    final userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(user.uid);

    final favoritesRef = userRef.child('favorites');
    final hotelFavoritesRef = userRef.child('hotel_favorites');

    try {
      List<Map<String, dynamic>> fetchedFavorites = [];
      Set<String> states = {};
      Set<String> types = {};

      // Fetch attraction favorites from Firebase
      print("Fetching attraction favorites...");
      final attractionSnapshot = await favoritesRef.once();
      print("Attraction snapshot exists: ${attractionSnapshot.snapshot.exists}");

      if (attractionSnapshot.snapshot.exists && attractionSnapshot.snapshot.value != null) {
        // Handle both Map and List cases for attractions
        dynamic attractionData = attractionSnapshot.snapshot.value;
        Map<dynamic, dynamic> attractionValues = {};

        if (attractionData is Map) {
          attractionValues = attractionData;
        } else if (attractionData is List) {
          // Convert List to Map with indices as keys
          for (int i = 0; i < attractionData.length; i++) {
            if (attractionData[i] != null) {
              attractionValues[i.toString()] = attractionData[i];
            }
          }
        }

        print("Found ${attractionValues.length} attraction favorites");

        for (var entry in attractionValues.entries) {
          if (entry.value == null) continue;

          final attractionData = await FirebaseDatabase.instance
              .ref()
              .child('Attractions')
              .child(entry.key.toString())
              .once();

          if (attractionData.snapshot.exists && attractionData.snapshot.value != null) {
            final attraction = {
              'id': entry.key.toString(),
              'category': 'attraction',
              ...Map<String, dynamic>.from(attractionData.snapshot.value as Map),
            };
            fetchedFavorites.add(attraction);

            // Collect unique states and types for filters
            if (attraction['state'] != null) {
              states.add(attraction['state'].toString());
            }
            if (attraction['type'] is List) {
              for (var type in attraction['type']) {
                types.add(type.toString());
              }
            }
          }
        }
      }

      // Fetch hotel favorites from Firebase
      print("Fetching hotel favorites...");
      final hotelSnapshot = await hotelFavoritesRef.once();
      print("Hotel snapshot exists: ${hotelSnapshot.snapshot.exists}");

      if (hotelSnapshot.snapshot.exists && hotelSnapshot.snapshot.value != null) {
        // Handle both Map and List cases for hotels
        dynamic hotelData = hotelSnapshot.snapshot.value;
        Map<dynamic, dynamic> hotelValues = {};

        if (hotelData is Map) {
          hotelValues = hotelData;
        } else if (hotelData is List) {
          // Convert List to Map with indices as keys, but preserve the actual data
          for (int i = 0; i < hotelData.length; i++) {
            if (hotelData[i] != null) {
              hotelValues[i.toString()] = hotelData[i];
            }
          }
        } else {
          print("Unexpected hotel data type: ${hotelData.runtimeType}");
          print("Hotel data: $hotelData");
        }

        print("Found ${hotelValues.length} hotel favorites");

        for (var entry in hotelValues.entries) {
          if (entry.value == null) continue;

          String hotelId = entry.key.toString();
          var hotelValue = entry.value;

          Map<String, dynamic>? hotelDataMap;

          // Check if the stored value is a complete hotel object or just an ID/simple value
          if (hotelValue is Map) {
            if (hotelValue.containsKey('name') || hotelValue.containsKey('city')) {
              // Complete hotel object is stored in Firebase
              print("Found complete hotel data in Firebase for hotel $hotelId");
              hotelDataMap = Map<String, dynamic>.from(hotelValue);
            } else {
              // Map but doesn't contain hotel data, might contain metadata
              print("Found partial data, attempting to fetch from service for hotel $hotelId");
              try {
                int id = int.parse(hotelId);
                hotelDataMap = await MockMalaysiaHotelService.getHotelDataById(id);
              } catch (e) {
                print("Error parsing hotel ID $hotelId: $e");
                continue;
              }
            }
          } else {
            // Simple value (might be just true/false or timestamp), fetch from local service
            print("Simple value found, fetching from local service for hotel $hotelId");
            try {
              int id = int.parse(hotelId);
              hotelDataMap = await MockMalaysiaHotelService.getHotelDataById(id);
            } catch (e) {
              print("Error parsing hotel ID $hotelId: $e");
              continue;
            }
          }

          if (hotelDataMap != null && hotelDataMap.isNotEmpty) {
            final hotel = {
              'id': hotelId,
              'category': 'hotel',
              ...hotelDataMap,
            };
            fetchedFavorites.add(hotel);

            // Collect unique states and types for filters
            if (hotel['city'] != null) {
              states.add(hotel['city'].toString());
            }
            if (hotel['country'] != null) {
              states.add(hotel['country'].toString());
            }
            // Add hotel as a type
            types.add('Hotel');

            // Also add the specific hotel type if available
            if (hotel['type'] != null) {
              types.add(hotel['type'].toString());
            }
          } else {
            print("Hotel data not found for ID $hotelId");
          }
        }
      }

      print("Total favorites found: ${fetchedFavorites.length}");

      setState(() {
        favorites = fetchedFavorites;
        availableStates = states.toList()..sort();
        availableTypes = types.toList()..sort();
        isLoading = false;
        _applyFilters();
      });

    } catch (error, stackTrace) {
      print("Error fetching favorites: $error");
      print("Stack trace: $stackTrace");
      setState(() {
        isLoading = false;
      });

      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites. Please try again.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _fetchFavorites();
              },
            ),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> results = favorites;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      results = results.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        return name.contains(_searchController.text.toLowerCase());
      }).toList();
    }

    // Apply state filter
    if (selectedState != null) {
      results = results.where((item) {
        // For attractions, check 'state' field
        if (item['category'] == 'attraction') {
          return item['state']?.toString() == selectedState;
        }
        // For hotels, check 'city' or 'country' fields
        else if (item['category'] == 'hotel') {
          return item['city']?.toString() == selectedState ||
              item['country']?.toString() == selectedState;
        }
        return false;
      }).toList();
    }

    // Apply type filter
    if (selectedType != null) {
      results = results.where((item) {
        // For attractions, check 'type' array
        if (item['category'] == 'attraction') {
          if (item['type'] is List) {
            return (item['type'] as List).contains(selectedType);
          }
        }
        // For hotels, check if selectedType is 'Hotel' or matches the hotel's type
        else if (item['category'] == 'hotel') {
          if (selectedType == 'Hotel') {
            return true;
          }
          if (item['type'] != null) {
            return item['type'].toString() == selectedType;
          }
        }
        return false;
      }).toList();
    }

    // Sort by name
    results.sort((a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo((b['name'] ?? '').toString().toLowerCase()));

    setState(() {
      filteredFavorites = results;
    });
  }

  double _getLowestPrice(Map<String, dynamic> item) {
    // For hotels, check both 'price' field and 'roomTypes' array
    if (item['category'] == 'hotel') {
      double lowestPrice = double.infinity;

      // Check direct price field
      if (item['price'] != null) {
        double price = item['price'] is double ? item['price'] : double.tryParse(item['price'].toString()) ?? 0.0;
        if (price > 0 && price < lowestPrice) {
          lowestPrice = price;
        }
      }

      // Check roomTypes for different pricing
      if (item['roomTypes'] is List) {
        List<dynamic> roomTypes = item['roomTypes'] as List;
        for (var room in roomTypes) {
          if (room is Map && room['price'] != null) {
            double roomPrice = room['price'] is double ? room['price'] : double.tryParse(room['price'].toString()) ?? 0.0;
            if (roomPrice > 0 && roomPrice < lowestPrice) {
              lowestPrice = roomPrice;
            }
          }
        }
      }

      return lowestPrice == double.infinity ? 0.0 : lowestPrice;
    }

    // For attractions, use the existing pricing logic
    List<Map<String, dynamic>> pricing = [];
    if (item['pricing'] is List) {
      pricing = (item['pricing'] as List).map<Map<String, dynamic>>((priceItem) {
        return Map<String, dynamic>.from(
          (priceItem as Map).map((key, value) => MapEntry(key.toString(), value)),
        );
      }).toList();
    }

    if (pricing.isEmpty) return 0.0;

    double lowest = double.infinity;
    for (var priceItem in pricing) {
      final price = priceItem['price'];
      if (price != null) {
        double priceValue = price is double ? price : double.tryParse(price.toString()) ?? 0.0;
        if (priceValue > 0 && priceValue < lowest) {
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

  // Convert Map data to Attraction model
  Attraction _mapToAttraction(Map<String, dynamic> data) {
    List<PricingInfo> pricing = [];
    if (data['pricing'] is List) {
      pricing = (data['pricing'] as List).map<PricingInfo>((item) {
        Map<String, dynamic> priceMap = Map<String, dynamic>.from(item);
        return PricingInfo(
          remark: priceMap['remark'] ?? '',
          price: (priceMap['price'] ?? 0).toDouble(),
        );
      }).toList();
    }

    return Attraction(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      type: data['type'] is List ? List<String>.from(data['type']) : [],
      description: data['description'] ?? '',
      images: data['images'] is List ? List<String>.from(data['images']) : [],
      pricing: pricing,
    );
  }

  // Convert Map data to Hotel model
  Hotel _mapToHotel(Map<String, dynamic> data) {
    print("Converting hotel data: $data");

    List<Map<String, dynamic>>? roomTypes;
    if (data['roomTypes'] is List) {
      roomTypes = (data['roomTypes'] as List).map<Map<String, dynamic>>((room) {
        return Map<String, dynamic>.from(room);
      }).toList();
    }

    // Handle image URL - check multiple possible fields
    String imageUrl = '';
    if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) {
      imageUrl = data['imageUrl'].toString();
    } else if (data['images'] is List && (data['images'] as List).isNotEmpty) {
      imageUrl = (data['images'] as List)[0].toString();
    } else if (data['image'] != null && data['image'].toString().isNotEmpty) {
      imageUrl = data['image'].toString();
    }

    // Handle address - might be stored in different fields or missing
    String address = '';
    if (data['address'] != null && data['address'].toString().isNotEmpty) {
      address = data['address'].toString();
    } else {
      // Build address from city and country if direct address is not available
      List<String> addressParts = [];
      if (data['city'] != null && data['city'].toString().isNotEmpty) {
        addressParts.add(data['city'].toString());
      }
      if (data['country'] != null && data['country'].toString().isNotEmpty) {
        addressParts.add(data['country'].toString());
      }
      address = addressParts.join(', ');
    }

    // Handle rating with better null safety
    double rating = 0.0;
    if (data['rating'] != null) {
      if (data['rating'] is double) {
        rating = data['rating'] as double;
      } else if (data['rating'] is int) {
        rating = (data['rating'] as int).toDouble();
      } else if (data['rating'] is String) {
        rating = double.tryParse(data['rating'] as String) ?? 0.0;
      }
    }

    // Handle price with better null safety
    double? price;
    if (data['price'] != null) {
      if (data['price'] is double) {
        price = data['price'] as double;
      } else if (data['price'] is int) {
        price = (data['price'] as int).toDouble();
      } else if (data['price'] is String) {
        price = double.tryParse(data['price'] as String);
      }
    }

    print("Creating Hotel object with:");
    print("- ID: ${data['id']}");
    print("- Name: ${data['name']}");
    print("- Address: $address");
    print("- City: ${data['city']}");
    print("- Country: ${data['country']}");
    print("- Rating: $rating");
    print("- ImageUrl: $imageUrl");
    print("- Price: $price");

    return Hotel(
      id: int.tryParse(data['id'].toString()) ?? 0,
      name: data['name']?.toString() ?? 'Unknown Hotel',
      address: address,
      city: data['city']?.toString() ?? '',
      country: data['country']?.toString() ?? '',
      rating: rating,
      imageUrl: imageUrl,
      amenities: data['amenities'] is List ? List<String>.from(data['amenities']) : [],
      roomTypes: roomTypes,
      price: price ?? 0.0, // Provide default value for non-nullable double
      currency: data['currency']?.toString() ?? 'MYR',
      type: data['type']?.toString() ?? 'Hotel',
    );
  }

  // Navigate to detail page based on product type
  void _navigateToProductDetails(Map<String, dynamic> product) async {
    final isHotel = product['category'] == 'hotel';

    try {
      if (isHotel) {
        // Fetch complete hotel data with room types and pricing
        int hotelId = int.tryParse(product['id'].toString()) ?? 0;
        Map<String, dynamic>? completeHotelData = await MockMalaysiaHotelService.getHotelDataById(hotelId);

        // Close loading dialog
        Navigator.of(context).pop();

        if (completeHotelData != null && completeHotelData.isNotEmpty) {
          // Add the category and id to the complete data
          completeHotelData['category'] = 'hotel';
          completeHotelData['id'] = product['id'];

          // Create hotel object with complete data
          Hotel hotel = _mapToHotel(completeHotelData);
          print("Hotel object created with complete data: ${hotel.name}");
          print("Room types available: ${hotel.roomTypes?.length ?? 0}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailsScreen(hotel: hotel),
            ),
          );
        } else {
          // Fallback to basic data if service fails
          print("Failed to fetch complete hotel data, using basic data");
          Hotel hotel = _mapToHotel(product);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailsScreen(hotel: hotel),
            ),
          );
        }
      } else {
        // Navigate to attraction details
        Attraction attraction = _mapToAttraction(product);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttractionDetail(attraction: attraction),
          ),
        );
      }
    } catch (error, stackTrace) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print("Error navigating to product details: $error");
      print("Stack trace: $stackTrace");
      print("Product data: $product");

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading product details. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFavorite(String productId, String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Determine which node to remove from based on category
      String nodeName = category == 'hotel' ? 'hotel_favorites' : 'favorites';

      await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child(nodeName)
          .child(productId)
          .remove();

      setState(() {
        favorites.removeWhere((item) => item['id'] == productId);
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
                  final product = filteredFavorites[index];
                  final isHotel = product['category'] == 'hotel';
                  final lowestPrice = _getLowestPrice(product);
                  final mainType = isHotel ? 'Hotel' : _getMainType(product);

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
                                    // Product category badge
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isHotel ? Colors.orange.withOpacity(0.1) : Color(0xFF0816A7).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isHotel ? 'HOTEL' : 'ATTRACTION',
                                        style: TextStyle(
                                          color: isHotel ? Colors.orange : Color(0xFF0816A7),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      product['name'] ?? 'Unnamed Product',
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
                                            isHotel
                                                ? '${product['city'] ?? ''}, ${product['country'] ?? ''}'
                                                : '${product['city'] ?? ''}, ${product['state'] ?? ''}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Show rating for hotels
                                    if (isHotel && product['rating'] != null) ...[
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            '${product['rating']}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.favorite, color: Colors.red, size: 24),
                                onPressed: () => _removeFavorite(product['id'], product['category']),
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
                              onPressed: () => _navigateToProductDetails(product),
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
              )
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