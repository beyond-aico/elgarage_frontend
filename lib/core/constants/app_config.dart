class AppConfig {
  static const String baseUrl = 'https://elgaragebackend-production.up.railway.app/api/v1';

  static const String auth = '$baseUrl/auth'; 
  static const String profile = '$baseUrl/users/profile'; 
  static const String cars = '$baseUrl/cars';
  static const String maintenance = '$baseUrl/maintenance';
  
  static const String appName = 'El Garage';
}