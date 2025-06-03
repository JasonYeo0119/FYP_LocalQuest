import 'package:firebase_database/firebase_database.dart';
import '../Model/transport.dart';

class TransportService {
  static final DatabaseReference _database =
  FirebaseDatabase.instance.ref().child('Transports');

  // Fetch all transports from Firebase
  static Future<List<Transport>> getAllTransports() async {
    try {
      final snapshot = await _database.once();
      final data = snapshot.snapshot.value;

      if (data == null || data is! Map<dynamic, dynamic>) {
        return [];
      }

      List<Transport> transports = [];
      data.forEach((key, value) {
        if (value != null && value is Map<dynamic, dynamic>) {
          final transportData = <String, dynamic>{};
          value.forEach((k, v) {
            transportData[k.toString()] = v;
          });

          final transport = Transport.fromMap(key.toString(), transportData);
          transports.add(transport);
        }
      });

      return transports;
    } catch (e) {
      print('Error fetching transports: $e');
      return [];
    }
  }

  // Search transports based on criteria
  static Future<List<Transport>> searchTransports({
    String? origin,
    String? destination,
    String? type,
    bool includeHidden = false,
  }) async {
    try {
      final allTransports = await getAllTransports();

      return allTransports.where((transport) {
        // Filter out hidden transports unless specifically requested
        if (!includeHidden && transport.isHidden) return false;

        // Special handling for cars
        if (type?.toLowerCase() == 'car') {
          return _matchesCarSearch(transport, origin, destination, type);
        }

        return transport.matchesSearch(
          searchOrigin: origin,
          searchDestination: destination,
          searchType: type,
        );
      }).toList();
    } catch (e) {
      print('Error searching transports: $e');
      return [];
    }
  }

  // Special car search matching
  static bool _matchesCarSearch(Transport transport, String? origin, String? destination, String? type) {
    // Check if it's a car
    if (transport.type.toLowerCase() != 'car') return false;

    // Check if hidden
    if (transport.isHidden) return false;

    // Get car location from various possible fields
    String carLocation = '';
    if (transport.additionalInfo != null && transport.additionalInfo!['location'] != null) {
      carLocation = transport.additionalInfo!['location'].toString();
    } else if (transport.origin.isNotEmpty) {
      carLocation = transport.origin;
    }

    print('Car: ${transport.name}, Location: $carLocation');

    // If no origin specified, return all cars
    if (origin == null || origin.isEmpty) {
      return true;
    }

    // Check if car location matches search origin
    bool locationMatch = carLocation.toLowerCase().contains(origin.toLowerCase()) ||
        origin.toLowerCase().contains(carLocation.toLowerCase());

    // Try state/city matching if direct match fails
    if (!locationMatch) {
      List<String> searchParts = origin.split(',').map((s) => s.trim().toLowerCase()).toList();
      List<String> carParts = carLocation.split(',').map((s) => s.trim().toLowerCase()).toList();

      for (String searchPart in searchParts) {
        for (String carPart in carParts) {
          if (searchPart.isNotEmpty && carPart.isNotEmpty &&
              (searchPart.contains(carPart) || carPart.contains(searchPart))) {
            locationMatch = true;
            break;
          }
        }
        if (locationMatch) break;
      }
    }

    print('Location match for ${transport.name}: $locationMatch');
    return locationMatch;
  }

  // Get transport by ID
  static Future<Transport?> getTransportById(String id) async {
    try {
      final snapshot = await _database.child(id).once();
      final data = snapshot.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final transportData = <String, dynamic>{};
        data.forEach((k, v) {
          transportData[k.toString()] = v;
        });

        return Transport.fromMap(id, transportData);
      }

      return null;
    } catch (e) {
      print('Error fetching transport by ID: $e');
      return null;
    }
  }

  // Add new transport
  static Future<String?> addTransport(Transport transport) async {
    try {
      final newRef = _database.push();
      await newRef.set(transport.toMap());
      return newRef.key;
    } catch (e) {
      print('Error adding transport: $e');
      return null;
    }
  }

  // Update transport
  static Future<bool> updateTransport(Transport transport) async {
    try {
      await _database.child(transport.id).update(transport.toMap());
      return true;
    } catch (e) {
      print('Error updating transport: $e');
      return false;
    }
  }

  // Delete transport
  static Future<bool> deleteTransport(String id) async {
    try {
      await _database.child(id).remove();
      return true;
    } catch (e) {
      print('Error deleting transport: $e');
      return false;
    }
  }

  // Toggle hide/show transport
  static Future<bool> toggleTransportVisibility(String id, bool hide) async {
    try {
      await _database.child(id).update({'hide': hide});
      return true;
    } catch (e) {
      print('Error toggling transport visibility: $e');
      return false;
    }
  }

  // Get transports by type
  static Future<List<Transport>> getTransportsByType(String type) async {
    try {
      final allTransports = await getAllTransports();
      List<Transport> filteredTransports = allTransports
          .where((transport) =>
      transport.type.toLowerCase() == type.toLowerCase() &&
          !transport.isHidden)
          .toList();

      print('Found ${filteredTransports.length} transports of type $type');
      for (var transport in filteredTransports) {
        print('Transport: ${transport.name}, Type: ${transport.type}');
        if (type.toLowerCase() == 'car' && transport.additionalInfo != null) {
          print('Car details: ${transport.additionalInfo}');
        }
      }

      return filteredTransports;
    } catch (e) {
      print('Error fetching transports by type: $e');
      return [];
    }
  }

  // Get popular routes (most frequent origin-destination pairs)
  static Future<List<String>> getPopularRoutes() async {
    try {
      final allTransports = await getAllTransports();
      final routeCounts = <String, int>{};

      for (final transport in allTransports) {
        if (!transport.isHidden) {
          final route = transport.route;
          routeCounts[route] = (routeCounts[route] ?? 0) + 1;
        }
      }

      // Sort by frequency and return top routes
      final sortedRoutes = routeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedRoutes.take(10).map((e) => e.key).toList();
    } catch (e) {
      print('Error fetching popular routes: $e');
      return [];
    }
  }

  // Stream for real-time updates
  static Stream<List<Transport>> getTransportsStream() {
    return _database.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        return <Transport>[];
      }

      List<Transport> transports = [];
      data.forEach((key, value) {
        if (value != null && value is Map<dynamic, dynamic>) {
          final transportData = <String, dynamic>{};
          value.forEach((k, v) {
            transportData[k.toString()] = v;
          });

          final transport = Transport.fromMap(key.toString(), transportData);
          transports.add(transport);
        }
      });

      return transports;
    });
  }

  // Get cars by location (specific method for car searches)
  static Future<List<Transport>> getCarsByLocation(String location) async {
    try {
      final allCars = await getTransportsByType('Car');

      return allCars.where((car) {
        String carLocation = '';
        if (car.additionalInfo != null && car.additionalInfo!['location'] != null) {
          carLocation = car.additionalInfo!['location'].toString();
        } else {
          carLocation = car.origin;
        }

        return carLocation.toLowerCase().contains(location.toLowerCase()) ||
            location.toLowerCase().contains(carLocation.toLowerCase());
      }).toList();
    } catch (e) {
      print('Error fetching cars by location: $e');
      return [];
    }
  }
}