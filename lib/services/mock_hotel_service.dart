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
      'price': 280.0, // Base price (lowest room type)
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Gym', 'Spa', 'Fine Dining', 'City View', 'Concierge'],
      'roomTypes': [
        {
          'name': 'Superior Room',
          'price': 280.0,
          'quantity': 45,
          'description': 'Elegant room with city view and modern amenities'
        },
        {
          'name': 'Deluxe Room',
          'price': 320.0,
          'quantity': 38,
          'description': 'Spacious room with KLCC view and premium facilities'
        },
        {
          'name': 'Executive Suite',
          'price': 450.0,
          'quantity': 22,
          'description': 'Luxurious suite with separate living area and Twin Towers view'
        },
        {
          'name': 'Presidential Suite',
          'price': 850.0,
          'quantity': 8,
          'description': 'Ultimate luxury with panoramic city views and butler service'
        }
      ]
    },
    {
      'id': 2,
      'name': 'Budget Inn KL Central',
      'address': 'Jalan Sultan, 50000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 35.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Air Conditioning', '24/7 Reception'],
      'roomTypes': [
        {
          'name': 'Standard Single',
          'price': 35.0,
          'quantity': 25,
          'description': 'Basic single room with essential amenities'
        },
        {
          'name': 'Standard Double',
          'price': 45.0,
          'quantity': 30,
          'description': 'Comfortable double room for two guests'
        },
        {
          'name': 'Family Room',
          'price': 65.0,
          'quantity': 15,
          'description': 'Spacious room accommodating up to 4 guests'
        }
      ]
    },
    {
      'id': 3,
      'name': 'Bukit Bintang Suites',
      'address': 'Bukit Bintang, 55100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 150.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Kitchen', 'Pool', 'Gym', 'Shopping Access'],
      'roomTypes': [
        {
          'name': 'Junior Suite',
          'price': 150.0,
          'quantity': 20,
          'description': 'Compact suite with kitchenette and living area'
        },
        {
          'name': 'One Bedroom Suite',
          'price': 180.0,
          'quantity': 25,
          'description': 'Separate bedroom with full kitchen and dining area'
        },
        {
          'name': 'Executive Suite',
          'price': 220.0,
          'quantity': 18,
          'description': 'Premium suite with shopping mall access'
        },
        {
          'name': 'Penthouse Suite',
          'price': 350.0,
          'quantity': 8,
          'description': 'Luxury penthouse with panoramic city views'
        }
      ]
    },
    {
      "id": 4,
      "name": "Cameron Highlands Retreat",
      "address": "Tanah Rata, 39000 Cameron Highlands",
      "city": "Cameron Highlands",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 180.0,
      "currency": "MYR",
      "type": "Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1560347876-aeef00ee58a1?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Mountain View", "Garden", "Breakfast Included"],
      "roomTypes": [
        {
          "name": "Deluxe Room",
          "price": 180.0,
          "quantity": 20,
          "description": "Spacious room with balcony overlooking the tea plantations"
        },
        {
          "name": "Family Suite",
          "price": 250.0,
          "quantity": 10,
          "description": "2-bedroom suite perfect for families, with garden view"
        }
      ]
    },
    {
      "id": 5,
      "name": "Genting Highlands Suites",
      "address": "Resorts World Genting, 69000 Genting Highlands",
      "city": "Genting Highlands",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 190.0,
      "currency": "MYR",
      "type": "Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Casino Access", "Indoor Pool", "Fitness Center", "Theme Park Nearby"],
      "roomTypes": [
        {
          "name": "Superior Room",
          "price": 190.0,
          "quantity": 50,
          "description": "Comfortable room with mountain view and easy access to entertainment areas"
        },
        {
          "name": "Premier Suite",
          "price": 250.0,
          "quantity": 30,
          "description": "Spacious suite with separate living area and panoramic highland views"
        },
        {
          "name": "Family Suite",
          "price": 320.0,
          "quantity": 15,
          "description": "Large family-friendly suite with 2 bedrooms and 2 bathrooms"
        }
      ]
    },
    {
      "id": 6,
      "name": "Ipoh Garden Hotel",
      "address": "Jalan Sultan Azlan Shah, 31400 Ipoh",
      "city": "Ipoh",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 160.0,
      "currency": "MYR",
      "type": "Mid-Range Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Pool", "Restaurant", "Free Parking", "Conference Facilities"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 160.0,
          "quantity": 50,
          "description": "Comfortable room with modern amenities, close to Ipoh’s famous food streets"
        },
        {
          "name": "Deluxe Room",
          "price": 190.0,
          "quantity": 40,
          "description": "Spacious room with city or garden view and premium bedding"
        },
        {
          "name": "Executive Suite",
          "price": 270.0,
          "quantity": 20,
          "description": "Luxury suite with separate living area and workspace"
        }
      ]
    },
    {
      'id': 7,
      'name': 'Chinatown Heritage Inn',
      'address': 'Petaling Street, 50000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.5,
      'price': 55.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Design', 'Street Food Access'],
      'roomTypes': [
        {
          'name': 'Heritage Single',
          'price': 55.0,
          'quantity': 18,
          'description': 'Traditional style single room with heritage decor'
        },
        {
          'name': 'Heritage Double',
          'price': 65.0,
          'quantity': 22,
          'description': 'Double room with authentic Chinese design elements'
        },
        {
          'name': 'Family Heritage',
          'price': 85.0,
          'quantity': 12,
          'description': 'Spacious family room with traditional furnishings'
        }
      ]
    },
    {
      'id': 8,
      'name': 'KLCC Luxury Residence',
      'address': 'Jalan Ampang, 50450 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 320.0,
      'currency': 'MYR',
      'type': 'Luxury Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Private Balcony', 'Concierge', 'Spa', 'Fine Dining'],
      'roomTypes': [
        {
          'name': 'Luxury Suite',
          'price': 320.0,
          'quantity': 30,
          'description': 'Elegant suite with private balcony and KLCC view'
        },
        {
          'name': 'Premium Suite',
          'price': 380.0,
          'quantity': 25,
          'description': 'Upgraded suite with enhanced amenities and spa access'
        },
        {
          'name': 'Royal Suite',
          'price': 550.0,
          'quantity': 15,
          'description': 'Ultimate luxury with personal butler and fine dining'
        },
        {
          'name': 'Presidential Residence',
          'price': 950.0,
          'quantity': 5,
          'description': 'Exclusive residence with private lift and concierge'
        }
      ]
    },
    {
      'id': 9,
      'name': 'Sentul Park Hotel',
      'address': 'Jalan Sentul, 51000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 75.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Restaurant', 'Park View'],
      'roomTypes': [
        {
          'name': 'Standard Room',
          'price': 75.0,
          'quantity': 35,
          'description': 'Comfortable room with park view'
        },
        {
          'name': 'Superior Room',
          'price': 85.0,
          'quantity': 28,
          'description': 'Enhanced room with better park views'
        },
        {
          'name': 'Family Room',
          'price': 110.0,
          'quantity': 20,
          'description': 'Spacious room for families with park access'
        }
      ]
    },
    {
      'id': 10,
      'name': 'Bangsar Studio Loft',
      'address': 'Bangsar, 59100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Modern Design', 'Kitchenette', 'Cafe Access'],
      'roomTypes': [
        {
          'name': 'Modern Studio',
          'price': 120.0,
          'quantity': 25,
          'description': '1 open-plan room with contemporary design and kitchenette'
        },
        {
          'name': 'Loft Studio',
          'price': 140.0,
          'quantity': 20,
          'description': '1 spacious loft-style room with high ceilings'
        },
        {
          'name': 'Premium Loft',
          'price': 170.0,
          'quantity': 15,
          'description': '1 luxury loft with premium finishes and cafe access'
        }
      ]
    },
    {
      'id': 11,
      'name': 'Ampang Point Suites',
      'address': 'Ampang, 68000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Separate Living Room', 'Pool', 'Parking'],
      'roomTypes': [
        {
          'name': 'Junior Suite',
          'price': 140.0,
          'quantity': 30,
          'description': 'Compact suite with separate living area'
        },
        {
          'name': 'Executive Suite',
          'price': 160.0,
          'quantity': 25,
          'description': 'Spacious suite with enhanced amenities'
        },
        {
          'name': 'Premium Suite',
          'price': 200.0,
          'quantity': 18,
          'description': 'Large suite with premium facilities and parking'
        }
      ]
    },
    {
      'id': 12,
      'name': 'KL Express Hotel',
      'address': 'Jalan Tun Razak, 50400 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.3,
      'price': 45.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Express Check-in', 'Vending Machine'],
      'roomTypes': [
        {
          'name': 'Express Single',
          'price': 45.0,
          'quantity': 40,
          'description': 'Compact single room with express services'
        },
        {
          'name': 'Express Double',
          'price': 55.0,
          'quantity': 35,
          'description': 'Efficient double room for quick stays'
        }
      ]
    },
    {
      'id': 13,
      'name': 'Mont Kiara Luxury Apartment',
      'address': 'Mont Kiara, 50480 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Multiple Bedrooms', 'Pool', 'Gym', 'Security'],
      'roomTypes': [
        {
          'name': 'Two Bedroom Apartment',
          'price': 180.0,
          'quantity': 25,
          'description': '2 bedrooms, 2 bathrooms with modern amenities'
        },
        {
          'name': 'Three Bedroom Apartment',
          'price': 220.0,
          'quantity': 20,
          'description': '3 bedrooms, 2 bathrooms with luxury finishes'
        },
        {
          'name': 'Four Bedroom Penthouse',
          'price': 320.0,
          'quantity': 12,
          'description': '4 bedrooms, 3 bathrooms with panoramic views'
        }
      ]
    },
    {
      'id': 14,
      'name': 'Pavilion Elite Hotel',
      'address': 'Jalan Bukit Bintang, 55100 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 250.0,
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Luxury Shopping', 'Spa', 'Fine Dining', 'Butler Service'],
      'roomTypes': [
        {
          'name': 'Elite Room',
          'price': 250.0,
          'quantity': 40,
          'description': 'Luxury room with shopping mall access'
        },
        {
          'name': 'Elite Suite',
          'price': 280.0,
          'quantity': 30,
          'description': 'Spacious suite with spa and fine dining access'
        },
        {
          'name': 'Executive Suite',
          'price': 380.0,
          'quantity': 20,
          'description': 'Premium suite with butler service'
        },
        {
          'name': 'Presidential Suite',
          'price': 650.0,
          'quantity': 8,
          'description': 'Ultimate luxury with personal shopping and dining'
        }
      ]
    },
    {
      'id': 15,
      'name': 'Wangsa Maju Budget Inn',
      'address': 'Wangsa Maju, 53300 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.1,
      'price': 35.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Basic Amenities', 'Parking'],
      'roomTypes': [
        {
          'name': 'Basic Single',
          'price': 35.0,
          'quantity': 25,
          'description': 'Simple single room with essential amenities'
        },
        {
          'name': 'Basic Double',
          'price': 40.0,
          'quantity': 20,
          'description': 'Budget-friendly double room with parking'
        }
      ]
    },
    {
      'id': 16,
      'name': 'Damansara Heights Studio',
      'address': 'Damansara Heights, 50490 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 110.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Hill View', 'Kitchenette', 'Quiet Area'],
      'roomTypes': [
        {
          'name': 'Hill View Studio',
          'price': 110.0,
          'quantity': 30,
          'description': '1 open-plan room with hill views and kitchenette'
        },
        {
          'name': 'Premium Hill Studio',
          'price': 130.0,
          'quantity': 20,
          'description': '1 spacious studio with panoramic hill views'
        }
      ]
    },
    {
      'id': 17,
      'name': 'Setapak Central Hotel',
      'address': 'Setapak, 53300 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.7,
      'price': 65.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Restaurant', 'Meeting Room', 'Parking'],
      'roomTypes': [
        {
          'name': 'Standard Room',
          'price': 65.0,
          'quantity': 35,
          'description': 'Comfortable room with basic amenities'
        },
        {
          'name': 'Business Room',
          'price': 75.0,
          'quantity': 25,
          'description': 'Room with work desk and meeting room access'
        },
        {
          'name': 'Executive Room',
          'price': 95.0,
          'quantity': 18,
          'description': 'Enhanced room with premium facilities'
        }
      ]
    },
    {
      'id': 18,
      'name': 'TTDI Premium Suites',
      'address': 'Taman Tun Dr Ismail, 60000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 160.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Spacious Living', 'Pool', 'Garden View'],
      'roomTypes': [
        {
          'name': 'Garden Suite',
          'price': 160.0,
          'quantity': 25,
          'description': 'Suite with garden views and spacious living area'
        },
        {
          'name': 'Premium Suite',
          'price': 190.0,
          'quantity': 20,
          'description': 'Enhanced suite with premium garden views'
        },
        {
          'name': 'Executive Suite',
          'price': 230.0,
          'quantity': 15,
          'description': 'Luxury suite with private garden access'
        }
      ]
    },
    {
      'id': 19,
      'name': 'Cheras Business Hotel',
      'address': 'Cheras, 56000 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.6,
      'price': 60.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Business Center', 'Restaurant', 'Conference Room'],
      'roomTypes': [
        {
          'name': 'Standard Room',
          'price': 60.0,
          'quantity': 40,
          'description': 'Basic business room with work facilities'
        },
        {
          'name': 'Business Room',
          'price': 70.0,
          'quantity': 30,
          'description': 'Enhanced room with business center access'
        },
        {
          'name': 'Conference Suite',
          'price': 95.0,
          'quantity': 15,
          'description': 'Suite with conference room and meeting facilities'
        }
      ]
    },
    {
      'id': 20,
      'name': 'KL City Center Apartment',
      'address': 'Jalan Raja Laut, 50350 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 140.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Access', 'Full Kitchen', 'Balcony'],
      'roomTypes': [
        {
          'name': 'One Bedroom Apartment',
          'price': 140.0,
          'quantity': 28,
          'description': '1 bedroom, 1 bathroom with city access and balcony'
        },
        {
          'name': 'Two Bedroom Apartment',
          'price': 170.0,
          'quantity': 22,
          'description': '2 bedrooms, 1 bathroom with full kitchen'
        },
        {
          'name': 'Three Bedroom Apartment',
          'price': 220.0,
          'quantity': 15,
          'description': '3 bedrooms, 2 bathrooms with panoramic city views'
        }
      ]
    },
    {
      'id': 21,
      'name': 'Sunway Pyramid Hotel',
      'address': 'Sunway City, 47500 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 180.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Theme Park Access', 'Pool', 'Mall Connection'],
      'roomTypes': [
        {
          'name': 'Standard Room',
          'price': 180.0,
          'quantity': 35,
          'description': 'Comfortable room with theme park access'
        },
        {
          'name': 'Theme Park View',
          'price': 210.0,
          'quantity': 30,
          'description': 'Room with theme park views and mall connection'
        },
        {
          'name': 'Family Suite',
          'price': 280.0,
          'quantity': 20,
          'description': 'Spacious suite perfect for families with theme park access'
        },
        {
          'name': 'Executive Suite',
          'price': 350.0,
          'quantity': 12,
          'description': 'Premium suite with exclusive park and mall privileges'
        }
      ]
    },
    {
      'id': 22,
      'name': 'Old Town White Coffee Inn',
      'address': 'Jalan Alor, 50200 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 50.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Food Street Access', 'Local Experience'],
      'roomTypes': [
        {
          'name': 'Local Single',
          'price': 50.0,
          'quantity': 20,
          'description': 'Authentic single room with food street access'
        },
        {
          'name': 'Local Double',
          'price': 60.0,
          'quantity': 25,
          'description': 'Traditional double room with local experience'
        },
        {
          'name': 'Heritage Room',
          'price': 75.0,
          'quantity': 15,
          'description': 'Enhanced room with heritage design and coffee culture'
        }
      ]
    },
    {
      'id': 23,
      'name': 'Tropicana Studio Residence',
      'address': 'Tropicana, 47410 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 105.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Golf Course View', 'Pool', 'Gym'],
      'roomTypes': [
        {
          'name': 'Golf View Studio',
          'price': 105.0,
          'quantity': 25,
          'description': '1 open-plan room with golf course views'
        },
        {
          'name': 'Premium Golf Studio',
          'price': 125.0,
          'quantity': 20,
          'description': '1 spacious studio with panoramic golf course views'
        }
      ]
    },
    {
      'id': 24,
      'name': 'Brickfields Little India Hotel',
      'address': 'Brickfields, 50470 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 3.5,
      'price': 55.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Cultural District', 'Indian Restaurants'],
      'roomTypes': [
        {
          'name': 'Cultural Single',
          'price': 55.0,
          'quantity': 18,
          'description': 'Traditional single room in cultural district'
        },
        {
          'name': 'Cultural Double',
          'price': 65.0,
          'quantity': 22,
          'description': 'Double room with access to Indian restaurants'
        },
        {
          'name': 'Heritage Family',
          'price': 85.0,
          'quantity': 12,
          'description': 'Family room with cultural heritage experience'
        }
      ]
    },
    {
      'id': 25,
      'name': 'The Face Platinum Suites',
      'address': 'Jalan Sultan Ismail, 50250 Kuala Lumpur',
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 300.0,
      'currency': 'MYR',
      'type': 'Luxury Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Platinum Service', 'Sky Pool', 'Private Butler', 'City Panorama'],
      'roomTypes': [
        {
          'name': 'Platinum Suite',
          'price': 300.0,
          'quantity': 25,
          'description': 'Luxury suite with sky pool and platinum service'
        },
        {
          'name': 'Executive Platinum',
          'price': 350.0,
          'quantity': 20,
          'description': 'Enhanced suite with private butler and city panorama'
        },
        {
          'name': 'Presidential Platinum',
          'price': 500.0,
          'quantity': 12,
          'description': 'Ultimate luxury with exclusive platinum privileges'
        },
        {
          'name': 'Royal Platinum',
          'price': 800.0,
          'quantity': 6,
          'description': 'Royal treatment with personalized platinum services'
        }
      ]
    },

    // PENANG (15 properties)
    {
      'id': 26,
      'name': 'George Town Heritage Hotel',
      'address': 'Armenian Street, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 150.0,
      'currency': 'MYR',
      'type': 'Heritage Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Heritage Design', 'UNESCO Area', 'Cultural Tours'],
      'roomTypes': [
        {
          'name': 'Heritage Room',
          'price': 150.0,
          'quantity': 30,
          'description': 'Traditional room with heritage design in UNESCO area'
        },
        {
          'name': 'Colonial Suite',
          'price': 180.0,
          'quantity': 25,
          'description': 'Suite with colonial architecture and cultural tours'
        },
        {
          'name': 'Premium Heritage',
          'price': 220.0,
          'quantity': 18,
          'description': 'Enhanced heritage room with premium amenities'
        },
        {
          'name': 'Presidential Heritage',
          'price': 320.0,
          'quantity': 10,
          'description': 'Luxury heritage suite with exclusive cultural experiences'
        }
      ]
    },
    {
      'id': 27,
      'name': 'Gurney Plaza Apartment',
      'address': 'Gurney Drive, 10250 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.2,
      'price': 130.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Sea View', 'Mall Access', 'Pool'],
      'roomTypes': [
        {
          'name': 'One Bedroom Apartment',
          'price': 130.0,
          'quantity': 25,
          'description': '1 bedroom, 1 bathroom with sea view and mall access'
        },
        {
          'name': 'Two Bedroom Apartment',
          'price': 160.0,
          'quantity': 20,
          'description': '2 bedrooms, 2 bathrooms with premium sea views'
        },
        {
          'name': 'Three Bedroom Apartment',
          'price': 200.0,
          'quantity': 15,
          'description': '3 bedrooms, 2 bathrooms with panoramic sea views'
        }
      ]
    },
    {
      'id': 28,
      'name': 'Penang Budget Hostel',
      'address': 'Chulia Street, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 3.2,
      'price': 25.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Backpacker Friendly', 'Common Area'],
      'roomTypes': [
        {
          'name': 'Dorm Bed',
          'price': 25.0,
          'quantity': 40,
          'description': 'Shared dormitory bed with common area access'
        },
        {
          'name': 'Private Single',
          'price': 35.0,
          'quantity': 15,
          'description': 'Private single room for backpackers'
        },
        {
          'name': 'Private Double',
          'price': 45.0,
          'quantity': 12,
          'description': 'Private double room with backpacker amenities'
        }
      ]
    },
    {
      'id': 29,
      'name': 'Batu Ferringhi Beach Resort',
      'address': 'Batu Ferringhi, 11100 Penang',
      'city': 'Batu Ferringhi',
      'country': 'Malaysia',
      'rating': 4.6,
      'price': 220.0,
      'currency': 'MYR',
      'type': 'Beach Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Pool', 'Water Sports', 'Spa'],
      'roomTypes': [
        {
          'name': 'Beach View Room',
          'price': 220.0,
          'quantity': 40,
          'description': 'Room with direct beach access and water sports'
        },
        {
          'name': 'Ocean Suite',
          'price': 250.0,
          'quantity': 30,
          'description': 'Suite with ocean views and spa access'
        },
        {
          'name': 'Beach Villa',
          'price': 350.0,
          'quantity': 20,
          'description': 'Private villa with exclusive beach access'
        },
        {
          'name': 'Presidential Villa',
          'price': 550.0,
          'quantity': 8,
          'description': 'Luxury villa with private beach and premium services'
        }
      ]
    },
    {
      'id': 30,
      'name': 'Straits Quay Marina Suites',
      'address': 'Tanjong Tokong, 10470 Penang',
      'city': 'Tanjong Tokong',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 170.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Marina View', 'Yacht Access', 'Fine Dining'],
      'roomTypes': [
        {
          'name': 'Marina Suite',
          'price': 170.0,
          'quantity': 25,
          'description': 'Suite with marina views and yacht access'
        },
        {
          'name': 'Premium Marina',
          'price': 200.0,
          'quantity': 20,
          'description': 'Enhanced suite with fine dining access'
        },
        {
          'name': 'Executive Marina',
          'price': 280.0,
          'quantity': 15,
          'description': 'Luxury suite with exclusive marina privileges'
        }
      ]
    },
    {
      'id': 31,
      'name': 'Penang Hill Studio',
      'address': 'Air Itam, 11500 Penang',
      'city': 'Air Itam',
      'country': 'Malaysia',
      'rating': 3.9,
      'price': 80.0,
      'currency': 'MYR',
      'type': 'Studio',
      'imageUrl': 'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Hill View', 'Cool Climate', 'Nature Access'],
      'roomTypes': [
        {
          'name': 'Hill View Studio',
          'price': 80.0,
          'quantity': 20,
          'description': '1 open-plan room with hill views and cool climate'
        },
        {
          'name': 'Premium Hill Studio',
          'price': 95.0,
          'quantity': 15,
          'description': '1 spacious studio with panoramic hill views'
        }
      ]
    },
    {
      'id': 32,
      'name': 'Queensbay Mall Hotel',
      'address': 'Bayan Lepas, 11900 Penang',
      'city': 'Bayan Lepas',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 120.0,
      'currency': 'MYR',
      'type': 'Mid-Range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Shopping Mall', 'Airport Access', 'Restaurant'],
      'roomTypes': [
        {
          'name': 'Standard Room',
          'price': 120.0,
          'quantity': 35,
          'description': 'Comfortable room with shopping mall access'
        },
        {
          'name': 'Superior Room',
          'price': 140.0,
          'quantity': 25,
          'description': 'Enhanced room with airport access'
        },
        {
          'name': 'Business Room',
          'price': 170.0,
          'quantity': 18,
          'description': 'Business-focused room with premium amenities'
        }
      ]
    },
    {
      'id': 33,
      'name': 'Jelutong Budget Inn',
      'address': 'Jelutong, 11600 Penang',
      'city': 'Jelutong',
      'country': 'Malaysia',
      'rating': 3.1,
      'price': 35.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Local Area', 'Basic Comfort'],
      'roomTypes': [
        {
          'name': 'Basic Single',
          'price': 35.0,
          'quantity': 20,
          'description': 'Simple single room in local area'
        },
        {
          'name': 'Basic Double',
          'price': 42.0,
          'quantity': 18,
          'description': 'Budget double room with basic comfort'
        }
      ]
    },
    {
      'id': 34,
      'name': 'Tanjung Bungah Luxury Villa',
      'address': 'Tanjung Bungah, 11200 Penang',
      'city': 'Tanjung Bungah',
      'country': 'Malaysia',
      'rating': 4.7,
      'price': 280.0,
      'currency': 'MYR',
      'type': 'Luxury Villa',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Private Pool', 'Sea View', 'Butler Service', 'Privacy'],
      'roomTypes': [
        {
          'name': 'Sea View Villa',
          'price': 280.0,
          'quantity': 15,
          'description': 'Private villa with sea views and pool'
        },
        {
          'name': 'Luxury Sea Villa',
          'price': 320.0,
          'quantity': 12,
          'description': 'Enhanced villa with butler service and privacy'
        },
        {
          'name': 'Presidential Villa',
          'price': 480.0,
          'quantity': 8,
          'description': 'Ultimate luxury villa with exclusive services'
        }
      ]
    },
    {
      'id': 35,
      'name': 'Komtar View Apartment',
      'address': 'Jalan Penang, 10000 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 3.8,
      'price': 90.0,
      'currency': 'MYR',
      'type': 'Apartment',
      'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'City Center', 'Transport Hub', 'Shopping'],
      'roomTypes': [
        {
          'name': 'One Bedroom Apartment',
          'price': 90.0,
          'quantity': 22,
          'description': '1 bedroom, 1 bathroom in city center with transport hub'
        },
        {
          'name': 'Two Bedroom Apartment',
          'price': 110.0,
          'quantity': 18,
          'description': '2 bedrooms, 1 bathroom with shopping access'
        }
      ]
    },
    {
      'id': 36,
      'name': 'Tropical Spice Garden Resort',
      'address': 'Lone Pine, 11100 Penang',
      'city': 'Batu Ferringhi',
      'country': 'Malaysia',
      'rating': 4.3,
      'price': 190.0,
      'currency': 'MYR',
      'type': 'Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Spice Garden', 'Nature Tours', 'Spa', 'Restaurant'],
      'roomTypes': [
        {
          'name': 'Garden Room',
          'price': 190.0,
          'quantity': 25,
          'description': 'Room with spice garden access and nature tours'
        },
        {
          'name': 'Spa Garden Suite',
          'price': 220.0,
          'quantity': 20,
          'description': 'Suite with spa access and enhanced garden views'
        },
        {
          'name': 'Premium Garden Villa',
          'price': 280.0,
          'quantity': 15,
          'description': 'Villa with private garden access and exclusive tours'
        }
      ]
    },
    {
      'id': 37,
      'name': 'Butterworth Transit Hotel',
      'address': 'Butterworth, 12300 Penang',
      'city': 'Butterworth',
      'country': 'Malaysia',
      'rating': 3.4,
      'price': 48.0,
      'currency': 'MYR',
      'type': 'Budget Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Ferry Terminal', 'Transit Friendly'],
      'roomTypes': [
        {
          'name': 'Transit Single',
          'price': 48.0,
          'quantity': 25,
          'description': 'Basic single room for ferry travelers'
        },
        {
          'name': 'Transit Double',
          'price': 58.0,
          'quantity': 20,
          'description': 'Double room with ferry terminal access'
        }
      ]
    },
    {
      'id': 38,
      'name': 'Gurney Paragon Suites',
      'address': 'Gurney Drive, 10250 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.5,
      'price': 200.0,
      'currency': 'MYR',
      'type': 'Suite',
      'imageUrl': 'https://images.unsplash.com/photo-1578944032637-f09897c5233d?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Premium Location', 'Sea View', 'Mall Access', 'Pool'],
      'roomTypes': [
        {
          'name': 'Sea View Suite',
          'price': 200.0,
          'quantity': 25,
          'description': 'Suite with sea views and premium location'
        },
        {
          'name': 'Premium Sea Suite',
          'price': 230.0,
          'quantity': 20,
          'description': 'Enhanced suite with mall access and pool'
        },
        {
          'name': 'Executive Sea Suite',
          'price': 280.0,
          'quantity': 15,
          'description': 'Luxury suite with exclusive sea views and amenities'
        }
      ]
    },
    {
      'id': 39,
      'name': 'Balik Pulau Orchard Stay',
      'address': 'Balik Pulau, 11000 Penang',
      'city': 'Balik Pulau',
      'country': 'Malaysia',
      'rating': 4.0,
      'price': 70.0,
      'currency': 'MYR',
      'type': 'Countryside Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Fruit Orchards', 'Rural Experience', 'Nature'],
      'roomTypes': [
        {
          'name': 'Orchard Room',
          'price': 70.0,
          'quantity': 18,
          'description': 'Room with fruit orchard access and rural experience'
        },
        {
          'name': 'Premium Orchard',
          'price': 85.0,
          'quantity': 15,
          'description': 'Enhanced room with better orchard views'
        },
        {
          'name': 'Orchard Suite',
          'price': 110.0,
          'quantity': 12,
          'description': 'Suite with private orchard access and nature tours'
        }
      ]
    },
    {
      'id': 40,
      'name': 'Eastern & Oriental Luxury',
      'address': 'Lebuh Farquhar, 10200 George Town, Penang',
      'city': 'George Town',
      'country': 'Malaysia',
      'rating': 4.9,
      'price': 380.0,
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Colonial Heritage', 'Sea View', 'Fine Dining', 'Spa', 'Butler'],
      'roomTypes': [
        {
          'name': 'Heritage Room',
          'price': 380.0,
          'quantity': 30,
          'description': 'Colonial heritage room with sea view'
        },
        {
          'name': 'Heritage Suite',
          'price': 450.0,
          'quantity': 25,
          'description': 'Suite with colonial design and fine dining access'
        },
        {
          'name': 'Executive Heritage',
          'price': 580.0,
          'quantity': 18,
          'description': 'Luxury heritage suite with spa and butler service'
        },
        {
          'name': 'Presidential Heritage',
          'price': 850.0,
          'quantity': 8,
          'description': 'Ultimate colonial luxury with exclusive heritage privileges'
        }
      ]
    },
    {
      'id': 41,
      'name': 'Pantai Cenang Beach Resort',
      'address': 'Pantai Cenang, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.4,
      'price': 150.0,
      'currency': 'MYR',
      'type': 'Beach Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Beach Access', 'Pool', 'Water Sports', 'Restaurant'],
      'roomTypes': [
        {
          'name': 'Beach View Room',
          'price': 150.0,
          'quantity': 35,
          'description': 'Room with direct beach access and water sports'
        },
        {
          'name': 'Ocean Suite',
          'price': 180.0,
          'quantity': 25,
          'description': 'Suite with enhanced ocean views and pool access'
        },
        {
          'name': 'Beach Villa',
          'price': 250.0,
          'quantity': 18,
          'description': 'Private villa with exclusive beach access'
        },
        {
          'name': 'Presidential Beach Villa',
          'price': 380.0,
          'quantity': 10,
          'description': 'Luxury villa with private beach and premium services'
        }
      ]
    },
    {
      'id': 42,
      'name': 'Datai Bay Luxury Resort',
      'address': 'Datai Bay, 07000 Langkawi, Kedah',
      'city': 'Langkawi',
      'country': 'Malaysia',
      'rating': 4.8,
      'price': 420.0,
      'currency': 'MYR',
      'type': 'Luxury Resort',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Rainforest', 'Private Beach', 'Spa', 'Golf', 'Fine Dining'],
      'roomTypes': [
        {
          'name': 'Rainforest Room',
          'price': 420.0,
          'quantity': 25,
          'description': 'Room surrounded by rainforest with private beach access'
        },
        {
          'name': 'Rainforest Suite',
          'price': 480.0,
          'quantity': 20,
          'description': 'Suite with enhanced rainforest views and spa access'
        },
        {
          'name': 'Beach Villa',
          'price': 650.0,
          'quantity': 15,
          'description': 'Private villa with golf access and fine dining'
        },
        {
          'name': 'Presidential Villa',
          'price': 950.0,
          'quantity': 8,
          'description': 'Ultimate luxury with exclusive rainforest and beach access'
        }
      ]
    },
    {
      'id': 43,
      'name': 'The Majestic Malacca',
      'address': '188, Jln. Bunga Raya, Pengkalan Rama, 75100 Malacca',
      'city': 'Malacca',
      'country': 'Malaysia',
      'rating': 4.9,
      'price': 550.0, // Base price (lowest room type)
      'currency': 'MYR',
      'type': 'Luxury Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Pool', 'Gym', 'Spa', 'Fine Dining', 'City View', 'Concierge'],
      'roomTypes': [
        {
          'name': 'Superior Room',
          'price': 550.0,
          'quantity': 20,
          'description': 'Elegant room with city view and modern amenities'
        },
        {
          'name': 'Deluxe Room',
          'price': 740.0,
          'quantity': 30,
          'description': 'Spacious room with good view and premium facilities'
        },
        {
          'name': 'Executive Suite',
          'price': 1120.0,
          'quantity': 5,
          'description': 'Luxurious suite with separate living area and good view'
        },
        {
          'name': 'Presidential Suite',
          'price': 1890.0,
          'quantity': 5,
          'description': 'Ultimate luxury with panoramic city views and butler service'
        }
      ]
    },
    {
      'id': 44,
      'name': 'Swiss Garden Hotel Malacca',
      'address': 'T2-4, The Shore @ Melaka River, Jalan Persisiran Bunga Raya, 75300 Malacca',
      'city': 'Malacca',
      'country': 'Malaysia',
      'rating': 4.1,
      'price': 330.0, // Base price (lowest room type)
      'currency': 'MYR',
      'type': 'Mid-range Hotel',
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      'amenities': ['WiFi', 'Rooftop Pool', 'Gym', 'Bar', 'Sport Facilities'],
      'roomTypes': [
        {
          'name': 'Superior Room',
          'price': 330.0,
          'quantity': 45,
          'description': 'Elegant room with modern amenities'
        },
        {
          'name': 'Deluxe Room',
          'price': 450.0,
          'quantity': 38,
          'description': 'Spacious room with premium facilities'
        },
        {
          'name': 'Family Room',
          'price': 640.0,
          'quantity': 22,
          'description': 'Suitable for family to stay together'
        }
      ]
    },
    {
      "id": 45,
      "name": "Seaside Bay Resort",
      "address": "Jalan Tun Fuad Stephens, 88000 Kota Kinabalu",
      "city": "Kota Kinabalu",
      "country": "Malaysia",
      "rating": 4.5,
      "price": 320.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Spa", "Infinity Pool", "Restaurant"],
      "roomTypes": [
        {
          "name": "Deluxe Sea View Room",
          "price": 320.0,
          "quantity": 30,
          "description": "Luxury room with private balcony and ocean views"
        },
        {
          "name": "Premier Suite",
          "price": 450.0,
          "quantity": 15,
          "description": "Spacious suite with separate living area and beachfront access"
        }
      ]
    },
    {
      "id": 46,
      "name": "Kinabalu Mountain View Hotel",
      "address": "Jalan Signal Hill, 88300 Kota Kinabalu",
      "city": "Kota Kinabalu",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 210.0,
      "currency": "MYR",
      "type": "Boutique Hotel",
      'imageUrl': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop',
      "amenities": ["WiFi", "Free Breakfast", "Mountain View", "Cafe", "Shuttle Service"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 210.0,
          "quantity": 40,
          "description": "Comfortable room with view of Signal Hill"
        },
        {
          "name": "Family Room",
          "price": 280.0,
          "quantity": 20,
          "description": "Large family-friendly room with extra bedding options"
        }
      ]
    },
    {
      "id": 47,
      "name": "Harbor Lights Hotel",
      "address": "Jalan Tun Razak, 88400 Kota Kinabalu",
      "city": "Kota Kinabalu",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 270.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Sky Bar", "Pool", "Restaurant", "Business Center"],
      "roomTypes": [
        {
          "name": "Executive Room",
          "price": 270.0,
          "quantity": 45,
          "description": "Elegant room with harbor views and executive lounge access"
        },
        {
          "name": "Presidential Suite",
          "price": 600.0,
          "quantity": 5,
          "description": "Luxurious suite with panoramic harbor view and personalized service"
        }
      ]
    },
    {
      "id": 48,
      "name": "Tunku Abdul Rahman Island Retreat",
      "address": "Pulau Manukan, 88000 Kota Kinabalu",
      "city": "Kota Kinabalu",
      "country": "Malaysia",
      "rating": 4.7,
      "price": 520.0,
      "currency": "MYR",
      "type": "Island Resort",
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      "amenities": ["WiFi", "Private Beach", "Snorkeling", "Spa", "Restaurant"],
      "roomTypes": [
        {
          "name": "Beach Chalet",
          "price": 520.0,
          "quantity": 12,
          "description": "Private wooden chalet steps from the beach with full sea view"
        },
        {
          "name": "Luxury Villa",
          "price": 750.0,
          "quantity": 6,
          "description": "Secluded villa with plunge pool and exclusive butler service"
        }
      ]
    },
    {
      "id": 49,
      "name": "Kota Kinabalu Urban Suites",
      "address": "Imago Shopping Mall, Jalan Coastal, 88100 Kota Kinabalu",
      "city": "Kota Kinabalu",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 250.0,
      "currency": "MYR",
      "type": "Serviced Apartment",
      'imageUrl': 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop',
      "amenities": ["WiFi", "Kitchenette", "Pool", "Gym", "Direct Mall Access"],
      "roomTypes": [
        {
          "name": "One Bedroom Suite",
          "price": 250.0,
          "quantity": 30,
          "description": "Modern serviced apartment with kitchenette and city view"
        },
        {
          "name": "Two Bedroom Family Suite",
          "price": 320.0,
          "quantity": 20,
          "description": "Spacious suite ideal for families with full kitchen and dining area"
        }
      ]
    },
    {
      "id": 50,
      "name": "Riverside Kuching Hotel",
      "address": "Jalan Tunku Abdul Rahman, 93100 Kuching",
      "city": "Kuching",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 180.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "River View", "Pool", "Restaurant", "Business Center"],
      "roomTypes": [
        {
          "name": "Superior Room",
          "price": 180.0,
          "quantity": 40,
          "description": "Modern room with a stunning view of the Sarawak River"
        },
        {
          "name": "Executive Suite",
          "price": 280.0,
          "quantity": 15,
          "description": "Spacious suite with separate living area and premium facilities"
        }
      ]
    },
    {
      "id": 51,
      "name": "Borneo Heritage Hotel",
      "address": "Jalan Padungan, 93100 Kuching",
      "city": "Kuching",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 150.0,
      "currency": "MYR",
      "type": "Boutique Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Cultural Tours", "Airport Shuttle"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 150.0,
          "quantity": 35,
          "description": "Comfortable room inspired by Sarawak cultural motifs"
        },
        {
          "name": "Family Room",
          "price": 220.0,
          "quantity": 10,
          "description": "Larger room suitable for families or small groups"
        }
      ]
    },
    {
      "id": 52,
      "name": "Kuching Garden Suites",
      "address": "Jalan Central Timur, 93300 Kuching",
      "city": "Kuching",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 200.0,
      "currency": "MYR",
      "type": "Serviced Apartment",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Kitchenette", "Gym", "Pool", "Free Parking"],
      "roomTypes": [
        {
          "name": "One Bedroom Apartment",
          "price": 200.0,
          "quantity": 25,
          "description": "Comfortable apartment with full kitchen and city view"
        },
        {
          "name": "Two Bedroom Suite",
          "price": 280.0,
          "quantity": 15,
          "description": "Spacious two-bedroom unit perfect for families"
        }
      ]
    },
    {
      "id": 53,
      "name": "Santubong Beach Resort",
      "address": "Santubong Peninsula, 93050 Kuching",
      "city": "Kuching",
      "country": "Malaysia",
      "rating": 4.5,
      "price": 350.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Spa", "Pool", "Restaurant"],
      "roomTypes": [
        {
          "name": "Beach Chalet",
          "price": 350.0,
          "quantity": 20,
          "description": "Traditional wooden chalet facing the South China Sea"
        },
        {
          "name": "Luxury Villa",
          "price": 500.0,
          "quantity": 10,
          "description": "Spacious villa with private pool and panoramic sea view"
        }
      ]
    },
    {
      "id": 54,
      "name": "Sibu City Hotel",
      "address": "Jalan Kampung Nyabor, 96000 Sibu",
      "city": "Sibu",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 160.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Free Parking", "Conference Facilities"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 160.0,
          "quantity": 50,
          "description": "Simple, clean, and convenient for business or leisure travelers"
        },
        {
          "name": "Deluxe Room",
          "price": 200.0,
          "quantity": 20,
          "description": "Larger room with comfortable bedding and work desk"
        }
      ]
    },
    {
      "id": 55,
      "name": "Rajang Waterfront Hotel",
      "address": "Jalan Wharf, 96000 Sibu",
      "city": "Sibu",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 190.0,
      "currency": "MYR",
      "type": "Waterfront Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "River View", "Sky Lounge", "Restaurant"],
      "roomTypes": [
        {
          "name": "Superior Room",
          "price": 190.0,
          "quantity": 35,
          "description": "Room with a view of the Rajang River and modern facilities"
        },
        {
          "name": "Executive Suite",
          "price": 280.0,
          "quantity": 10,
          "description": "Spacious suite with private balcony and lounge access"
        }
      ]
    },
    {
      "id": 56,
      "name": "Sibu Heritage Inn",
      "address": "Jalan Wong Nai Siong, 96000 Sibu",
      "city": "Sibu",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 140.0,
      "currency": "MYR",
      "type": "Budget Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Laundry Service", "Heritage Decor"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 140.0,
          "quantity": 40,
          "description": "Comfortable room designed with local Sarawakian decor elements"
        },
        {
          "name": "Family Room",
          "price": 190.0,
          "quantity": 15,
          "description": "Larger room suitable for families, with extra amenities"
        }
      ]
    },
    {
      "id": 57,
      "name": "Central Park Suites Sibu",
      "address": "Jalan Alan, 96000 Sibu",
      "city": "Sibu",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 220.0,
      "currency": "MYR",
      "type": "Serviced Apartment",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Kitchenette", "Pool", "Gym", "Free Parking"],
      "roomTypes": [
        {
          "name": "One Bedroom Suite",
          "price": 220.0,
          "quantity": 25,
          "description": "Comfortable serviced suite with full kitchen and living area"
        },
        {
          "name": "Two Bedroom Family Suite",
          "price": 300.0,
          "quantity": 12,
          "description": "Perfect for families, with spacious living and dining areas"
        }
      ]
    },
    {
      "id": 58,
      "name": "Johor Bahru Central Hotel",
      "address": "Jalan Wong Ah Fook, 80000 Johor Bahru",
      "city": "Johor Bahru",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 190.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Gym", "Pool", "Meeting Rooms"],
      "roomTypes": [
        {
          "name": "Deluxe Room",
          "price": 190.0,
          "quantity": 40,
          "description": "Modern room with city skyline view"
        },
        {
          "name": "Executive Suite",
          "price": 290.0,
          "quantity": 15,
          "description": "Spacious suite with separate living area and premium amenities"
        }
      ]
    },
    {
      "id": 59,
      "name": "Desaru Beach Resort",
      "address": "Jalan Pantai Desaru, 81930 Kota Tinggi",
      "city": "Kota Tinggi",
      "country": "Malaysia",
      "rating": 4.4,
      "price": 350.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Spa", "Pool", "Kids Club"],
      "roomTypes": [
        {
          "name": "Sea View Room",
          "price": 350.0,
          "quantity": 30,
          "description": "Elegant room with stunning view of the South China Sea"
        },
        {
          "name": "Luxury Villa",
          "price": 550.0,
          "quantity": 10,
          "description": "Private villa with plunge pool and direct beach access"
        }
      ]
    },
    {
      "id": 60,
      "name": "Nusajaya Business Hotel",
      "address": "Persiaran Medini, 79250 Nusajaya",
      "city": "Iskandar Puteri",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 180.0,
      "currency": "MYR",
      "type": "Business Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Business Center", "Meeting Rooms", "Gym", "Free Parking"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 180.0,
          "quantity": 50,
          "description": "Comfortable room with work desk and high-speed internet"
        },
        {
          "name": "Executive Room",
          "price": 250.0,
          "quantity": 20,
          "description": "Spacious room with additional workspace and premium bedding"
        }
      ]
    },
    {
      "id": 61,
      "name": "Legoland Adventure Resort",
      "address": "Jalan Legoland, 79250 Nusajaya",
      "city": "Iskandar Puteri",
      "country": "Malaysia",
      "rating": 4.5,
      "price": 400.0,
      "currency": "MYR",
      "type": "Theme Park Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Theme Park Access", "Pool", "Kids Activities", "Restaurant"],
      "roomTypes": [
        {
          "name": "Themed Room",
          "price": 400.0,
          "quantity": 40,
          "description": "Colorful LEGO-themed family rooms with park access"
        },
        {
          "name": "Family Suite",
          "price": 550.0,
          "quantity": 10,
          "description": "Spacious suite with separate kids’ area and interactive features"
        }
      ]
    },
    {
      "id": 62,
      "name": "Puteri Harbour Waterfront Hotel",
      "address": "Persiaran Puteri Selatan, 79000 Iskandar Puteri",
      "city": "Iskandar Puteri",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 250.0,
      "currency": "MYR",
      "type": "Waterfront Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Marina View", "Restaurant", "Pool", "Fitness Center"],
      "roomTypes": [
        {
          "name": "Superior Marina View",
          "price": 250.0,
          "quantity": 30,
          "description": "Elegant room overlooking the vibrant Puteri Harbour"
        },
        {
          "name": "Harbour Suite",
          "price": 400.0,
          "quantity": 12,
          "description": "Suite with panoramic views and premium amenities"
        }
      ]
    },
    {
      "id": 63,
      "name": "Muar Riverside Hotel",
      "address": "Jalan Maharani, 84000 Muar",
      "city": "Muar",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 170.0,
      "currency": "MYR",
      "type": "Riverside Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "River View", "Restaurant", "Free Parking"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 170.0,
          "quantity": 35,
          "description": "Comfortable room with views of the Muar River"
        },
        {
          "name": "Family Room",
          "price": 220.0,
          "quantity": 15,
          "description": "Larger room ideal for families traveling together"
        }
      ]
    },
    {
      "id": 64,
      "name": "Kulai Eco Resort",
      "address": "Jalan Sawah, 81000 Kulai",
      "city": "Kulai",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 160.0,
      "currency": "MYR",
      "type": "Eco Resort",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Nature Trails", "Swimming Pool", "Organic Restaurant"],
      "roomTypes": [
        {
          "name": "Eco Cabin",
          "price": 160.0,
          "quantity": 20,
          "description": "Rustic eco-friendly cabin surrounded by lush greenery"
        },
        {
          "name": "Deluxe Chalet",
          "price": 220.0,
          "quantity": 10,
          "description": "Spacious chalet with modern comforts in a natural setting"
        }
      ]
    },
    {
      "id": 65,
      "name": "Johor Premium Suites",
      "address": "Jalan Dato Abdullah Tahir, 80300 Johor Bahru",
      "city": "Johor Bahru",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 280.0,
      "currency": "MYR",
      "type": "Serviced Apartment",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Full Kitchen", "Gym", "Pool", "Free Parking"],
      "roomTypes": [
        {
          "name": "One Bedroom Suite",
          "price": 280.0,
          "quantity": 25,
          "description": "Fully furnished serviced apartment ideal for long stays"
        },
        {
          "name": "Two Bedroom Family Suite",
          "price": 380.0,
          "quantity": 12,
          "description": "Spacious apartment with separate bedrooms and living areas"
        }
      ]
    },
    {
      "id": 66,
      "name": "Port Dickson Beachfront Resort",
      "address": "Jalan Pantai, 71000 Port Dickson",
      "city": "Port Dickson",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 320.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Pool", "Spa", "Restaurant"],
      "roomTypes": [
        {
          "name": "Sea View Room",
          "price": 320.0,
          "quantity": 25,
          "description": "Comfortable beachfront room with panoramic sea views"
        },
        {
          "name": "Luxury Chalet",
          "price": 450.0,
          "quantity": 12,
          "description": "Private chalet with deck facing the ocean"
        }
      ]
    },
    {
      "id": 67,
      "name": "Seremban Lakeview Hotel",
      "address": "Jalan Tunku Hassan, 70000 Seremban",
      "city": "Seremban",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 180.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Lake View", "Gym", "Business Center"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 180.0,
          "quantity": 40,
          "description": "Comfortable city-view room with modern furnishings"
        },
        {
          "name": "Lakeview Suite",
          "price": 250.0,
          "quantity": 15,
          "description": "Spacious suite with beautiful lake views and premium facilities"
        }
      ]
    },
    {
      "id": 68,
      "name": "Nilai Spring Golf Resort Hotel",
      "address": "PT4770, Nilai Springs, 71800 Nilai",
      "city": "Nilai",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 210.0,
      "currency": "MYR",
      "type": "Golf Resort",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Golf Course", "Swimming Pool", "Gym", "Spa"],
      "roomTypes": [
        {
          "name": "Deluxe Golf View Room",
          "price": 210.0,
          "quantity": 30,
          "description": "Comfortable room with balcony overlooking the golf course"
        },
        {
          "name": "Executive Suite",
          "price": 320.0,
          "quantity": 10,
          "description": "Premium suite with separate living area and scenic golf views"
        }
      ]
    },
    {
      "id": 69,
      "name": "Kota Bharu City Hotel",
      "address": "Jalan Sultan Yahya Petra, 15200 Kota Bharu",
      "city": "Kota Bharu",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 160.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Conference Facilities", "Parking"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 160.0,
          "quantity": 40,
          "description": "Modern, comfortable room suitable for business and leisure stays"
        },
        {
          "name": "Executive Room",
          "price": 230.0,
          "quantity": 15,
          "description": "Spacious room with city view and premium bedding"
        }
      ]
    },
    {
      "id": 70,
      "name": "Pantai Cahaya Resort",
      "address": "Jalan Pantai Cahaya Bulan, 15350 Kota Bharu",
      "city": "Kota Bharu",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 280.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Pool", "Restaurant"],
      "roomTypes": [
        {
          "name": "Beach Chalet",
          "price": 280.0,
          "quantity": 20,
          "description": "Charming chalet just steps away from the sandy beach"
        },
        {
          "name": "Family Villa",
          "price": 400.0,
          "quantity": 8,
          "description": "Spacious family villa with private terrace"
        }
      ]
    },
    {
      "id": 71,
      "name": "Rantau Panjang Inn",
      "address": "Jalan Besar, 17200 Rantau Panjang",
      "city": "Rantau Panjang",
      "country": "Malaysia",
      "rating": 3.9,
      "price": 120.0,
      "currency": "MYR",
      "type": "Budget Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Parking", "Café"],
      "roomTypes": [
        {
          "name": "Standard Twin Room",
          "price": 120.0,
          "quantity": 25,
          "description": "Simple, comfortable room ideal for short stays"
        },
        {
          "name": "Deluxe Family Room",
          "price": 180.0,
          "quantity": 10,
          "description": "Larger room ideal for small families or groups"
        }
      ]
    },
    {
      "id": 72,
      "name": "Kuala Terengganu Riverside Hotel",
      "address": "Jalan Sultan Zainal Abidin, 20000 Kuala Terengganu",
      "city": "Kuala Terengganu",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 180.0,
      "currency": "MYR",
      "type": "Riverside Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "River View", "Conference Facilities"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 180.0,
          "quantity": 35,
          "description": "Comfortable city room with river views"
        },
        {
          "name": "Executive Suite",
          "price": 280.0,
          "quantity": 12,
          "description": "Spacious suite with additional living space"
        }
      ]
    },
    {
      "id": 73,
      "name": "Redang Island Resort",
      "address": "Pulau Redang, 21090 Kuala Nerus",
      "city": "Redang Island",
      "country": "Malaysia",
      "rating": 4.6,
      "price": 480.0,
      "currency": "MYR",
      "type": "Island Resort",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Beachfront", "Snorkeling", "Diving Center", "Restaurant"],
      "roomTypes": [
        {
          "name": "Beachfront Chalet",
          "price": 480.0,
          "quantity": 15,
          "description": "Private chalet right on the beach with breathtaking sea views"
        },
        {
          "name": "Garden Villa",
          "price": 380.0,
          "quantity": 10,
          "description": "Comfortable villa with garden views, close to amenities"
        }
      ]
    },
    {
      "id": 74,
      "name": "Dungun Hilltop Hotel",
      "address": "Jalan Lapangan Terbang, 23000 Dungun",
      "city": "Dungun",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 150.0,
      "currency": "MYR",
      "type": "Budget Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Free Parking", "Café"],
      "roomTypes": [
        {
          "name": "Standard Double Room",
          "price": 150.0,
          "quantity": 30,
          "description": "Basic and affordable room with essential amenities"
        }
      ]
    },
    {
      "id": 75,
      "name": "Kangar Heritage Hotel",
      "address": "Jalan Kangar - Alor Setar, 01000 Kangar",
      "city": "Kangar",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 150.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Meeting Rooms"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 150.0,
          "quantity": 30,
          "description": "Comfortable room with simple modern amenities"
        }
      ]
    },
    {
      "id": 76,
      "name": "Perlis Countryside Resort",
      "address": "Jalan Kuala Perlis, 02000 Kuala Perlis",
      "city": "Kuala Perlis",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 220.0,
      "currency": "MYR",
      "type": "Resort",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Countryside Views", "Free Parking", "Swimming Pool"],
      "roomTypes": [
        {
          "name": "Deluxe Countryside Room",
          "price": 220.0,
          "quantity": 18,
          "description": "Spacious room with peaceful countryside views"
        },
        {
          "name": "Family Suite",
          "price": 300.0,
          "quantity": 8,
          "description": "Large family suite with separate bedrooms and dining area"
        }
      ]
    },
    {
      "id": 77,
      "name": "Langkawi Seaside Resort",
      "address": "Pantai Cenang, 07000 Langkawi",
      "city": "Langkawi",
      "country": "Malaysia",
      "rating": 4.5,
      "price": 450.0,
      "currency": "MYR",
      "type": "Beach Resort",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Private Beach", "Infinity Pool", "Spa", "Water Sports"],
      "roomTypes": [
        {
          "name": "Beachfront Villa",
          "price": 450.0,
          "quantity": 15,
          "description": "Luxury villa with private terrace and direct beach access"
        },
        {
          "name": "Garden Suite",
          "price": 380.0,
          "quantity": 10,
          "description": "Comfortable suite with serene garden surroundings"
        }
      ]
    },
    {
      "id": 78,
      "name": "Alor Setar Grand Hotel",
      "address": "Jalan Sultan Badlishah, 05000 Alor Setar",
      "city": "Alor Setar",
      "country": "Malaysia",
      "rating": 4.2,
      "price": 190.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Conference Hall", "Gym"],
      "roomTypes": [
        {
          "name": "Superior Room",
          "price": 190.0,
          "quantity": 40,
          "description": "Modern room with city views and work desk"
        },
        {
          "name": "Executive Suite",
          "price": 270.0,
          "quantity": 12,
          "description": "Spacious suite ideal for business travelers"
        }
      ]
    },
    {
      "id": 79,
      "name": "Kulim Hillside Resort",
      "address": "Jalan Bukit Mertajam, 09000 Kulim",
      "city": "Kulim",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 210.0,
      "currency": "MYR",
      "type": "Resort",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Swimming Pool", "Nature Trails", "Restaurant"],
      "roomTypes": [
        {
          "name": "Deluxe Hill View Room",
          "price": 210.0,
          "quantity": 25,
          "description": "Room with stunning views of surrounding hills"
        }
      ]
    },
    {
      "id": 80,
      "name": "Langkawi City Inn",
      "address": "Kuah Town, 07000 Langkawi",
      "city": "Langkawi",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 140.0,
      "currency": "MYR",
      "type": "Budget Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Free Parking", "Breakfast Included"],
      "roomTypes": [
        {
          "name": "Standard Twin Room",
          "price": 140.0,
          "quantity": 30,
          "description": "Simple and cozy room with essential amenities"
        }
      ]
    },
    {
      "id": 81,
      "name": "Sungai Petani Urban Hotel",
      "address": "Jalan Patani, 08000 Sungai Petani",
      "city": "Sungai Petani",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 170.0,
      "currency": "MYR",
      "type": "Business Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Meeting Rooms", "Restaurant", "Gym"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 170.0,
          "quantity": 35,
          "description": "Comfortable business room ideal for work trips"
        },
        {
          "name": "Executive Room",
          "price": 240.0,
          "quantity": 10,
          "description": "Spacious executive room with desk and sitting area"
        }
      ]
    },
    {
      "id": 82,
      "name": "Malacca Heritage Hotel",
      "address": "Jalan Hang Tuah, 75300 Malacca",
      "city": "Malacca",
      "country": "Malaysia",
      "rating": 4.3,
      "price": 220.0,
      "currency": "MYR",
      "type": "Boutique Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Restaurant", "Historical Decor", "Courtyard"],
      "roomTypes": [
        {
          "name": "Heritage Room",
          "price": 220.0,
          "quantity": 20,
          "description": "Traditional Malacca design with modern comforts"
        },
        {
          "name": "Courtyard Suite",
          "price": 320.0,
          "quantity": 8,
          "description": "Luxury suite overlooking a tranquil courtyard"
        }
      ]
    },
    {
      "id": 83,
      "name": "Jonker Street Stay",
      "address": "Jonker Walk, 75200 Malacca",
      "city": "Malacca",
      "country": "Malaysia",
      "rating": 4.1,
      "price": 150.0,
      "currency": "MYR",
      "type": "City Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Cafe", "Walking Distance to Attractions"],
      "roomTypes": [
        {
          "name": "Standard Room",
          "price": 150.0,
          "quantity": 30,
          "description": "Simple room with essential amenities near Jonker Walk"
        }
      ]
    },
    {
      "id": 84,
      "name": "Malacca Riverside Resort",
      "address": "Jalan Laksamana, 75000 Malacca",
      "city": "Malacca",
      "country": "Malaysia",
      "rating": 4.5,
      "price": 300.0,
      "currency": "MYR",
      "type": "Resort",
      "imageUrl": "https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Swimming Pool", "River View", "Restaurant"],
      "roomTypes": [
        {
          "name": "Deluxe River View Room",
          "price": 300.0,
          "quantity": 18,
          "description": "Room with panoramic view of Malacca River"
        }
      ]
    },
    {
      "id": 85,
      "name": "Malacca Central Hotel",
      "address": "Jalan Munshi Abdullah, 75100 Malacca",
      "city": "Malacca",
      "country": "Malaysia",
      "rating": 4.0,
      "price": 180.0,
      "currency": "MYR",
      "type": "Business Hotel",
      "imageUrl": "https://images.unsplash.com/photo-1600047509105-8b90cfadf4ff?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Conference Rooms", "Restaurant", "Gym"],
      "roomTypes": [
        {
          "name": "Superior Room",
          "price": 180.0,
          "quantity": 35,
          "description": "Business-friendly room with work desk"
        }
      ]
    },
    {
      "id": 86,
      "name": "A Famosa View Resort",
      "address": "Jalan Parameswara, 75000 Malacca",
      "city": "Malacca",
      "country": "Malaysia",
      "rating": 4.4,
      "price": 350.0,
      "currency": "MYR",
      "type": "Luxury Resort",
      "imageUrl": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=250&fit=crop",
      "amenities": ["WiFi", "Infinity Pool", "Spa", "Fine Dining"],
      "roomTypes": [
        {
          "name": "Premier Suite",
          "price": 350.0,
          "quantity": 12,
          "description": "Luxurious suite with direct views of A Famosa Fort"
        }
      ]
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

  static Future<List<Map<String, dynamic>>> getAllHotels() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    // Return a copy of the mock hotels data
    return List<Map<String, dynamic>>.from(_mockHotels);
  }

