import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/transport.dart';
import '../Model/attraction_model.dart';
import '../Model/hotel.dart';
import '../services/itinerary_service.dart';

class SavedItinerary {
  final String id;
  final String name;
  final DateTime savedDate;
  final GeneratedItinerary itinerary;

  SavedItinerary({
    required this.id,
    required this.name,
    required this.savedDate,
    required this.itinerary,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'savedDate': savedDate.toIso8601String(),
      'itinerary': itinerary.toJson(),
    };
  }

  factory SavedItinerary.fromJson(Map<String, dynamic> json) {
    return SavedItinerary(
      id: json['id'],
      name: json['name'],
      savedDate: DateTime.parse(json['savedDate']),
      itinerary: GeneratedItinerary.fromJson(json['itinerary']),
    );
  }
}

class ItineraryStorageService {
  static const String _storageKey = 'saved_itineraries';

  // Save an itinerary
  static Future<bool> saveItinerary(GeneratedItinerary itinerary, String customName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Generate unique ID
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      // Create saved itinerary
      final savedItinerary = SavedItinerary(
        id: id,
        name: customName,
        savedDate: DateTime.now(),
        itinerary: itinerary,
      );

      // Get existing saved itineraries
      final existingItineraries = await getAllSavedItineraries();

      // Add new itinerary
      existingItineraries.add(savedItinerary);

      // Convert to JSON and save
      final jsonList = existingItineraries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error saving itinerary: $e');
      return false;
    }
  }

  // Get all saved itineraries
  static Future<List<SavedItinerary>> getAllSavedItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => SavedItinerary.fromJson(json)).toList();
    } catch (e) {
      print('Error loading itineraries: $e');
      return [];
    }
  }

  // Delete an itinerary
  static Future<bool> deleteItinerary(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingItineraries = await getAllSavedItineraries();

      // Remove itinerary with matching ID
      existingItineraries.removeWhere((itinerary) => itinerary.id == id);

      // Save updated list
      final jsonList = existingItineraries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error deleting itinerary: $e');
      return false;
    }
  }

  // Check if an itinerary name already exists
  static Future<bool> doesNameExist(String name) async {
    final existingItineraries = await getAllSavedItineraries();
    return existingItineraries.any((itinerary) => itinerary.name.toLowerCase() == name.toLowerCase());
  }

  // Update itinerary name
  static Future<bool> updateItineraryName(String id, String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingItineraries = await getAllSavedItineraries();

      // Find and update the itinerary
      final index = existingItineraries.indexWhere((itinerary) => itinerary.id == id);
      if (index == -1) return false;

      existingItineraries[index] = SavedItinerary(
        id: existingItineraries[index].id,
        name: newName,
        savedDate: existingItineraries[index].savedDate,
        itinerary: existingItineraries[index].itinerary,
      );

      // Save updated list
      final jsonList = existingItineraries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error updating itinerary name: $e');
      return false;
    }
  }

  // Get saved itinerary by ID
  static Future<SavedItinerary?> getItineraryById(String id) async {
    try {
      final existingItineraries = await getAllSavedItineraries();
      final index = existingItineraries.indexWhere((itinerary) => itinerary.id == id);
      return index != -1 ? existingItineraries[index] : null;
    } catch (e) {
      print('Error getting itinerary by ID: $e');
      return null;
    }
  }

  // Update entire itinerary (for when user modifies the itinerary)
  static Future<bool> updateItinerary(String id, GeneratedItinerary updatedItinerary) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingItineraries = await getAllSavedItineraries();

      // Find and update the itinerary
      final index = existingItineraries.indexWhere((itinerary) => itinerary.id == id);
      if (index == -1) return false;

      existingItineraries[index] = SavedItinerary(
        id: existingItineraries[index].id,
        name: existingItineraries[index].name,
        savedDate: existingItineraries[index].savedDate,
        itinerary: updatedItinerary,
      );

      // Save updated list
      final jsonList = existingItineraries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('Error updating itinerary: $e');
      return false;
    }
  }

  // Get itineraries count
  static Future<int> getItinerariesCount() async {
    final itineraries = await getAllSavedItineraries();
    return itineraries.length;
  }

  // Clear all saved itineraries
  static Future<bool> clearAllItineraries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing all itineraries: $e');
      return false;
    }
  }

  // Get itineraries sorted by date (newest first)
  static Future<List<SavedItinerary>> getItinerariesSortedByDate() async {
    final itineraries = await getAllSavedItineraries();
    itineraries.sort((a, b) => b.savedDate.compareTo(a.savedDate));
    return itineraries;
  }

  // Get itineraries sorted by name
  static Future<List<SavedItinerary>> getItinerariesSortedByName() async {
    final itineraries = await getAllSavedItineraries();
    itineraries.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return itineraries;
  }

  // Search itineraries by name
  static Future<List<SavedItinerary>> searchItinerariesByName(String searchTerm) async {
    final itineraries = await getAllSavedItineraries();
    return itineraries.where((itinerary) =>
        itinerary.name.toLowerCase().contains(searchTerm.toLowerCase())
    ).toList();
  }

  // Get itineraries by state
  static Future<List<SavedItinerary>> getItinerariesByState(String state) async {
    final itineraries = await getAllSavedItineraries();
    return itineraries.where((savedItinerary) =>
        savedItinerary.itinerary.originalRequest.selectedStates.contains(state)
    ).toList();
  }

  // Get itineraries within budget range
  static Future<List<SavedItinerary>> getItinerariesInBudgetRange(double minBudget, double maxBudget) async {
    final itineraries = await getAllSavedItineraries();
    return itineraries.where((savedItinerary) =>
    savedItinerary.itinerary.totalCost >= minBudget &&
        savedItinerary.itinerary.totalCost <= maxBudget
    ).toList();
  }

  // Export itinerary as JSON string (for sharing)
  static Future<String?> exportItinerary(String id) async {
    try {
      final itinerary = await getItineraryById(id);
      if (itinerary == null) return null;

      return jsonEncode(itinerary.toJson());
    } catch (e) {
      print('Error exporting itinerary: $e');
      return null;
    }
  }

  // Import itinerary from JSON string
  static Future<bool> importItinerary(String jsonString, String customName) async {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final savedItinerary = SavedItinerary.fromJson(json);

      // Create new itinerary with custom name and new ID
      final newSavedItinerary = SavedItinerary(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: customName,
        savedDate: DateTime.now(),
        itinerary: savedItinerary.itinerary,
      );

      // Get existing itineraries and add the new one
      final existingItineraries = await getAllSavedItineraries();
      existingItineraries.add(newSavedItinerary);

      // Save updated list
      final prefs = await SharedPreferences.getInstance();
      final jsonList = existingItineraries.map((e) => e.toJson()).toList();
      final jsonStringToSave = jsonEncode(jsonList);

      return await prefs.setString(_storageKey, jsonStringToSave);
    } catch (e) {
      print('Error importing itinerary: $e');
      return false;
    }
  }

  // Duplicate an existing itinerary
  static Future<bool> duplicateItinerary(String originalId, String newName) async {
    try {
      final originalItinerary = await getItineraryById(originalId);
      if (originalItinerary == null) return false;

      return await saveItinerary(originalItinerary.itinerary, newName);
    } catch (e) {
      print('Error duplicating itinerary: $e');
      return false;
    }
  }

  // Get storage usage information
  static Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      final itineraries = await getAllSavedItineraries();
      final sizeInBytes = jsonString?.length ?? 0;
      final sizeInKB = (sizeInBytes / 1024).toStringAsFixed(2);

      return {
        'count': itineraries.length,
        'sizeInBytes': sizeInBytes,
        'sizeInKB': sizeInKB,
        'averageSizePerItinerary': itineraries.isNotEmpty ? (sizeInBytes / itineraries.length).toStringAsFixed(2) : '0',
      };
    } catch (e) {
      print('Error getting storage info: $e');
      return {
        'count': 0,
        'sizeInBytes': 0,
        'sizeInKB': '0',
        'averageSizePerItinerary': '0',
      };
    }
  }
}

