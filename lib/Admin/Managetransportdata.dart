import 'package:flutter/material.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Admin/TransportNew.dart';
import 'package:firebase_database/firebase_database.dart';

void AddNewTransport(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Transportnew();
  }));
}

void Home(BuildContext ctx) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
    return Adminpage();
  }));
}

void editTransport(BuildContext context, Map<String, dynamic> transport) {
  // Navigator.of(context).push(MaterialPageRoute(builder: (_) {
  //   return TransportEdit(transportData: transport);
  // }));
  // TODO: Create TransportEdit page similar to HotelEdit
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Edit functionality to be implemented")),
  );
}

class ManageTransportData extends StatefulWidget {
  @override
  ManageTransportDataState createState() => ManageTransportDataState();
}

class ManageTransportDataState extends State<ManageTransportData> {
  final databaseRef = FirebaseDatabase.instance.ref().child('Transports');
  List<Map<String, dynamic>> transports = [];
  List<Map<String, dynamic>> filteredTransports = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTransports();
    searchController.addListener(_filterTransports);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterTransports() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredTransports = transports.where((transport) {
        final name = transport['name']?.toString().toLowerCase() ?? '';
        final type = transport['type']?.toString().toLowerCase() ?? '';
        final origin = transport['origin']?.toString().toLowerCase() ?? '';
        final destination = transport['destination']?.toString().toLowerCase() ?? '';
        final operatingDays = transport['operatingDays'] is List
            ? (transport['operatingDays'] as List).join(', ').toLowerCase()
            : '';
        final timeSlots = transport['timeSlots'] is List
            ? (transport['timeSlots'] as List).join(', ').toLowerCase()
            : '';

        return name.contains(query) ||
            type.contains(query) ||
            origin.contains(query) ||
            destination.contains(query) ||
            operatingDays.contains(query) ||
            timeSlots.contains(query);
      }).toList();
    });
  }

  void fetchTransports() {
    setState(() {
      isLoading = true;
    });

    databaseRef.onValue.listen((event) {
      try {
        final transportsData = <Map<String, dynamic>>[];
        final data = event.snapshot.value;

        if (data != null && data is Map<dynamic, dynamic>) {
          data.forEach((key, value) {
            if (value != null && value is Map<dynamic, dynamic>) {
              final transportMap = <String, dynamic>{};
              value.forEach((k, v) {
                transportMap[k.toString()] = v;
              });
              transportMap['id'] = key.toString();
              transportsData.add(transportMap);
            }
          });
        }

        setState(() {
          transports = transportsData;
          filteredTransports = transportsData;
          isLoading = false;
        });
      } catch (e) {
        print("Error processing data: $e");
        setState(() {
          transports = [];
          filteredTransports = [];
          isLoading = false;
        });
      }
    }, onError: (error) {
      print("Error fetching transports: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  void toggleHideTransport(String id, bool isCurrentlyHidden) {
    databaseRef.child(id).update({'hide': !isCurrentlyHidden}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isCurrentlyHidden ? "Transport unhidden" : "Transport hidden")),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update visibility: $error")),
      );
    });
  }

  void deleteTransport(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Transport"),
        content: Text("Are you sure you want to delete this transport?"),
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
                  SnackBar(content: Text("Transport deleted successfully")),
                );
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete transport: $error")),
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
        title: Text("Transport Data",
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
              AddNewTransport(context);
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
                    hintText: 'Search transports...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Total items: ${filteredTransports.length}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredTransports.isEmpty
                ? Center(
              child: Text(
                searchController.text.isEmpty
                    ? "No transports found"
                    : "No results found for '${searchController.text}'",
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
              itemCount: filteredTransports.length,
              itemBuilder: (context, index) {
                final transport = filteredTransports[index];

                List<String> operatingDays = [];
                if (transport['operatingDays'] is List) {
                  operatingDays = List<String>.from(transport['operatingDays']);
                }

                List<String> timeSlots = [];
                if (transport['timeSlots'] is List) {
                  timeSlots = List<String>.from(transport['timeSlots']);
                }

                List<int> availableSeats = [];
                if (transport['availableSeats'] is List) {
                  availableSeats = List<int>.from(transport['availableSeats']);
                }

                return Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transport Image
                      if (transport['imageUrl'] != null && transport['imageUrl'].toString().isNotEmpty)
                        Container(
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            transport['imageUrl'],
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
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          transport['name'] ?? 'Unnamed Transport',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        transport['hide'] == true ? Icons.visibility : Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                      tooltip: transport['hide'] == true ? "Unhide" : "Hide",
                                      onPressed: () => toggleHideTransport(transport['id'], transport['hide'] == true),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        editTransport(context, transport);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteTransport(transport['id']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Transport Type
                            Row(
                              children: [
                                Icon(Icons.directions_transit, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  transport['type'] ?? 'Unknown Type',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Route Information
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.green),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${transport['origin'] ?? 'Unknown'} → ${transport['destination'] ?? 'Unknown'}',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Price
                            Row(
                              children: [
                                Icon(Icons.attach_money, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'MYR ${transport['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),

                            // Bus-specific information
                            if (transport['type'] == 'Bus') ...[
                              SizedBox(height: 12),
                              Divider(),
                              SizedBox(height: 8),

                              // Operating Days
                              if (operatingDays.isNotEmpty) ...[
                                Text(
                                  'Operating Days:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: operatingDays.map((day) => Chip(
                                    label: Text(day, style: TextStyle(fontSize: 12, color: Colors.black)),
                                    backgroundColor: Colors.white,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                                SizedBox(height: 8),
                              ],

                              // Time Slots
                              if (timeSlots.isNotEmpty) ...[
                                Text(
                                  'Available Times:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  children: timeSlots.map((time) => Chip(
                                    label: Text(time, style: TextStyle(fontSize: 12, color: Colors.black)),
                                    backgroundColor: Colors.white,
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                                SizedBox(height: 8),
                              ],

                              // Seat Information
                              if (availableSeats.isNotEmpty) ...[
                                Row(
                                  children: [
                                    Icon(Icons.event_seat, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      'Available Seats: ${availableSeats.length}/${transport['totalSeats'] ?? 33}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Seats: ${availableSeats.take(10).join(', ')}${availableSeats.length > 10 ? '...' : ''}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ],
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