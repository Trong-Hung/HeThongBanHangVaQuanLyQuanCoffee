class ApiConfig {
  // Base URL for Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Auth endpoints
  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String profileEndpoint = '$baseUrl/api/auth/profile';
  static const String changePasswordEndpoint =
      '$baseUrl/api/auth/change-password';

  // Product endpoints
  static const String productsEndpoint = '$baseUrl/api/products';

  // Category endpoints
  static const String categoriesEndpoint = '$baseUrl/api/categories';

  // Order endpoints
  static const String ordersEndpoint = '$baseUrl/api/orders';
  static const String orderStatsEndpoint = '$baseUrl/api/orders/stats';

  // Config endpoints
  static const String shopInfoEndpoint = '$baseUrl/api/config/shop-info';
  static const String publicShopInfoEndpoint =
      '$baseUrl/api/config/public/shop-info';

  // Health check
  static const String healthEndpoint = '$baseUrl/api/health';

  // Upload endpoints
  static const String uploadImageEndpoint = '$baseUrl/api/upload/product-image';
  static const String uploadLogoEndpoint = '$baseUrl/api/upload/shop-logo';

  // Request timeout
  static const Duration requestTimeout = Duration(seconds: 30);

  // Test credentials - need to register first
  static const String testUsername = 'testshop01';
  static const String testPassword = 'password123';

  // Default credentials (aliases for compatibility)
  static const String defaultUsername = testUsername;
  static const String defaultPassword = testPassword;
}
