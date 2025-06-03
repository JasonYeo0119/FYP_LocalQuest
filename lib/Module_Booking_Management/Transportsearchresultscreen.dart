import 'package:flutter/material.dart';
import '../Model/transport.dart';
import '../widgets/transport_card.dart';

class TransportSearchResultsScreen extends StatelessWidget {
  final List<Transport> transports; // Changed from Map<String, dynamic> to Transport
  final String origin;
  final String destination;
  final DateTime departDate;
  final DateTime? returnDate;
  final String? transportType;

  const TransportSearchResultsScreen({
    Key? key,
    required this.transports,
    required this.origin,
    required this.destination,
    required this.departDate,
    this.returnDate,
    this.transportType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Results'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7107F3), Color(0xFFFF02FA)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$origin → $destination',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  'Depart date: ${departDate.day}/${departDate.month}/${departDate.year}',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                if (returnDate != null)
                  Text(
                    'Return date: ${returnDate!.day}/${returnDate!.month}/${returnDate!.year}',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
              ],
            ),
          ),
          Expanded(
            child: transports.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_transit, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No transports found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search criteria',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: transports.length,
              itemBuilder: (context, index) {
                final transport = transports[index];
                // Convert Transport object to Map<String, dynamic>
                final transportMap = transport.toMap();
                return TransportCard(transport: transportMap);
              },
            ),
          ),
        ],
      ),
    );
  }
}