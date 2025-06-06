import 'package:flutter/material.dart';
import '../Model/attraction_model.dart';
import '../services/attraction_service.dart';
import '../widgets/attraction_card.dart';
import 'Attractiondetails.dart';

class AttractionSearchResults extends StatefulWidget {
  final String initialQuery;

  const AttractionSearchResults({
    Key? key,
    required this.initialQuery,
  }) : super(key: key);

  @override
  _AttractionSearchResultsState createState() => _AttractionSearchResultsState();
}

class _AttractionSearchResultsState extends State<AttractionSearchResults> {
  final AttractionService _attractionService = AttractionService();
  final TextEditingController _searchController = TextEditingController();

  List<Attraction> _attractions = [];
  List<Attraction> _filteredAttractions = [];
  bool _isLoading = true;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery;
    _searchController.text = widget.initialQuery;
    _searchAttractions(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAttractions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Attraction> results = await _attractionService.searchAttractions(query);
      setState(() {
        _attractions = results;
        _filteredAttractions = results;
        _isLoading = false;
        _currentQuery = query;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching attractions: $e')),
      );
    }
  }

  void _filterAttractionsByState(String? state) {
    if (state == null || state.isEmpty) {
      setState(() {
        _filteredAttractions = _attractions;
      });
      return;
    }

    setState(() {
      _filteredAttractions = _attractions
          .where((attraction) => attraction.state.toLowerCase() == state.toLowerCase())
          .toList();
    });
  }

  void _filterAttractionsByType(String? type) {
    if (type == null || type.isEmpty) {
      setState(() {
        _filteredAttractions = _attractions;
      });
      return;
    }

    setState(() {
      _filteredAttractions = _attractions
          .where((attraction) => attraction.type.any((t) => t.toLowerCase() == type.toLowerCase()))
          .toList();
    });
  }

  void _navigateToAttractionDetail(Attraction attraction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttractionDetail(attraction: attraction),
      ),
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search attractions...',
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey[600]),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _searchAttractions(value.trim());
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              if (_searchController.text.trim().isNotEmpty) {
                _searchAttractions(_searchController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Get unique states and types from current attractions
    Set<String> states = _attractions.map((a) => a.state).toSet();
    Set<String> types = _attractions.expand((a) => a.type).toSet();

    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
        children: [
          // All filter
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('All'),
              selected: _filteredAttractions.length == _attractions.length,
              onSelected: (selected) {
                setState(() {
                  _filteredAttractions = _attractions;
                });
              },
            ),
          ),

          // Type filters
          ...types.take(5).map((type) => Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(type),
              selected: false,
              onSelected: (selected) {
                _filterAttractionsByType(type);
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching attractions...'),
          ],
        ),
      );
    }

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
            SizedBox(height: 16),
            Text(
              _currentQuery.isEmpty
                  ? 'No attractions found'
                  : 'No attractions found for "$_currentQuery"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 16),
      itemCount: _filteredAttractions.length,
      itemBuilder: (context, index) {
        return AttractionCard(
          attraction: _filteredAttractions[index],
          onTap: () => _navigateToAttractionDetail(_filteredAttractions[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search Results',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
            ),
          ),
        ),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_attractions.isNotEmpty) _buildFilterChips(),
          SizedBox(height: 8),
          if (_attractions.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_filteredAttractions.length} result${_filteredAttractions.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8),
          Expanded(
            child: _buildResultsList(),
          ),
        ],
      ),
    );
  }
}