// Assuming you have or will create basic models

// --- MOCK DATABASE SERVICE ---
class DummyDataService {
  
  // 1. Users Table (Simulating DB Table)
  static final List<Map<String, dynamic>> _users = [
    {
      'id': 'u_admin',
      'username': 'f',
      'password': 'f', // In real app, this is hashed
      'role': 'FLEET_MANAGER',
      'name': 'Hesham Fathy',
      'company': 'ElGarage Logistics'
    },
    {
      'id': 'u_driver_01',
      'username': 'd',
      'password': 'd',
      'role': 'DRIVER',
      'assignedCarId': 'c_001',
      'name': 'Ahmed Driver'
    },
    {
      'id': 'u_individual',
      'username': 'u',
      'password': 'u',
      'role': 'INDIVIDUAL',
      'name': 'Individual Owner'
    }
  ];

  // 2. Fleet Cars Table
  // Generating 20 dummy cars with industrial/fleet context
  static final List<Map<String, dynamic>> _fleetCars = List.generate(20, (index) {
    int id = index + 1;
    double mileage = 10000.0 + (index * 5000); 
    bool maintenanceNeeded = mileage > 50000 && mileage < 55000; // Random logic
    
    return {
      'id': 'c_${id.toString().padLeft(3, '0')}',
      'make': index % 2 == 0 ? 'Toyota' : 'Chevrolet',
      'model': index % 2 == 0 ? 'Hilux' : 'Optra',
      'year': 2021 + (index % 3),
      'plateNumber': 'ABC ${100 + id}',
      'currentOdometer': mileage,
      'status': maintenanceNeeded ? 'MAINTENANCE_REQUIRED' : 'ACTIVE',
      'lastServiceDate': '2025-10-${(id % 30).toString().padLeft(2, '0')}',
      'image': 'assets/images/car_placeholder.png', // Placeholder
      'driverId': 'u_driver_${id.toString().padLeft(2, '0')}'
    };
  });

  // 3. Maintenance Logs
  static final List<Map<String, dynamic>> logs = [];

  // --- METHODS ---

  static Map<String, dynamic>? login(String username, String password, String type) {
    try {
      final user = _users.firstWhere(
        (u) => u['username'] == username && u['password'] == password,
      );
      
      // Strict Role Check
      if (type == 'FLEET' && user['role'] == 'INDIVIDUAL') return null;
      if (type == 'INDIVIDUAL' && user['role'] != 'INDIVIDUAL') return null;
      
      return user;
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getFleetCars() {
    return _fleetCars;
  }

  static Map<String, dynamic>? getCarById(String id) {
    return _fleetCars.firstWhere((c) => c['id'] == id, orElse: () => {});
  }

  // Driver updates Odometer
  static Map<String, dynamic> updateOdometer(String carId, double newReading) {
    final carIndex = _fleetCars.indexWhere((c) => c['id'] == carId);
    if (carIndex != -1) {
      _fleetCars[carIndex]['currentOdometer'] = newReading;
      
      // Simple Logic: If mileage > 100,000 trigger alert
      if (newReading % 10000 < 500) { 
         _fleetCars[carIndex]['status'] = 'MAINTENANCE_REQUIRED';
      } else {
         _fleetCars[carIndex]['status'] = 'ACTIVE';
      }
      return _fleetCars[carIndex];
    }
    throw Exception('Car not found');
  }
}