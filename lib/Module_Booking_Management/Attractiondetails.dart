import 'package:flutter/material.dart';
import 'package:localquest/Model/attraction_model.dart';
import 'package:localquest/Module_Financial/Payment.dart';

class AttractionDetail extends StatefulWidget {
  final Attraction attraction;

  const AttractionDetail({
    Key? key,
    required this.attraction,
  }) : super(key: key);

  @override
  _AttractionDetailState createState() => _AttractionDetailState();
}

class _AttractionDetailState extends State<AttractionDetail> {
  PageController _pageController = PageController();
  int _currentImageIndex = 0;

  // Map to store selected quantities for each pricing option
  Map<int, int> _selectedQuantities = {};
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize quantities to 0 for each pricing option
    for (int i = 0; i < widget.attraction.pricing.length; i++) {
      _selectedQuantities[i] = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Check if attraction is free (all prices are 0)
  bool _isFreeAttraction() {
    return widget.attraction.pricing.every((pricing) => pricing.price == 0);
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      int newQuantity = (_selectedQuantities[index] ?? 0) + change;
      if (newQuantity >= 0) {
        _selectedQuantities[index] = newQuantity;
        _calculateTotalPrice();
      }
    });
  }

  void _calculateTotalPrice() {
    double total = 0.0;
    _selectedQuantities.forEach((index, quantity) {
      if (index < widget.attraction.pricing.length) {
        total += widget.attraction.pricing[index].price * quantity;
      }
    });
    _totalPrice = total;
  }

  int _getTotalTickets() {
    return _selectedQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  void _proceedToPayment() {
    if (_getTotalTickets() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one ticket'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create ticket summary for payment
    List<Map<String, dynamic>> selectedTickets = [];
    _selectedQuantities.forEach((index, quantity) {
      if (quantity > 0 && index < widget.attraction.pricing.length) {
        selectedTickets.add({
          'type': widget.attraction.pricing[index].remark,
          'price': widget.attraction.pricing[index].price,
          'quantity': quantity,
          'subtotal': widget.attraction.pricing[index].price * quantity,
        });
      }
    });

    // Navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPaymentPage(
          attraction: widget.attraction,
          selectedTickets: selectedTickets,
          totalPrice: _totalPrice,
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    final screenHeight = MediaQuery.of(context).size.height;

    if (widget.attraction.images.isEmpty) {
      return Container(
        height: screenHeight * 0.3,
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.image,
            size: 64,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      height: screenHeight * 0.3,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.attraction.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.attraction.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Image indicators
          if (widget.attraction.images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.attraction.images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.attraction.name,
            style: TextStyle(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: screenWidth * 0.05,
                color: Colors.red[400],
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  '${widget.attraction.address}, ${widget.attraction.city}, ${widget.attraction.state}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Types
          if (widget.attraction.type.isNotEmpty) ...[
            Text(
              'Categories',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Wrap(
              spacing: screenWidth * 0.025,
              runSpacing: screenHeight * 0.01,
              children: widget.attraction.type.map((type) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.008,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],

          // Description
          if (widget.attraction.description.isNotEmpty) ...[
            Text(
              'Description',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              widget.attraction.description,
              style: TextStyle(
                fontSize: screenWidth * 0.038,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],

          // Pricing section - only show if not free
          if (widget.attraction.pricing.isNotEmpty && !_isFreeAttraction()) ...[
            Text(
              'Select Tickets',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: widget.attraction.pricing.asMap().entries.map((entry) {
                  int index = entry.key;
                  PricingInfo pricing = entry.value;
                  bool isLast = index == widget.attraction.pricing.length - 1;
                  int quantity = _selectedQuantities[index] ?? 0;

                  return Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      border: isLast ? null : Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pricing.remark,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.038,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'RM ${pricing.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Decrease button
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: quantity > 0 ? Color(0xFF0C1FF7) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: quantity > 0 ? Colors.white : Colors.grey[600],
                                    ),
                                    onPressed: quantity > 0 ? () => _updateQuantity(index, -1) : null,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Quantity display
                                Container(
                                  width: 40,
                                  child: Text(
                                    '$quantity',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // Increase button
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF0C1FF7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _updateQuantity(index, 1),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (quantity > 0) ...[
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Subtotal: RM ${(pricing.price * quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Total and Book Now section - only show if tickets selected and not free
            if (_getTotalTickets() > 0) ...[
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0C1FF7), Color(0xFF02BFFF)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTotalTickets()} Ticket${_getTotalTickets() > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Total: RM ${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF0C1FF7),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],

          // Free attraction notice - show if all prices are 0
          if (_isFreeAttraction() && widget.attraction.pricing.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[400]!, Colors.green[600]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Free Attraction',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'This attraction is free to visit. No booking required!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.attraction.name,
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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }
}