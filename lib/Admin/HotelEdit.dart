import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class HotelEdit extends StatefulWidget {
  final Map<String, dynamic> hotelData;

  const HotelEdit({Key? key, required this.hotelData}) : super(key: key);

  @override
  _HotelEditState createState() => _HotelEditState();
}

class _HotelEditState extends State<HotelEdit> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _priceController;

  // Dropdown selections
  String? selectedState;
  String? selectedType;

  // Lists for dropdowns
  final List<String> states = [
    "Johor", "Kedah", "Kelantan", "Kuala Lumpur", "Labuan",
    "Malacca", "Negeri Sembilan", "Pahang", "Penang", "Perak",
    "Perlis", "Putrajaya", "Sabah", "Sarawak", "Selangor", "Terengganu"
  ];

  final List<String> types = [
    "Luxury Hotel", "Mid-range Hotel", "Budget Hotel", "Apartment", "Villa", "Suites"
  ];

  final List<String> rooms = [
    "Single Room", "Double Room", "Triple Room", "Quad room",
    "Family Room (6 pax)", "Apartment", "Suites", "Villa", "Other"
  ];

  // Amenities
  final List<String> amenitiesList = [
    "Gym", "Wifi", "Pool", "Air-Conditioner", "Heater", "Kitchen Equipments",
    "Private Bathroom", "Bathtub", "Breakfast", "Washer", "Dryer", "Free Parking",
    "TV", "Lift", "Non-smoking Room", "Jacuzzi", "View"
  ];
  List<String> selectedAmenities = [];

  // Images
  List<Map<String, dynamic>> images = [];
  final ImagePicker _picker = ImagePicker();

  // Room details
  List<Map<String, dynamic>> roomDetails = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.hotelData['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.hotelData['description'] ?? '');
    _addressController = TextEditingController(text: widget.hotelData['address'] ?? '');
    _cityController = TextEditingController(text: widget.hotelData['city'] ?? '');
    _priceController = TextEditingController(text: (widget.hotelData['price'] ?? 0.0).toString());

    // Set selected dropdown values
    selectedState = widget.hotelData['state'];
    selectedType = widget.hotelData['type'];

    // Set selected amenities
    if (widget.hotelData['amenities'] is List) {
      selectedAmenities = List<String>.from(widget.hotelData['amenities']);
    }

    // Load existing images
    if (widget.hotelData['images'] is List) {
      List<String> existingImages = List<String>.from(widget.hotelData['images']);

      for (String url in existingImages) {
        images.add({
          'url': url,
          'isUploading': false,
        });
      }
    }

    // Load existing room details
    if (widget.hotelData['rooms'] is List) {
      List<dynamic> existingRooms = widget.hotelData['rooms'];

      for (var room in existingRooms) {
        TextEditingController priceController = TextEditingController();
        TextEditingController quantityController = TextEditingController();

        priceController.text = (room['price'] ?? '').toString();
        quantityController.text = (room['quantity'] ?? '').toString();

        roomDetails.add({
          'roomType': room['roomType'],
          'price': priceController,
          'pax': room['pax'],
          'quantity': quantityController,
        });
      }
    }

    // If no room details were loaded, add at least one empty row
    if (roomDetails.isEmpty) {
      addNewRoomRow();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _priceController.dispose();

    // Dispose room details controllers
    for (var item in roomDetails) {
      (item['price'] as TextEditingController).dispose();
      (item['quantity'] as TextEditingController).dispose();
    }

    super.dispose();
  }

  void addNewRoomRow() {
    setState(() {
      roomDetails.add({
        'roomType': null,
        'price': TextEditingController(),
        'pax': null,
        'quantity': TextEditingController(),
      });
    });
  }

  void removeRoomRow(int index) {
    setState(() {
      (roomDetails[index]['price'] as TextEditingController).dispose();
      (roomDetails[index]['quantity'] as TextEditingController).dispose();
      roomDetails.removeAt(index);
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        images.add({
          'file': pickedFile,
          'url': null,
          'isUploading': true,
        });
      });

      await _uploadImage(pickedFile, images.length - 1);
    }
  }

  Future<void> _uploadImage(XFile imageFile, int index) async {
    try {
      final String fileName = path.basename(imageFile.path);
      final File file = File(imageFile.path);

      // Create a reference to the location where you want to upload the file
      final storageRef = FirebaseStorage.instance.ref().child('hotels/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      // Upload file
      final uploadTask = storageRef.putFile(file);

      // Get download URL after upload completes
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        images[index]['url'] = downloadUrl;
        images[index]['isUploading'] = false;
      });
    } catch (e) {
      print('Error uploading image: $e');
      setState(() {
        images[index]['isUploading'] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  void updateHotel() async {
    // Check if any image is still uploading
    bool uploading = false;
    for (var image in images) {
      if (image['isUploading'] == true) {
        uploading = true;
        break;
      }
    }

    if (uploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please wait for all images to upload")),
      );
      return;
    }

    // Validate required fields
    if (selectedState == null || selectedState!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a state")),
      );
      return;
    }

    if (selectedType == null || selectedType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a hotel type")),
      );
      return;
    }

    // Prepare image URLs
    List<String> imageUrls = [];
    for (var image in images) {
      if (image['url'] != null && image['url'].toString().isNotEmpty) {
        imageUrls.add(image['url']);
      }
    }

    // Prepare the room details data
    List<Map<String, dynamic>> roomsData = [];
    for (var item in roomDetails) {
      final priceController = item['price'] as TextEditingController;
      final quantityController = item['quantity'] as TextEditingController;
      final roomType = item['roomType'];
      final pax = item['pax'];

      if (roomType != null && priceController.text.isNotEmpty && pax != null && quantityController.text.isNotEmpty) {
        roomsData.add({
          'roomType': roomType,
          'price': priceController.text,
          'pax': pax,
          'quantity': quantityController.text,
        });
      }
    }

    // Create hotel data map
    Map<String, dynamic> hotelData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': selectedState,
      'type': selectedType,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'amenities': selectedAmenities,
      'images': imageUrls,
      'rooms': roomsData,
    };

    // Preserve the hide status
    if (widget.hotelData.containsKey('hide')) {
      hotelData['hide'] = widget.hotelData['hide'];
    }

    try {
      String hotelId = widget.hotelData['id'];

      await FirebaseDatabase.instance
          .ref()
          .child('Hotels')
          .child(hotelId)
          .update(hotelData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hotel updated successfully")),
      );

      // Return to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      print("Error updating hotel: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update hotel: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Hotel"),
        actions: [
          TextButton(
            onPressed: updateHotel,
            child: Text(
              "Save",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              Text(
                "Basic Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Hotel Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter hotel name";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter description";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Location
              Text(
                "Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // City
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: "City",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter city";
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // State dropdown
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: InputDecoration(
                  labelText: "State",
                  border: OutlineInputBorder(),
                ),
                items: states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedState = newValue;
                  });
                },
              ),
              SizedBox(height: 24),

              // Hotel Type
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: "Hotel Type",
                  border: OutlineInputBorder(),
                ),
                items: types.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue;
                  });
                },
              ),
              SizedBox(height: 16),

              // Starting Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Starting Price (MYR)",
                  border: OutlineInputBorder(),
                  prefixText: "MYR ",
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter price";
                  }
                  if (double.tryParse(value) == null) {
                    return "Please enter a valid number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Room Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Room Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: addNewRoomRow,
                    icon: Icon(Icons.add),
                    label: Text("Add Room"),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Room Details rows
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: roomDetails.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Room ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: roomDetails.length > 1 ? () => removeRoomRow(index) : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: roomDetails[index]['roomType'],
                            decoration: InputDecoration(
                              labelText: "Room Type",
                              border: OutlineInputBorder(),
                            ),
                            items: rooms.map((String room) {
                              return DropdownMenuItem<String>(
                                value: room,
                                child: Text(room),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                roomDetails[index]['roomType'] = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: roomDetails[index]['price'],
                            decoration: InputDecoration(
                              labelText: "Price (MYR)",
                              border: OutlineInputBorder(),
                              prefixText: "MYR ",
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: roomDetails[index]['pax'],
                            decoration: InputDecoration(
                              labelText: "Number of Pax",
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(10, (i) => i + 1).map((int pax) {
                              return DropdownMenuItem<int>(
                                value: pax,
                                child: Text(pax.toString()),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                roomDetails[index]['pax'] = newValue;
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: roomDetails[index]['quantity'],
                            decoration: InputDecoration(
                              labelText: "Quantity",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 24),

              // Amenities selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenitiesList.map((type) {
                  bool isSelected = selectedAmenities.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAmenities.add(type);
                        } else {
                          selectedAmenities.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // Images
              Text(
                "Images",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Image gallery
              Container(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Image button
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 40),
                            SizedBox(height: 8),
                            Text("Add Image"),
                          ],
                        ),
                      ),
                    ),

                    // Show existing images
                    ...images.asMap().entries.map((entry) {
                      int index = entry.key;
                      var image = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 120,
                            margin: EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: image['isUploading'] == true
                                ? Center(child: CircularProgressIndicator())
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                image['url'],
                                fit: BoxFit.cover,
                                width: 120,
                                height: 150,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 13,
                            child: InkWell(
                              onTap: () => removeImage(index),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateHotel,
                  child: Text("Update Hotel"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}