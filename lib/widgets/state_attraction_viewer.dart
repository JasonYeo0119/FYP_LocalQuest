import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Model/attraction_model.dart';
import '../services/itinerary_service.dart';

class StateAttractionsViewer extends StatefulWidget {
  final Set<String> selectedStates;
  final TripType tripType;
  final double maxBudget;

  const StateAttractionsViewer({
    Key? key,
    required this.selectedStates,
    required this.tripType,
    required this.maxBudget,
  }) : super(key: key);

  @override
  State<StateAttractionsViewer> createState() => _StateAttractionsViewerState();
}

class _StateAttractionsViewerState extends State<StateAttractionsViewer> {
  final FirebaseItineraryService _itineraryService = FirebaseItineraryService();
  Map<String, List<Attraction>> _attractionsByState = {};
  Map<String, bool> _loadingStates = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  'Selected States',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tap on any state to view available attractions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.selectedStates.map((state) {
                return _buildStateCard(state);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard(String state) {
    bool isLoading = _loadingStates[state] ?? false;
    int attractionCount = _attractionsByState[state]?.length ?? 0;

    return InkWell(
      onTap: () => _showStateAttractions(state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.place,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  state,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isLoading) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ] else if (attractionCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                '$attractionCount attractions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showStateAttractions(String state) async {
    // Load attractions if not already loaded
    if (!_attractionsByState.containsKey(state)) {
      setState(() {
        _loadingStates[state] = true;
      });

      try {
        List<Attraction> attractions = await _itineraryService.searchAttractionsOptimized(
          states: [state],
          tripType: widget.tripType,
          maxPrice: 999999,
        );

        setState(() {
          _attractionsByState[state] = attractions;
          _loadingStates[state] = false;
        });
      } catch (e) {
        setState(() {
          _loadingStates[state] = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading attractions for $state: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    // Show dialog with attractions
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => StateAttractionsDialog(
          state: state,
          attractions: _attractionsByState[state] ?? [],
          tripType: widget.tripType,
        ),
      );
    }
  }
}

class StateAttractionsDialog extends StatefulWidget {
  final String state;
  final List<Attraction> attractions;
  final TripType tripType;

  const StateAttractionsDialog({
    Key? key,
    required this.state,
    required this.attractions,
    required this.tripType,
  }) : super(key: key);

  @override
  State<StateAttractionsDialog> createState() => _StateAttractionsDialogState();
}

class _StateAttractionsDialogState extends State<StateAttractionsDialog> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<String> get _availableFilters {
    Set<String> types = {'All'};
    for (var attraction in widget.attractions) {
      types.addAll(attraction.type);
    }
    return types.toList()..sort();
  }

  List<Attraction> get _filteredAttractions {
    List<Attraction> filtered = widget.attractions;

    // Filter by type
    if (_selectedFilter != 'All') {
      filtered = filtered.where((attraction) {
        return attraction.type.any((type) =>
            type.toLowerCase().contains(_selectedFilter.toLowerCase()));
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((attraction) {
        return attraction.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            attraction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            attraction.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 16),
            Expanded(child: _buildAttractionsList()),
            const SizedBox(height: 16),
            _buildCloseButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attractions in ${widget.state}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.attractions.length} attractions available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search attractions...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear),
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 12),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _availableFilters.map((filter) {
              bool isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? filter : 'All';
                    });
                  },
                  selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    Map<String, int> priceRanges = {
      'Free': 0,
      'Under RM25': 0,
      'RM25-50': 0,
      'Above RM50': 0,
    };

    for (var attraction in _filteredAttractions) {
      double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
      if (price == 0) {
        priceRanges['Free'] = priceRanges['Free']! + 1;
      } else if (price < 25) {
        priceRanges['Under RM25'] = priceRanges['Under RM25']! + 1;
      } else if (price <= 50) {
        priceRanges['RM25-50'] = priceRanges['RM25-50']! + 1;
      } else {
        priceRanges['Above RM50'] = priceRanges['Above RM50']! + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Stats (${_filteredAttractions.length} shown)',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildAttractionsList() {
    if (_filteredAttractions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No attractions found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredAttractions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return _buildAttractionTile(_filteredAttractions[index]);
      },
    );
  }

  Widget _buildAttractionTile(Attraction attraction) {
    double price = attraction.pricing.isNotEmpty ? attraction.pricing.first.price : 0;
    String priceText = price == 0 ? 'Free' : 'RM${price.toStringAsFixed(0)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),

      title: Text(
        attraction.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            attraction.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  attraction.address,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: attraction.type.take(3).map((type) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: price == 0 ? Colors.green : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          priceText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () {
        _showAttractionDetails(attraction);
      },
    );
  }

  IconData _getAttractionIcon(List<String> types) {
    if (types.isEmpty) return Icons.place;

    String firstType = types.first.toLowerCase();

    if (firstType.contains('heritage') || firstType.contains('culture')) {
      return Icons.account_balance;
    } else if (firstType.contains('nature') || firstType.contains('park')) {
      return Icons.park;
    } else if (firstType.contains('beach') || firstType.contains('water')) {
      return Icons.beach_access;
    } else if (firstType.contains('shopping')) {
      return Icons.shopping_bag;
    } else if (firstType.contains('adventure') || firstType.contains('sports')) {
      return Icons.terrain;
    } else if (firstType.contains('theme')) {
      return Icons.park;
    } else if (firstType.contains('food') || firstType.contains('restaurant')) {
      return Icons.restaurant;
    } else {
      return Icons.place;
    }
  }

  void _showAttractionDetails(Attraction attraction) {
    showDialog(
      context: context,
      builder: (context) => AttractionDetailsDialog(attraction: attraction),
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Close'),
      ),
    );
  }
}

class AttractionDetailsDialog extends StatelessWidget {
  final Attraction attraction;

  const AttractionDetailsDialog({Key? key, required this.attraction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    attraction.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              attraction.description.split(' ').length > 10
                  ? '${attraction.description.split(' ').take(10).join(' ')}...'
                  : attraction.description,
            ),

            const SizedBox(height: 16),

            // Location
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(attraction.address)),
              ],
            ),

            const SizedBox(height: 16),

            // Types
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: attraction.type.map((type) {
                return Chip(
                  label: Text(type),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Pricing
            if (attraction.pricing.isNotEmpty) ...[
              Text(
                'Pricing',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...attraction.pricing.asMap().entries.map((entry) {
                int index = entry.key;
                var pricing = entry.value;
                String categoryName = 'Entry Fee';

                // Handle different pricing tiers if multiple exist
                if (attraction.pricing.length > 1) {
                  switch (index) {
                    case 0:
                      categoryName = 'Adult';
                      break;
                    case 1:
                      categoryName = 'Child';
                      break;
                    case 2:
                      categoryName = 'Senior';
                      break;
                    default:
                      categoryName = 'Tier ${index + 1}';
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(categoryName),
                      Text(
                        'RM${pricing.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.money_off, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'Free Attraction',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}