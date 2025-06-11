import 'package:flutter/material.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Admin/HotelNew.dart';
import 'package:localquest/Admin/HotelEdit.dart';
import 'package:firebase_database/firebase_database.dart';

void AddNew(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Hotelnew();
  }));
}

void Home(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Adminpage();
  }));
}

void editHotel(BuildContext context, Map<String, dynamic> hotel) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
    return HotelEdit(hotelData: hotel);
  }));
}

class Managehoteldata extends StatefulWidget {
  @override
  ManagehoteldataState createState() => ManagehoteldataState();
}

class ManagehoteldataState extends State<Managehoteldata> {
  final databaseRef = FirebaseDatabase.instance.ref().child('Hotels');
  List<Map<String, dynamic>> hotels = [];
  List<Map<String, dynamic>> filteredHotels = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  bool showAllAmenities = false;
  int maxVisibleAmenities = 5;

  @override
  void initState() {
    super.initState();
    fetchHotels();
    searchController.addListener(_filterHotels);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterHotels() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredHotels = hotels.where((hotel) {
        final name = hotel['name']?.toString().toLowerCase() ?? '';
        final address = hotel['address']?.toString().toLowerCase() ?? '';
        final city = hotel['city']?.toString().toLowerCase() ?? '';
        final state = hotel['state']?.toString().toLowerCase() ?? '';
        final type = hotel['type']?.toString().toLowerCase() ?? '';
        final room = hotel['room']?.toString().toLowerCase() ?? '';
        final description = hotel['description']?.toString().toLowerCase() ?? '';
        final amenities = hotel['amenities'] is List
            ? (hotel['amenities'] as List).join(', ').toLowerCase()
            : '';

        return name.contains(query) ||
            address.contains(query) ||
            city.contains(query) ||
            state.contains(query) ||
            type.contains(query) ||
            room.contains(query) ||
            description.contains(query) ||
            amenities.contains(query);
      }).toList();
    });
  }

  void fetchHotels() {
    setState(() {
      isLoading = true;
    });

    databaseRef.onValue.listen((event) {
      try {
        final hotelsData = <Map<String, dynamic>>[];
        final data = event.snapshot.value;

        if (data != null && data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value != null && value is Map<dynamic, dynamic>) {
              final hotelMap = <String, dynamic>{};
              value.forEach((k, v) {
                hotelMap[k.toString()] = v;
              });
              hotelMap['id'] = key.toString();
              hotelsData.add(hotelMap);
            }
          });
        }

        setState(() {
          hotels = hotelsData;
          filteredHotels = hotelsData;
          isLoading = false;
        });
      } catch (e) {
        print("Error processing data: $e");
        setState(() {
          hotels = [];
          filteredHotels = [];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print("Error fetching hotels: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void toggleHideHotel(String id, bool isCurrentlyHidden) {
    databaseRef.child(id).update({'hide': !isCurrentlyHidden}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isCurrentlyHidden ? "Hotel unhidden" : "Hotel hidden")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update visibility: $error")),
      );
    });
  }

  void deleteHotel(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Hotel"),
        content: Text("Are you sure you want to delete this hotel?"),
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
                  SnackBar(content: Text("Hotel deleted successfully")),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete hotel: $error")),
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
        title: Text("Hotel Data",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.home_filled),
            onPressed: () {
              Home(context);
            },
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search hotels...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Total items: ${filteredHotels.length}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredHotels.isEmpty
                ? Center(
              child: Text(
                searchController.text.isEmpty
                    ? "No hotels found"
                    : "No results found for '${searchController.text}'",
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemCount: filteredHotels.length,
              itemBuilder: (context, index) {
                final hotel = filteredHotels[index];

                List<String> images = [];
                if (hotel['images'] is List) {
                  images = List<String>.from(hotel['images']);
                }

                List<String> amenities = [];
                if (hotel['amenities'] is List) {
                  amenities = List<String>.from(hotel['amenities']);
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
                                    hotel['name'] ?? 'Unnamed Hotel',
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
                                        hotel['hide'] == true ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      tooltip: hotel['hide'] == true ? "Unhide" : "Hide",
                                      onPressed: () => toggleHideHotel(hotel['id'], hotel['hide'] == true),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        editHotel(context, hotel);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteHotel(hotel['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${hotel['city'] ?? ''}, ${hotel['state'] ?? ''}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.hotel, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  hotel['type'] ?? 'Unknown Type'
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'MYR ${hotel['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),

                            if (amenities.isNotEmpty) ...[
                              Text(
                                'Amenities:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: (hotel['showAllAmenities'] == true
                                    ? amenities
                                    : amenities.take(maxVisibleAmenities).toList())
                                    .map((amenity) => Text(amenity))
                                    .toList(),
                              ),
                              if (amenities.length > maxVisibleAmenities && hotel['showAllAmenities'] != true)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      hotel['showAllAmenities'] = true;
                                    });
                                  },
                                  child: Text('See All Amenities'),
                                ),
                              SizedBox(height: 6),
                            ],


                            Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              hotel['description'] ?? 'No description available',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if ((hotel['description'] ?? '').toString().length > 100)
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(hotel['name'] ?? 'Description'),
                                      content: SingleChildScrollView(
                                        child: Text(hotel['description'] ?? ''),
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