// Helper class for itinerary statistics
class ItineraryStatistics {
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final itineraries = await ItineraryStorageService.getAllSavedItineraries();

      if (itineraries.isEmpty) {
        return {
          'totalItineraries': 0,
          'averageBudget': 0.0,
          'mostVisitedState': 'None',
          'averageDuration': 0.0,
          'budgetRange': {'min': 0.0, 'max': 0.0},
        };
      }

      // Calculate statistics
      double totalBudget = 0;
      int totalDuration = 0;
      Map<String, int> stateVisitCount = {};
      double minBudget = double.infinity;
      double maxBudget = 0;

      for (var savedItinerary in itineraries) {
        final itinerary = savedItinerary.itinerary;

        // Budget statistics
        totalBudget += itinerary.totalCost;
        if (itinerary.totalCost < minBudget) minBudget = itinerary.totalCost;
        if (itinerary.totalCost > maxBudget) maxBudget = itinerary.totalCost;

        // Duration statistics
        totalDuration += itinerary.originalRequest.tripDuration;

        // State visit count
        for (String state in itinerary.originalRequest.selectedStates) {
          stateVisitCount[state] = (stateVisitCount[state] ?? 0) + 1;
        }
      }

      // Find most visited state
      String mostVisitedState = 'None';
      int maxVisits = 0;
      stateVisitCount.forEach((state, count) {
        if (count > maxVisits) {
          maxVisits = count;
          mostVisitedState = state;
        }
      });

      return {
        'totalItineraries': itineraries.length,
        'averageBudget': totalBudget / itineraries.length,
        'mostVisitedState': mostVisitedState,
        'averageDuration': totalDuration / itineraries.length,
        'budgetRange': {
          'min': minBudget == double.infinity ? 0.0 : minBudget,
          'max': maxBudget
        },
        'stateVisitCount': stateVisitCount,
      };
    } catch (e) {
      print('Error calculating statistics: $e');
      return {
        'totalItineraries': 0,
        'averageBudget': 0.0,
        'mostVisitedState': 'None',
        'averageDuration': 0.0,
        'budgetRange': {'min': 0.0, 'max': 0.0},
      };
    }
  }
}
