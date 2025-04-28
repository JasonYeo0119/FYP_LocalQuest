import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localquest/Admin/Managehoteldata.dart';

class Hotelnew extends StatefulWidget {
  @override
  HotelnewState createState() => HotelnewState();
}

class HotelnewState extends State<Hotelnew> {
  final name = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final description = TextEditingController();
  final price = TextEditingController();

  final List<String> states = [
    "Johor", "Kedah", "Kelantan", "Kuala Lumpur", "Labuan",
    "Malacca", "Negeri Sembilan", "Pahang", "Penang", "Perak",
    "Perlis", "Putrajaya", "Sabah", "Sarawak", "Selangor", "Terengganu"
  ];
  String? selectedState;

  final List<String> types = [
    "Luxury Hotel", "Mid-range Hotel", "Budget Hotel", "Apartment", "Villa", "Suites"
  ];
  String? selectedType;

  final List<String> rooms = [
    "Single Room", "Double Room", "Triple Room", "Quad room",
    "Family Room (6 pax)", "Apartment", "Suites", "Villa", "Other"
  ];

  final List<String> amenitiesList = [
    "Gym", "Wifi", "Pool", "Air-Conditioner", "Heater", "Kitchen Equipments",
    "Private Bathroom", "Bathtub", "Breakfast", "Washer", "Dryer", "Free Parking",
    "TV", "Lift", "Non-smoking Room", "Jacuzzi", "View"
  ];
  List<String> selectedAmenities = [];

  List<Map<String, dynamic>> images = [];
  bool _isUploading = false;

  List<Map<String, dynamic>> roomDetails = [
    {'roomType': null, 'price': '', 'pax': null, 'quantity': ''},
    {'roomType': null, 'price': '', 'pax': null, 'quantity': ''},
  ];

  late DatabaseReference dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Hotels');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      setState(() {
        images.add({'file': imageFile, 'url': null, 'isUploading': true});
      });

      await _uploadImage(images.length - 1);
    }
  }

  Future<void> _uploadImage(int index) async {
    if (index < 0 || index >= images.length) return;
    if (images[index]['file'] == null) return;

    try {
      String fileName = 'hotels/${DateTime.now().millisecondsSinceEpoch}_${name.text.isEmpty ? 'hotel' : name.text.replaceAll(' ', '_')}_$index.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(images[index]['file']);
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

  void saveHotel() async {
    bool uploading = images.any((image) => image['isUploading'] == true);
    if (uploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please wait for all images to upload")),
      );
      return;
    }

    if (selectedState == null || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please complete all dropdown selections")),
      );
      return;
    }

    List<String> imageUrls = images.where((img) => img['url'] != null).map((img) => img['url'] as String).toList();

    Map<String, dynamic> hotelData = {
      'name': name.text,
      'address': address.text,
      'city': city.text,
      'state': selectedState,
      'description': description.text,
      'type': selectedType,
      'price': double.tryParse(price.text) ?? 0.0,
      'amenities': selectedAmenities,
      'images': imageUrls,
      'rooms': roomDetails,
    };

    dbRef.push().set(hotelData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hotel added successfully!")),
      );
      clearFields();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Managehoteldata()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add hotel: $error")),
      );
    });
  }

  void clearFields() {
    name.clear();
    address.clear();
    city.clear();
    description.clear();
    price.clear();
    selectedState = null;
    selectedType = null;
    selectedAmenities = [];
    images = [];
    roomDetails = [
      {'roomType': null, 'price': '', 'pax': null, 'quantity': ''},
      {'roomType': null, 'price': '', 'pax': null, 'quantity': ''},
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create New Hotel")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Name", name),
              buildTextField("Address", address),
              buildTextField("City", city),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "State", border: OutlineInputBorder()),
                value: selectedState,
                items: states.map((String state) => DropdownMenuItem<String>(value: state, child: Text(state))).toList(),
                onChanged: (value) => setState(() => selectedState = value),
              ),
              SizedBox(height: 8),
              buildTextField("Description", description, maxLines: 5),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Type", border: OutlineInputBorder()),
                value: selectedType,
                items: types.map((String type) => DropdownMenuItem<String>(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => selectedType = value),
              ),
              SizedBox(height: 8),
              buildTextField("Starting Price (MYR)", price, isNumber: true),

              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Room Details", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () => setState(() => roomDetails.add({'roomType': null, 'price': '', 'pax': null, 'quantity': ''})),
                    child: Text("Add Room"),
                  ),
                ],
              ),
              ...List.generate(roomDetails.length, (index) => buildRoomEntry(index)),

              SizedBox(height: 8),
              // Amenities selection
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenitiesList.map((amenity) {
                  bool isSelected = selectedAmenities.contains(amenity);
                  return FilterChip(
                    label: Text(amenity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedAmenities.add(amenity);
                        } else {
                          selectedAmenities.remove(amenity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Hotel Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ElevatedButton(onPressed: _pickImage, child: Text("Add Image")),
                ],
              ),
              SizedBox(height: 16),
              images.isEmpty
                  ? Center(child: Text("No images selected"))
                  : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1),
                itemCount: images.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                      child: images[index]['isUploading'] == true
                          ? Center(child: CircularProgressIndicator())
                          : images[index]['url'] != null
                          ? Image.network(images[index]['url'], fit: BoxFit.cover)
                          : Image.file(images[index]['file'], fit: BoxFit.cover),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              GestureDetector(
                onTap: saveHotel,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Text("Confirm", style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoomEntry(int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Remark (Room Type)"),
              value: roomDetails[index]['roomType'],
              items: rooms.map((String room) => DropdownMenuItem<String>(value: room, child: Text(room))).toList(),
              onChanged: (value) => setState(() => roomDetails[index]['roomType'] = value),
            ),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Price (MYR)"),
              onChanged: (value) => roomDetails[index]['price'] = value,
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: "Number of Pax"),
              value: roomDetails[index]['pax'],
              items: List.generate(10, (i) => i + 1).map((int pax) => DropdownMenuItem<int>(value: pax, child: Text(pax.toString()))).toList(),
              onChanged: (value) => setState(() => roomDetails[index]['pax'] = value),
            ),
            SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Quantity"),
              onChanged: (value) => roomDetails[index]['quantity'] = value,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => setState(() => roomDetails.removeAt(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }
}
