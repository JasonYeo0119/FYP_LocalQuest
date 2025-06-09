class Attraction {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String description;
  final List<String> type;
  final List<PricingInfo> pricing;
  final List<String> images;

  Attraction({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.description,
    required this.type,
    required this.pricing,
    required this.images,
  });

  // Factory constructor to create Attraction from Firebase data
  factory Attraction.fromMap(String id, Map<dynamic, dynamic> data) {
    List<PricingInfo> pricingList = [];
    if (data['pricing'] != null) {
      for (var item in data['pricing']) {
        pricingList.add(PricingInfo.fromMap(item));
      }
    }

    List<String> typeList = [];
    if (data['type'] != null) {
      typeList = List<String>.from(data['type']);
    }

    List<String> imagesList = [];
    if (data['images'] != null) {
      imagesList = List<String>.from(data['images']);
    }

    return Attraction(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      description: data['description'] ?? '',
      type: typeList,
      pricing: pricingList,
      images: imagesList,
    );
  }

  factory Attraction.fromJson(Map<String, dynamic> json) {
    List<PricingInfo> pricingList = [];
    if (json['pricing'] != null) {
      for (var item in json['pricing']) {
        pricingList.add(PricingInfo.fromJson(item));
      }
    }

    List<String> typeList = [];
    if (json['type'] != null) {
      typeList = List<String>.from(json['type']);
    }

    List<String> imagesList = [];
    if (json['images'] != null) {
      imagesList = List<String>.from(json['images']);
    }

    return Attraction(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      description: json['description'] ?? '',
      type: typeList,
      pricing: pricingList,
      images: imagesList,
    );
  }

  // Convert Attraction to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'description': description,
      'type': type,
      'pricing': pricing.map((p) => p.toMap()).toList(),
      'images': images,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'description': description,
      'type': type,
      'pricing': pricing.map((p) => p.toJson()).toList(),
      'images': images,
    };
  }
}

class PricingInfo {
  final String remark;
  final double price;

  PricingInfo({
    required this.remark,
    required this.price,
  });

  factory PricingInfo.fromMap(Map<dynamic, dynamic> data) {
    return PricingInfo(
      remark: data['remark'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    return PricingInfo(
      remark: json['remark'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'remark': remark,
      'price': price,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'remark': remark,
      'price': price,
    };
  }
}

