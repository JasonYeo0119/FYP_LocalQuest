import '../Model/hotel.dart';

class MockMalaysiaHotelService {
  static final List<Map<String, dynamic>> _mockHotels = [
    // KUALA LUMPUR (25 properties)
    {
      'id': 1,
      'name': 'Petronas Twin Towers Hotel',
      'address': 'KLCC, 50088 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 320.0,
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Gym', 'Spa', 'Fine Dining', 'City View', 'Concierge']
    },
    {
      'id': 2,
      'name': 'Budget Inn KL Central',
      'address': 'Jalan Sultan, 50000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 45.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Air Conditioning', '24/7 Reception']
    },
    {
      'id': 3,
      'name': 'Bukit Bintang Suites',
      'address': 'Bukit Bintang, 55100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Kitchen', 'Pool', 'Gym', 'Shopping Access']
    },
    {
      'id': 4,
      'name': 'KL Tower View Studio',
      'address': 'Jalan P. Ramlee, 50250 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Kitchenette', 'City View', 'Pool']
    },
    {
      'id': 5,
      'name': 'Mid Valley Service Apartment',
      'address': 'Mid Valley City, 59200 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 150.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Full Kitchen', 'Pool', 'Gym', 'Mall Access']
    },
    {
      'id': 6,
      'name': 'Golden Triangle Hotel',
      'address': 'Jalan Raja Chulan, 50200 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Restaurant', 'Business Center']
    },
    {
      'id': 7,
      'name': 'Chinatown Heritage Inn',
      'address': 'Petaling Street, 50000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.5,
      'price': 65.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Design', 'Street Food Access']
    },
    {
      'id': 8,
      'name': 'KLCC Luxury Residence',
      'address': 'Jalan Ampang, 50450 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 380.0,
      'currency': 'MYR',
      'type': 'Luxury Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Private Balcony', 'Concierge', 'Spa', 'Fine Dining']
    },
    {
      'id': 9,
      'name': 'Sentul Park Hotel',
      'address': 'Jalan Sentul, 51000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 85.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Restaurant', 'Park View']
    },
    {
      'id': 10,
      'name': 'Bangsar Studio Loft',
      'address': 'Bangsar, 59100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Modern Design', 'Kitchenette', 'Cafe Access']
    },
    {
      'id': 11,
      'name': 'Ampang Point Suites',
      'address': 'Ampang, 68000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Separate Living Room', 'Pool', 'Parking']
    },
    {
      'id': 12,
      'name': 'KL Express Hotel',
      'address': 'Jalan Tun Razak, 50400 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.3,
      'price': 55.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Express Check-in', 'Vending Machine']
    },
    {
      'id': 13,
      'name': 'Mont Kiara Luxury Apartment',
      'address': 'Mont Kiara, 50480 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 220.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Multiple Bedrooms', 'Pool', 'Gym', 'Security']
    },
    {
      'id': 14,
      'name': 'Pavilion Elite Hotel',
      'address': 'Jalan Bukit Bintang, 55100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 280.0,
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Luxury Shopping', 'Spa', 'Fine Dining', 'Butler Service']
    },
    {
      'id': 15,
      'name': 'Wangsa Maju Budget Inn',
      'address': 'Wangsa Maju, 53300 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.1,
      'price': 40.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Basic Amenities', 'Parking']
    },
    {
      'id': 16,
      'name': 'Damansara Heights Studio',
      'address': 'Damansara Heights, 50490 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 130.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Hill View', 'Kitchenette', 'Quiet Area']
    },
    {
      'id': 17,
      'name': 'Setapak Central Hotel',
      'address': 'Setapak, 53300 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.7,
      'price': 75.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Restaurant', 'Meeting Room', 'Parking']
    },
    {
      'id': 18,
      'name': 'TTDI Premium Suites',
      'address': 'Taman Tun Dr Ismail, 60000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 190.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Spacious Living', 'Pool', 'Garden View']
    },
    {
      'id': 19,
      'name': 'Cheras Business Hotel',
      'address': 'Cheras, 56000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.6,
      'price': 70.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Business Center', 'Restaurant', 'Conference Room']
    },
    {
      'id': 20,
      'name': 'KL City Center Apartment',
      'address': 'Jalan Raja Laut, 50350 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 170.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Access', 'Full Kitchen', 'Balcony']
    },
    {
      'id': 21,
      'name': 'Sunway Pyramid Hotel',
      'address': 'Sunway City, 47500 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 210.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Access', 'Pool', 'Mall Connection']
    },
    {
      'id': 22,
      'name': 'Old Town White Coffee Inn',
      'address': 'Jalan Alor, 50200 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 60.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Food Street Access', 'Local Experience']
    },
    {
      'id': 23,
      'name': 'Tropicana Studio Residence',
      'address': 'Tropicana, 47410 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 125.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Golf Course View', 'Pool', 'Gym']
    },
    {
      'id': 24,
      'name': 'Brickfields Little India Hotel',
      'address': 'Brickfields, 50470 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.5,
      'price': 65.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Cultural District', 'Indian Restaurants']
    },
    {
      'id': 25,
      'name': 'The Face Platinum Suites',
      'address': 'Jalan Sultan Ismail, 50250 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 350.0,
      'currency': 'MYR',
      'type': 'Luxury Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Platinum Service', 'Sky Pool', 'Private Butler', 'City Panorama']
    },

    // PENANG (15 properties)
    {
      'id': 26,
      'name': 'George Town Heritage Hotel',
      'address': 'Armenian Street, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Heritage Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Design', 'UNESCO Area', 'Cultural Tours']
    },
    {
      'id': 27,
      'name': 'Gurney Plaza Apartment',
      'address': 'Gurney Drive, 10250 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sea View', 'Mall Access', 'Pool']
    },
    {
      'id': 28,
      'name': 'Penang Budget Hostel',
      'address': 'Chulia Street, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 35.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Backpacker Friendly', 'Common Area']
    },
    {
      'id': 29,
      'name': 'Batu Ferringhi Beach Resort',
      'address': 'Batu Ferringhi, 11100 Penang',
      'city': 'Batu Ferringhi',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 250.0,
      'currency': 'MYR',
      'type': 'Beach Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Pool', 'Water Sports', 'Spa']
    },
    {
      'id': 30,
      'name': 'Straits Quay Marina Suites',
      'address': 'Tanjong Tokong, 10470 Penang',
      'city': 'Tanjong Tokong',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Marina View', 'Yacht Access', 'Fine Dining']
    },
    {
      'id': 31,
      'name': 'Penang Hill Studio',
      'address': 'Air Itam, 11500 Penang',
      'city': 'Air Itam',
      'country': 'Malaysia',
      'rating': 3.9,
      'price': 95.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Hill View', 'Cool Climate', 'Nature Access']
    },
    {
      'id': 32,
      'name': 'Queensbay Mall Hotel',
      'address': 'Bayan Lepas, 11900 Penang',
      'city': 'Bayan Lepas',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'Airport Access', 'Restaurant']
    },
    {
      'id': 33,
      'name': 'Jelutong Budget Inn',
      'address': 'Jelutong, 11600 Penang',
      'city': 'Jelutong',
      'country': 'Malaysia',
      'rating': 3.1,
      'price': 42.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Local Area', 'Basic Comfort']
    },
    {
      'id': 34,
      'name': 'Tanjung Bungah Luxury Villa',
      'address': 'Tanjung Bungah, 11200 Penang',
      'city': 'Tanjung Bungah',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 320.0,
      'currency': 'MYR',
      'type': 'Luxury Villa',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Private Pool', 'Sea View', 'Butler Service', 'Privacy']
    },
    {
      'id': 35,
      'name': 'Komtar View Apartment',
      'address': 'Jalan Penang, 10000 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 110.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Center', 'Transport Hub', 'Shopping']
    },
    {
      'id': 36,
      'name': 'Tropical Spice Garden Resort',
      'address': 'Lone Pine, 11100 Penang',
      'city': 'Batu Ferringhi',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 220.0,
      'currency': 'MYR',
      'type': 'Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Spice Garden', 'Nature Tours', 'Spa', 'Restaurant']
    },
    {
      'id': 37,
      'name': 'Butterworth Transit Hotel',
      'address': 'Butterworth, 12300 Penang',
      'city': 'Butterworth',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 58.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Ferry Terminal', 'Transit Friendly']
    },
    {
      'id': 38,
      'name': 'Gurney Paragon Suites',
      'address': 'Gurney Drive, 10250 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 230.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Premium Location', 'Sea View', 'Mall Access', 'Pool']
    },
    {
      'id': 39,
      'name': 'Balik Pulau Orchard Stay',
      'address': 'Balik Pulau, 11000 Penang',
      'city': 'Balik Pulau',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 85.0,
      'currency': 'MYR',
      'type': 'Countryside Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Fruit Orchards', 'Rural Experience', 'Nature']
    },
    {
      'id': 40,
      'name': 'Eastern & Oriental Luxury',
      'address': 'Lebuh Farquhar, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.9,
      'price': 450.0,
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Colonial Heritage', 'Sea View', 'Fine Dining', 'Spa', 'Butler']
    },

    // LANGKAWI (10 properties)
    {
      'id': 41,
      'name': 'Pantai Cenang Beach Resort',
      'address': 'Pantai Cenang, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Beach Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Pool', 'Water Sports', 'Restaurant']
    },
    {
      'id': 42,
      'name': 'Datai Bay Luxury Resort',
      'address': 'Datai Bay, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 480.0,
      'currency': 'MYR',
      'type': 'Luxury Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Rainforest', 'Private Beach', 'Spa', 'Golf', 'Fine Dining']
    },
    {
      'id': 43,
      'name': 'Kuah Town Budget Hotel',
      'address': 'Kuah, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 55.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Ferry Terminal', 'Duty Free Shopping']
    },
    {
      'id': 44,
      'name': 'Tanjung Rhu Beach Villa',
      'address': 'Tanjung Rhu, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 280.0,
      'currency': 'MYR',
      'type': 'Beach Villa',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Private Beach', 'Mangrove Tours', 'Kayaking']
    },
    {
      'id': 45,
      'name': 'Pantai Tengah Apartment',
      'address': 'Pantai Tengah, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Proximity', 'Kitchen', 'Balcony']
    },
    {
      'id': 46,
      'name': 'Cable Car View Studio',
      'address': 'Oriental Village, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 95.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Cable Car Access', 'Mountain View', 'Adventure Activities']
    },
    {
      'id': 47,
      'name': 'Burau Bay Resort',
      'address': 'Burau Bay, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Bay View', 'Pool', 'Restaurant', 'Boat Tours']
    },
    {
      'id': 48,
      'name': 'Langkawi Airport Hotel',
      'address': 'Padang Mat Sirat, 07100 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 3.5,
      'price': 75.0,
      'currency': 'MYR',
      'type': 'Transit Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Airport Shuttle', 'Early Check-in', 'Restaurant']
    },
    {
      'id': 49,
      'name': 'Pelangi Beach Suites',
      'address': 'Pantai Cenang, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach View', 'Separate Living', 'Pool', 'Spa']
    },
    {
      'id': 50,
      'name': 'Underwater World Budget Stay',
      'address': 'Pantai Cenang, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 3.3,
      'price': 48.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Aquarium Access', 'Beach Walk', 'Local Food']
    },

    // JOHOR BAHRU (12 properties)
    {
      'id': 51,
      'name': 'JB City Square Hotel',
      'address': 'City Square, 80000 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Mall Connection', 'Singapore Border', 'Restaurant']
    },
    {
      'id': 52,
      'name': 'Legoland Family Suite',
      'address': 'Nusajaya, 79100 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 220.0,
      'currency': 'MYR',
      'type': 'Family Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Access', 'Family Facilities', 'Pool', 'Kids Club']
    },
    {
      'id': 53,
      'name': 'JB Budget Express',
      'address': 'Jalan Wong Ah Fook, 80000 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.0,
      'price': 45.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Access', 'Basic Amenities']
    },
    {
      'id': 54,
      'name': 'Puteri Harbour Marina Suites',
      'address': 'Puteri Harbour, 79100 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 190.0,
      'currency': 'MYR',
      'type': 'Marina Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Marina View', 'Yacht Club', 'Fine Dining', 'Premium Location']
    },
    {
      'id': 55,
      'name': 'Danga Bay Apartment',
      'address': 'Danga Bay, 80200 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.9,
      'price': 110.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Waterfront', 'Full Kitchen', 'Sea Breeze']
    },
    {
      'id': 56,
      'name': 'Senai Airport Hotel',
      'address': 'Senai, 81400 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.7,
      'price': 85.0,
      'currency': 'MYR',
      'type': 'Airport Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Airport Shuttle', 'Business Center', 'Restaurant']
    },
    {
      'id': 57,
      'name': 'Molek Pine Studio',
      'address': 'Taman Molek, 81100 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 90.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Quiet Neighborhood', 'Kitchenette', 'Parking']
    },
    {
      'id': 58,
      'name': 'Paradigm Mall Hotel',
      'address': 'Skudai, 81300 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 125.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'University Area', 'Restaurant']
    },
    {
      'id': 59,
      'name': 'JB Luxury Penthouse',
      'address': 'Austin Heights, 81100 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 300.0,
      'currency': 'MYR',
      'type': 'Luxury Penthouse',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Skyline', 'Private Terrace', 'Premium Facilities', 'Concierge']
    },
    {
      'id': 60,
      'name': 'Taman Sentosa Budget Inn',
      'address': 'Taman Sentosa, 80150 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 42.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Local Area', 'Affordable Stay']
    },
    {
      'id': 61,
      'name': 'Forest City Marina Resort',
      'address': 'Forest City, 81550 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 280.0,
      'currency': 'MYR',
      'type': 'Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Artificial Island', 'Marina', 'Golf', 'Beach Club']
    },
    {
      'id': 62,
      'name': 'Larkin Sentral Apartment',
      'address': 'Larkin, 80350 Johor Bahru, Johor',
      'city': 'Johor Bahru',
      'country': 'Malaysia',
      'rating': 3.6,
      'price': 95.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Transport Hub', 'Shopping Access', 'Full Kitchen']
    },

    // KOTA KINABALU (8 properties)
    {
      'id': 63,
      'name': 'Shangri-La Tanjung Aru',
      'address': 'Tanjung Aru, 88100 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 350.0,
      'currency': 'MYR',
      'type': 'Luxury Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sunset Views', 'Private Beach', 'Spa', 'Golf', 'Fine Dining']
    },
    {
      'id': 64,
      'name': 'KK City Budget Lodge',
      'address': 'Jalan Gaya, 88000 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 3.3,
      'price': 50.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sunday Market', 'Waterfront Access', 'Local Food']
    },
    {
      'id': 65,
      'name': 'Imago Shopping Mall Suites',
      'address': 'Imago, 88100 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 170.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'City Center', 'Modern Facilities']
    },
    {
      'id': 66,
      'name': 'Signal Hill Observatory Studio',
      'address': 'Signal Hill, 88000 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 115.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Observatory View', 'City Panorama', 'Hiking Access']
    },
    {
      'id': 67,
      'name': 'Likas Bay Apartment',
      'address': 'Likas, 88400 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 3.9,
      'price': 105.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Bay View', 'Sports Complex', 'Jogging Track']
    },
    {
      'id': 68,
      'name': 'KK Airport Transit Hotel',
      'address': 'KKIA, 88200 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 3.6,
      'price': 80.0,
      'currency': 'MYR',
      'type': 'Transit Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Airport Access', 'Transit Lounge', 'Restaurant']
    },
    {
      'id': 69,
      'name': 'Manukan Island Resort',
      'address': 'Manukan Island, 88000 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 240.0,
      'currency': 'MYR',
      'type': 'Island Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Island Paradise', 'Snorkeling', 'Water Sports', 'Beach Bar']
    },
    {
      'id': 70,
      'name': 'Waterfront Esplanade Hotel',
      'address': 'Waterfront, 88000 Kota Kinabalu, Sabah',
      'city': 'Kota Kinabalu',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 145.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Waterfront View', 'Night Market', 'Seafood Restaurants']
    },

    // MELAKA (8 properties)
    {
      'id': 71,
      'name': 'Casa del Rio Heritage Hotel',
      'address': 'Melaka River, 75000 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 220.0,
      'currency': 'MYR',
      'type': 'Heritage Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'River View', 'Heritage Design', 'UNESCO Area', 'Spa']
    },
    {
      'id': 72,
      'name': 'Jonker Street Budget Inn',
      'address': 'Jonker Street, 75200 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 55.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Night Market', 'Antique Shops', 'Local Culture']
    },
    {
      'id': 73,
      'name': 'A Famosa Resort Villa',
      'address': 'A Famosa Resort, 78000 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Resort Villa',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park', 'Golf Course', 'Water Park', 'Family Fun']
    },
    {
      'id': 74,
      'name': 'Mahkota Parade Apartment',
      'address': 'Mahkota Parade, 75000 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 100.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'Beach Access', 'Entertainment']
    },
    {
      'id': 75,
      'name': 'Dutch Square Studio',
      'address': 'Dutch Square, 75000 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Historic Center', 'Museums', 'Red Square View']
    },
    {
      'id': 76,
      'name': 'Ayer Keroh Country Resort',
      'address': 'Ayer Keroh, 75450 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Country Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Nature Setting', 'Zoo Access', 'Recreation Park']
    },
    {
      'id': 77,
      'name': 'Klebang Beach Suite',
      'address': 'Klebang, 75200 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 3.7,
      'price': 90.0,
      'currency': 'MYR',
      'type': 'Beach Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Coconut Shake', 'Sea Breeze']
    },
    {
      'id': 78,
      'name': 'Bukit Beruang Budget Hotel',
      'address': 'Bukit Beruang, 75450 Melaka',
      'city': 'Melaka',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 48.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Student Area', 'Affordable Dining', 'University Access']
    },

    // IPOH (7 properties)
    {
      'id': 79,
      'name': 'The Banjaran Hotsprings Retreat',
      'address': 'Tambun, 31400 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 420.0,
      'currency': 'MYR',
      'type': 'Luxury Spa Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Natural Hot Springs', 'Spa Caves', 'Fine Dining', 'Wellness']
    },
    {
      'id': 80,
      'name': 'Old Town White Coffee Lodge',
      'address': 'Old Town, 31000 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 3.6,
      'price': 68.0,
      'currency': 'MYR',
      'type': 'Heritage Lodge',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Architecture', 'White Coffee', 'Walking Distance']
    },
    {
      'id': 81,
      'name': 'Kinta Riverfront Apartment',
      'address': 'Greentown, 30450 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 110.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'River View', 'City Access', 'Full Kitchen']
    },
    {
      'id': 82,
      'name': 'Lost World of Tambun Resort',
      'address': 'Tambun, 31400 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Theme Park Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Access', 'Hot Springs', 'Water Park', 'Adventure']
    },
    {
      'id': 83,
      'name': 'Ipoh Garden Budget Hotel',
      'address': 'Ipoh Garden, 31400 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 3.1,
      'price': 42.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Garden Setting', 'Local Eateries', 'Value Stay']
    },
    {
      'id': 84,
      'name': 'Perak Cave Temple Studio',
      'address': 'Gunung Rapat, 31350 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 85.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Cave Temples', 'Limestone Hills', 'Nature Photography']
    },
    {
      'id': 85,
      'name': 'Polo Ground Luxury Suites',
      'address': 'Polo Ground, 30000 Ipoh, Perak',
      'city': 'Ipoh',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Luxury Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Historic Area', 'Premium Facilities', 'Fine Dining', 'Concierge']
    },

    // CAMERON HIGHLANDS (5 properties)
    {
      'id': 86,
      'name': 'Cameron Highlands Resort',
      'address': 'Tanah Rata, 39000 Cameron Highlands, Pahang',
      'city': 'Cameron Highlands',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 280.0,
      'currency': 'MYR',
      'type': 'Hill Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Colonial Architecture', 'Golf Course', 'Tea Plantation', 'Cool Climate']
    },
    {
      'id': 87,
      'name': 'Strawberry Farm Homestay',
      'address': 'Brinchang, 39100 Cameron Highlands, Pahang',
      'city': 'Cameron Highlands',
      'country': 'Malaysia',
      'rating': 3.9,
      'price': 75.0,
      'currency': 'MYR',
      'type': 'Homestay',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Strawberry Farm', 'Local Experience', 'Mountain View']
    },
    {
      'id': 88,
      'name': 'Tea Valley Budget Inn',
      'address': 'Ringlet, 39200 Cameron Highlands, Pahang',
      'city': 'Cameron Highlands',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 52.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Tea Plantation Views', 'Nature Walks', 'Budget Friendly']
    },
    {
      'id': 89,
      'name': 'Highland Studio Apartment',
      'address': 'Tanah Rata, 39000 Cameron Highlands, Pahang',
      'city': 'Cameron Highlands',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 95.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Highland Views', 'Fireplace', 'Market Access']
    },
    {
      'id': 90,
      'name': 'Mossy Forest Lodge',
      'address': 'Gunung Brinchang, 39100 Cameron Highlands, Pahang',
      'city': 'Cameron Highlands',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Mountain Lodge',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Mossy Forest Access', 'Jungle Trekking', 'Bird Watching', 'Nature Guide']
    },

    // KUCHING (5 properties)
    {
      'id': 91,
      'name': 'Kuching Waterfront Hotel',
      'address': 'Waterfront, 93000 Kuching, Sarawak',
      'city': 'Kuching',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Waterfront Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'River View', 'Night Market', 'Cat Museum Access']
    },
    {
      'id': 92,
      'name': 'Carpenter Street Heritage Inn',
      'address': 'Carpenter Street, 93000 Kuching, Sarawak',
      'city': 'Kuching',
      'country': 'Malaysia',
      'rating': 3.7,
      'price': 70.0,
      'currency': 'MYR',
      'type': 'Heritage Inn',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Street', 'Local Culture', 'Weekend Market']
    },
    {
      'id': 93,
      'name': 'Borneo Highlands Resort',
      'address': 'Padawan, 94200 Kuching, Sarawak',
      'city': 'Kuching',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Highland Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Highland Views', 'Adventure Activities', 'Tree Top Walk', 'Cool Climate']
    },
    {
      'id': 94,
      'name': 'Vivacity Megamall Apartment',
      'address': 'Vivacity, 93350 Kuching, Sarawak',
      'city': 'Kuching',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'Entertainment', 'Modern Facilities']
    },
    {
      'id': 95,
      'name': 'Kuching Budget Central',
      'address': 'Jalan Padungan, 93100 Kuching, Sarawak',
      'city': 'Kuching',
      'country': 'Malaysia',
      'rating': 3.3,
      'price': 45.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Center', 'Food Courts', 'Budget Friendly']
    },

    // GENTING HIGHLANDS (3 properties)
    {
      'id': 96,
      'name': 'Genting Grand Premium Suite',
      'address': 'Genting Highlands, 69000 Pahang',
      'city': 'Genting Highlands',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 250.0,
      'currency': 'MYR',
      'type': 'Premium Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Access', 'Casino', 'Cable Car', 'Entertainment']
    },
    {
      'id': 97,
      'name': 'Highlands Budget Hotel',
      'address': 'Genting Highlands, 69000 Pahang',
      'city': 'Genting Highlands',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 85.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Proximity', 'Cool Weather', 'Basic Amenities']
    },
    {
      'id': 98,
      'name': 'SkyAvenue Luxury Apartment',
      'address': 'SkyAvenue, 69000 Genting Highlands, Pahang',
      'city': 'Genting Highlands',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 320.0,
      'currency': 'MYR',
      'type': 'Luxury Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sky Views', 'Premium Shopping', 'Fine Dining', 'Entertainment Complex']
    },

    // PORT DICKSON (2 properties)
    {
      'id': 99,
      'name': 'Port Dickson Beach Resort',
      'address': 'Teluk Kemang, 71050 Port Dickson, Negeri Sembilan',
      'city': 'Port Dickson',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 130.0,
      'currency': 'MYR',
      'type': 'Beach Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Water Sports', 'Pool', 'Seafood Restaurant']
    },
    {
      'id': 100,
      'name': 'PD Waterfront Studio',
      'address': 'Bandar Port Dickson, 71000 Port Dickson, Negeri Sembilan',
      'city': 'Port Dickson',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 75.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sea View', 'Weekend Getaway', 'Fishing Village']
    }
  ];

  static Future<List<Hotel>> searchHotels({String? destination, String? type, double? minPrice, double? maxPrice}) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500));

    List<Map<String, dynamic>> filteredHotels = _mockHotels;

    if (destination != null && destination.isNotEmpty) {
      String searchTerm = destination.toLowerCase();
      filteredHotels = filteredHotels.where((hotel) {
        return hotel['city'].toString().toLowerCase().contains(searchTerm) ||
            hotel['country'].toString().toLowerCase().contains(searchTerm) ||
            hotel['name'].toString().toLowerCase().contains(searchTerm);
      }).toList();
    }

    if (type != null && type.isNotEmpty) {
      String searchType = type.toLowerCase();
      filteredHotels = filteredHotels.where((hotel) {
        return hotel['type'].toString().toLowerCase().contains(searchType);
      }).toList();
    }

    if (minPrice != null) {
      filteredHotels = filteredHotels.where((hotel) {
        return hotel['price'] >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      filteredHotels = filteredHotels.where((hotel) {
        return hotel['price'] <= maxPrice;
      }).toList();
    }

    return filteredHotels.map((json) => Hotel.fromJson(json)).toList();
  }

  static Future<Hotel?> getHotelById(int id) async {
    await Future.delayed(Duration(milliseconds: 500));

    try {
      final hotelData = _mockHotels.firstWhere((hotel) => hotel['id'] == id);
      return Hotel.fromJson(hotelData);
    } catch (e) {
      return null;
    }
  }

  static List<String> getPopularDestinations() {
    return [
      'Kuala Lumpur', 'George Town', 'Langkawi', 'Johor Bahru',
      'Kota Kinabalu', 'Melaka', 'Ipoh', 'Cameron Highlands',
      'Kuching', 'Genting Highlands', 'Port Dickson'
    ];
  }

  static List<String> getAccommodationTypes() {
    return [
      'Budget Hotel', 'Mid-Range Hotel', 'Luxury Hotel', 'Suite',
      'Studio', 'Apartment', 'Resort', 'Villa', 'Heritage Hotel'
    ];
  }

  static Map<String, int> getHotelStats() {
    return {
      'totalHotels': _mockHotels.length,
      'budgetHotels': _mockHotels.where((h) => h['price'] < 80.0).length,
      'midRangeHotels': _mockHotels.where((h) => h['price'] >= 80.0 && h['price'] < 200.0).length,
      'luxuryHotels': _mockHotels.where((h) => h['price'] >= 200.0).length,
      'cities': getPopularDestinations().length,
    };
  }
}