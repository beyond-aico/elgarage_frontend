class AppConfig {
  static const String serverIp = '192.168.1.81'; 
  static const String baseUrl = 'http://$serverIp:3000/api/v1';

  // ✅ العناوين المطلوبة لعمل النظام
  static const String auth = '$baseUrl/auth'; 
  static const String profile = '$baseUrl/users/profile'; // المسار اللي السيرفر مستنيه
  static const String cars = '$baseUrl/cars';
  static const String maintenance = '$baseUrl/maintenance';
  
  static const String appName = 'El Garage';
}