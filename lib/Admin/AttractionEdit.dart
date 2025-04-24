import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class AttractionEdit extends StatefulWidget {
  final Map<String, dynamic> attractionData;

  const AttractionEdit({Key? key, required this.attractionData}) : super(key: key);

  @override
  _AttractionEditState createState() => _AttractionEditState();
}

class _AttractionEditState extends State<AttractionEdit> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  // State selection
  String? selectedState;

  // Attraction types
  final List<String> allTypes = [
    "Adventure", "Chill", "Beach", "City", "Jungle", "Outdoor", "Indoor",
    "Good View", "High Temperature", "Low Temperature"
  ];
  List<String> selectedtypeofattraction = [];

  // Images
  List<Map<String, dynamic>> images = [];
  final ImagePicker _picker = ImagePicker();

  // Pricing
  List<Map<String, dynamic>> remarksPrices = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _nameController = TextEditingController(text: widget.attractionData['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.attractionData['description'] ?? '');
    _addressController = TextEditingController(text: widget.attractionData['address'] ?? '');
    _cityController = TextEditingController(text: widget.attractionData['city'] ?? '');

    // Set selected state
    selectedState = widget.attractionData['state'];

    // Set selected types
    if (widget.attractionData['type'] is List) {
      selectedtypeofattraction = List<String>.from(widget.attractionData['type']);
    }

    // Load existing images
    if (widget.attractionData['images'] is List) {
      List<String> existingImages = List<String>.from(widget.attractionData['images']);

      for (String url in existingImages) {
        images.add({
          'url': url,
          'isUploading': false,
        });
      }
    }

    // Load existing pricing
    if (widget.attractionData['pricing'] is List) {
      List<dynamic> existingPricing = widget.attractionData['pricing'];

      for (var price in existingPricing) {
        TextEditingController remarkController = TextEditingController();
        TextEditingController priceController = TextEditingController();

        remarkController.text = price['remark'] ?? '';
        priceController.text = (price['price'] ?? '0.0').toString();

        remarksPrices.add({
          'remark': remarkController,
          'price': priceController,
        });
      }
    }

    // If no pricing was loaded, add at least one empty row
    if (remarksPrices.isEmpty) {
      addNewPriceRow();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();

    // Dispose pricing controllers
    for (var item in remarksPrices) {
      (item['remark'] as TextEditingController).dispose();
      (item['price'] as TextEditingController).dispose();
    }

    super.dispose();
  }

  void addNewPriceRow() {
    setState(() {
      remarksPrices.add({
        'remark': TextEditingController(),
        'price': TextEditingController(),
      });
    });
  }

  void removePriceRow(int index) {
    setState(() {
      (remarksPrices[index]['remark'] as TextEditingController).dispose();
      (remarksPrices[index]['price'] as TextEditingController).dispose();
      remarksPrices.removeAt(index);
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
      final storageRef = FirebaseStorage.instance.ref().child('attractions/${DateTime.now().millisecondsSinceEpoch}_$fileName');

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

  void updateAttraction() async {
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
      if (image['url'] != null && image['url'].toString().isNotEmpty) {
        imageUrls.add(image['url']);
      }
    }

    // Create attraction data map
    Map<String, dynamic> attractionData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': selectedState,
      'type': selectedtypeofattraction,
      'pricing': pricingData,
      'images': imageUrls,
    };

    // Preserve the hide status
    if (widget.attractionData.containsKey('hide')) {
      attractionData['hide'] = widget.attractionData['hide'];
    }

    try {
      String attractionId = widget.attractionData['id'];

      await FirebaseDatabase.instance
          .ref()
          .child('Attractions')
          .child(attractionId)
          .update(attractionData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Attraction updated successfully")),
      );

      // Return to previous screen
      Navigator.of(context).pop();
    } catch (e) {
      print("Error updating attraction: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update attraction: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Attraction"),
        actions: [
          TextButton(
            onPressed: updateAttraction,
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
                  labelText: "Attraction Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter attraction name";
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
                items: [
                  "Johor", "Kedah", "Kelantan", "Kuala Lumpur",
                  "Labuan", "Malacca", "Negeri Sembilan", "Pahang",
                  "Penang", "Perak", "Perlis", "Putrajaya",
                  "Sabah", "Sarawak", "Selangor", "Terengganu"
                ].map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedState = newValue;
                  });
                },
              ),
              SizedBox(height: 24),

              // Attraction Types
              Text(
                "Attraction Types",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              // Types selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allTypes.map((type) {
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
              SizedBox(height: 24),

              // Pricing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pricing",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: addNewPriceRow,
                    icon: Icon(Icons.add),
                    label: Text("Add Price"),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Pricing rows
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: remarksPrices.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Remark field
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: remarksPrices[index]['remark'],
                            decoration: InputDecoration(
                              labelText: "Type/Remark",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),

                        // Price field
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: remarksPrices[index]['price'],
                            decoration: InputDecoration(
                              labelText: "Price (MYR)",
                              border: OutlineInputBorder(),
                              prefixText: "MYR ",
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: remarksPrices.length > 1 ? () => removePriceRow(index) : null,
                        ),
                      ],
                    ),
                  );
                },
              ),

              SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateAttraction,
                  child: Text("Update Attraction"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}