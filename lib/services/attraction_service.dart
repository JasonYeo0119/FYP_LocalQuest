import 'package:firebase_database/firebase_database.dart';
import '../Model/attraction_model.dart';

class AttractionService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('Attractions');

  // Search attractions by various criteria
  Future<List<Attraction>> searchAttractions(String query) async {
    try {
      DatabaseEvent event = await _dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      List<Attraction> allAttractions = [];
      List<Attraction> filteredAttractions = [];

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> attractionsData = snapshot.value as Map<dynamic, dynamic>;

        // Convert all attractions from Firebase
        attractionsData.forEach((key, value) {
          if (value != null) {
            allAttractions.add(Attraction.fromMap(key.toString(), value as Map<dynamic, dynamic>));
          }
        });

        // Filter attractions based on search query
        String searchQuery = query.toLowerCase().trim();

        if (searchQuery.isEmpty) {
          return allAttractions; // Return all if no search query
        }

        for (Attraction attraction in allAttractions) {
          bool matches = false;

          // Search by name
          if (attraction.name.toLowerCase().contains(searchQuery)) {
            matches = true;
          }

          // Search by city
          if (attraction.city.toLowerCase().contains(searchQuery)) {
            matches = true;
          }

          // Search by state
          if (attraction.state.toLowerCase().contains(searchQuery)) {
            matches = true;
          }

          // Search by address
          if (attraction.address.toLowerCase().contains(searchQuery)) {
            matches = true;
          }

          // Search by description
          if (attraction.description.toLowerCase().contains(searchQuery)) {
            matches = true;
          }

          // Search by type
          for (String type in attraction.type) {
            if (type.toLowerCase().contains(searchQuery)) {
              matches = true;
              break;
            }
          }

          if (matches) {
            filteredAttractions.add(attraction);
          }
        }
      }

      return filteredAttractions;
    } catch (e) {
      print('Error searching attractions: $e');
      return [];
    }
  }

  // Get all attractions
  Future<List<Attraction>> getAllAttractions() async {
    try {
      DatabaseEvent event = await _dbRef.once();
      DataSnapshot snapshot = event.snapshot;

      List<Attraction> attractions = [];

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> attractionsData = snapshot.value as Map<dynamic, dynamic>;

        attractionsData.forEach((key, value) {
          if (value != null) {
            attractions.add(Attraction.fromMap(key.toString(), value as Map<dynamic, dynamic>));
          }
        });
      }

      return attractions;
    } catch (e) {
      print('Error fetching attractions: $e');
      return [];
    }
  }

  // Get attractions by state
  Future<List<Attraction>> getAttractionsByState(String state) async {
    try {
      List<Attraction> allAttractions = await getAllAttractions();
      return allAttractions.where((attraction) =>
      attraction.state.toLowerCase() == state.toLowerCase()).toList();
    } catch (e) {
      print('Error fetching attractions by state: $e');
      return [];
    }
  }

  // Get attractions by type
  Future<List<Attraction>> getAttractionsByType(String type) async {
    try {
      List<Attraction> allAttractions = await getAllAttractions();
      return allAttractions.where((attraction) =>
          attraction.type.any((t) => t.toLowerCase() == type.toLowerCase())).toList();
    } catch (e) {
      print('Error fetching attractions by type: $e');
      return [];
    }
  }

  // Get attraction by ID
  Future<Attraction?> getAttractionById(String id) async {
    try {
      DatabaseEvent event = await _dbRef.child(id).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        return Attraction.fromMap(id, snapshot.value as Map<dynamic, dynamic>);
      }

      return null;
    } catch (e) {
      print('Error fetching attraction by ID: $e');
      return null;
    }
  }
}