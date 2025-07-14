class AppConstants {
  // App Information
  static const String appName = 'D-Iden';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String privateKeyKey = 'private_key_encrypted';
  static const String walletAddressKey = 'wallet_address';
  static const String biometricsEnabledKey = 'biometrics_enabled';
  
  // Blockchain Network
  static const String networkRpcUrl = 'https://polygon-mumbai.g.alchemy.com/v2/demo'; // Free public RPC for Mumbai
  static const int networkChainId = 80001; // Mumbai testnet
  static const String networkName = 'Polygon Mumbai';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int biometricTimeout = 30;
  
  // Validation
  static const int minPasswordLength = 8;
  static const int pinLength = 6;
}
