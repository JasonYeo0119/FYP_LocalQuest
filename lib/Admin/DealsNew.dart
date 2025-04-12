import 'package:flutter/material.dart';
import 'package:localquest/Admin/Adminpage.dart';

class Dealsnew extends StatefulWidget {
  @override
  DealsnewState createState() => DealsnewState();
}

class DealsnewState extends State<Dealsnew> {
  final name = TextEditingController();
  final startdate = TextEditingController();
  final enddate = TextEditingController();
  final description = TextEditingController();
  final image = TextEditingController();

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    name.dispose();
    startdate.dispose();
    enddate.dispose();
    description.dispose();
    image.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Deals"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Name", name),
              buildTextField("Start Date", startdate),
              buildTextField("End Date", enddate),
              buildTextField("Description", description, maxLines: 5),
              buildTextField("Insert Image", image),
              SizedBox(height: 20),

              Positioned(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Adminpage()),
                    );
                  },
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