// Also add this method to get hotel data by ID as Map
  static Future<Map<String, dynamic>?> getHotelDataById(int id) async {
    await Future.delayed(Duration(milliseconds: 300));

    try {
      final hotelData = _mockHotels.firstWhere((hotel) => hotel['id'] == id);
      return Map<String, dynamic>.from(hotelData);
    } catch (e) {
      return null;
    }
  }

  static List<String> getPopularDestinations() {
    return [
      'Kuala Lumpur', 'Penang', 'Langkawi', 'Kuching',
      'Johor Bahru', 'Sabah', 'Malacca', 'Port Dickson', 'Cameron Highlands',
      'Genting Highlands', 'Ipoh'
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

  // New method to get room types for a specific hotel
  static List<Map<String, dynamic>> getRoomTypesForHotel(int hotelId) {
    try {
      final hotelData = _mockHotels.firstWhere((hotel) => hotel['id'] == hotelId);
      return List<Map<String, dynamic>>.from(hotelData['roomTypes'] ?? []);
    } catch (e) {
      return [];
    }
  }

  // New method to get room availability
  static Future<Map<String, dynamic>> checkRoomAvailability(int hotelId, String roomType, DateTime checkIn, DateTime checkOut) async {
    await Future.delayed(Duration(milliseconds: 800));

    final roomTypes = getRoomTypesForHotel(hotelId);
    final selectedRoom = roomTypes.firstWhere(
          (room) => room['name'] == roomType,
      orElse: () => {},
    );

    if (selectedRoom.isEmpty) {
      return {'available': false, 'message': 'Room type not found'};
    }

    // Simulate random availability (80% chance of being available)
    final isAvailable = DateTime.now().microsecond % 10 < 8;
    final availableRooms = isAvailable ? (selectedRoom['quantity'] as int) - (DateTime.now().microsecond % 5) : 0;

    return {
      'available': isAvailable && availableRooms > 0,
      'availableRooms': availableRooms,
      'price': selectedRoom['price'],
      'roomType': selectedRoom['name'],
      'description': selectedRoom['description'],
    };
  }
}