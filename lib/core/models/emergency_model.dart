class EmergencyModel {
  final String name;
  final String phoneNumber;
  final String location;     // المنطقة (Nasr City, Maadi...)
  final String type;         // 'Winch', 'Tire', 'Battery'
  final String rating;       // تقييم (4.5)

  EmergencyModel({
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.type,
    required this.rating,
  });
  factory EmergencyModel.fromJson(Map<String, dynamic> json) {
    return EmergencyModel(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      rating: json['rating']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'location': location,
      'type': type,
      'rating': rating,
    };
  }
}