class AppConstants {
  // API Endpoints
  static const String baseUrl = 'http://196.190.251.122';
  static const String loginEndpoint = 'http://196.190.251.122:8084/api/auth/sign-in';
  static const String registerEndpoint = 'http://196.190.251.122:8084/api/auth/sign-up';
  static const String productsEndpoint = 'http://196.190.251.122:8086/api/Products';
  static const String invoicesEndpoint = 'http://196.190.251.122:8082/api/v2/invoices';
  static const String usersEndpoint = 'http://196.190.251.122:8086/api/Auth/me';
  
  // Local Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String cartKey = 'cart_data';
  
  // App Settings
  static const String appName = 'My App';
  static const String appVersion = '1.0.0';
  
  // Printer Settings
  static const int printerTimeout = 30000; // 30 seconds
  static const int maxRetries = 3;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;
} 