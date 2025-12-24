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
}