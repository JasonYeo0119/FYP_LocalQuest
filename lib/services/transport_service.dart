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
      return allTransports
          .where((transport) =>
      transport.type.toLowerCase() == type.toLowerCase() &&
          !transport.isHidden)
          .toList();
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
}