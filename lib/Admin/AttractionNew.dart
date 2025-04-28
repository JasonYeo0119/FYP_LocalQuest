import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:localquest/Admin/Manageattractiondata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AttractionNew extends StatefulWidget {
  @override
  AttractionNewState createState() => AttractionNewState();
}

class AttractionNewState extends State<AttractionNew> {
  final name = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final state = TextEditingController();
  final description = TextEditingController();
  final type = TextEditingController();

  // List to store remarks and prices with non-nullable controllers
  List<Map<String, dynamic>> remarksPrices = [];

  // List to store image files and URLs
  List<Map<String, dynamic>> images = [];
  bool _isUploading = false;

  late DatabaseReference dbRef;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        images.add({
          'file': imageFile,
          'url': null,
          'isUploading': true,
        });
      });

      // Upload immediately after picking
      await _uploadImage(images.length - 1);
    }
  }

  Future<void> _uploadImage(int index) async {
    if (index < 0 || index >= images.length) return;
    if (images[index]['file'] == null) return;

    setState(() {
      images[index]['isUploading'] = true;
    });

    try {
      // Create a unique filename
      String fileName = 'attractions/${DateTime.now().millisecondsSinceEpoch}_${name.text.isEmpty ? 'attraction' : name.text.replaceAll(' ', '_')}_$index.jpg';

      // Create reference to the file location in Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

      // Upload the file
      UploadTask uploadTask = storageRef.putFile(images[index]['file']);

      // Get download URL when upload completes
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        images[index]['url'] = downloadUrl;
        images[index]['isUploading'] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image uploaded successfully")),
      );
    } catch (e) {
      setState(() {
        images[index]['isUploading'] = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image: $e")),
      );
    }
  }

  void _deleteImage(int index) async {
    // If the image has been uploaded to Firebase Storage, delete it there first
    if (images[index]['url'] != null) {
      try {
        // Extract the file path from the URL
        String fileUrl = images[index]['url'];
        // Create a reference to the file in Firebase Storage
        Reference ref = FirebaseStorage.instance.refFromURL(fileUrl);
        // Delete the file
        await ref.delete();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete image from storage: $e")),
        );
      }
    }

    // Remove the image from the local list
    setState(() {
      images.removeAt(index);
    });
  }

  void _replaceImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final newImageFile = File(pickedFile.path);

      // Delete the previous image from Firebase Storage if it exists
      if (images[index]['url'] != null) {
        try {
          Reference ref = FirebaseStorage.instance.refFromURL(images[index]['url']);
          await ref.delete();
        } catch (e) {
          // Just log the error but continue with replacement
          print("Failed to delete previous image: $e");
        }
      }

      setState(() {
        images[index]['file'] = newImageFile;
        images[index]['url'] = null;
        images[index]['isUploading'] = true;
      });

      // Upload the new image
      await _uploadImage(index);
    }
  }

  void _addRemarkPrice() {
    setState(() {
      remarksPrices.add({
        'remark': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void _removeRemarkPrice(int index) {
    if (remarksPrices.length > 1) {
      // Get the controllers to dispose them properly
      final remarkController = remarksPrices[index]['remark'] as TextEditingController?;
      final priceController = remarksPrices[index]['price'] as TextEditingController?;

      // Dispose controllers if they exist
      remarkController?.dispose();
      priceController?.dispose();

      setState(() {
        remarksPrices.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("At least one remark and price is required")),
      );
    }
  }

  void saveAttraction() async {
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

    // Validate that state is selected
    if (selectedState == null || selectedState!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a state")),
      );
      return;
    }

    // Validate that at least one type is selected
    if (selectedtypeofattraction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one attraction type")),
      );
      return;
    }

    // Prepare the pricing data with null safety
    List<Map<String, dynamic>> pricingData = [];
    for (var item in remarksPrices) {
      final remarkController = item['remark'] as TextEditingController;
      final priceController = item['price'] as TextEditingController;

      if (remarkController.text.isNotEmpty && priceController.text.isNotEmpty) {
        pricingData.add({
          'remark': remarkController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
        });
      }
    }

    // Prepare image URLs
    List<String> imageUrls = [];
    for (var image in images) {
      if (image['url'] != null) {
        imageUrls.add(image['url']);
      }
    }

    Map<String, dynamic> attractionData = {
      'name': name.text,
      'address': address.text,
      'city': city.text,
      'state': selectedState,
      'description': description.text,
      'type': selectedtypeofattraction,
      'pricing': pricingData,
      'images': imageUrls,
    };

    dbRef.push().set(attractionData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attraction added successfully!")),
      );
      clearFields();
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Manageattractiondata())
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add attraction: $error")),
      );
    });
  }

  void clearFields() {
    name.clear();
    address.clear();
    city.clear();
    setState(() {
      selectedState = null;
      selectedtypeofattraction = [];

      // Properly dispose existing controllers before clearing
      for (var item in remarksPrices) {
        final remarkController = item['remark'] as TextEditingController?;
        final priceController = item['price'] as TextEditingController?;
        remarkController?.dispose();
        priceController?.dispose();
      }

      // Initialize with new controllers
      remarksPrices = [
        {
          'remark': TextEditingController(),
          'price': TextEditingController(),
        },
        {
          'remark': TextEditingController(),
          'price': TextEditingController(),
        },
      ];

      // Clear images
      images = [];
    });
    description.clear();
    type.clear();
  }

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Attractions');

    // Initialize with default remark/price fields
    remarksPrices = [
      {
        'remark': TextEditingController(),
        'price': TextEditingController(),
      },
      {
        'remark': TextEditingController(),
        'price': TextEditingController(),
      },
    ];
  }

  final List<String> states = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Kuala Lumpur",
    "Labuan",
    "Malacca",
    "Negeri Sembilan",
    "Pahang",
    "Penang",
    "Perak",
    "Perlis",
    "Putrajaya",
    "Sabah",
    "Sarawak",
    "Selangor",
    "Terengganu",
  ];
  String? selectedState;

  final List<String> typeofattraction = [
    "Adventure", "Chill", "Beach", "City", "Jungle", "Outdoor", "Indoor",
    "Good View", "High Temperature", "Low Temperature"
  ];
  List<String> selectedtypeofattraction = [];

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    name.dispose();
    address.dispose();
    city.dispose();
    state.dispose();
    description.dispose();
    type.dispose();

    // Dispose all remark and price controllers
    for (var item in remarksPrices) {
      final remarkController = item['remark'] as TextEditingController?;
      final priceController = item['price'] as TextEditingController?;
      remarkController?.dispose();
      priceController?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Attraction"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Name", name),
              buildTextField("Address", address),
              buildTextField("City", city),

              // State Selection Dropdown
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "State",
                    border: OutlineInputBorder(),
                  ),
                  value: selectedState,
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
              ),

              buildTextField("Description", description, maxLines: 5),

              // Types selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: typeofattraction.map((type) {
                  bool isSelected = selectedtypeofattraction.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedtypeofattraction.add(type);
                        } else {
                          selectedtypeofattraction.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),

              // Dynamic Remarks and Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Remarks and Prices", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: _addRemarkPrice,
                          child: Text("Add More"),
                        ),
                      ],
                    ),
                  ),
                  ...remarksPrices.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var item = entry.value;
                    // Cast controllers with proper null safety
                    final remarkController = item['remark'] as TextEditingController;
                    final priceController = item['price'] as TextEditingController;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: remarkController,
                              decoration: InputDecoration(
                                labelText: "Remark",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Price (MYR)",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeRemarkPrice(idx),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

              // Image upload section
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Attraction Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text("Add Image"),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Display uploaded images
                    images.isEmpty ?
                    Center(child: Text("No images selected")) :
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: images[index]['isUploading'] == true
                                  ? Center(child: CircularProgressIndicator())
                                  : (images[index]['url'] != null
                                  ? Image.network(images[index]['url'], fit: BoxFit.cover)
                                  : Image.file(images[index]['file'], fit: BoxFit.cover)),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.edit, size: 20),
                                      onPressed: () => _replaceImage(index),
                                      padding: EdgeInsets.all(0),
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.delete, size: 20),
                                      onPressed: () => _deleteImage(index),
                                      padding: EdgeInsets.all(0),
                                      constraints: BoxConstraints(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Save button
              GestureDetector(
                onTap: saveAttraction,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Confirm",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable TextField builder
  Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}