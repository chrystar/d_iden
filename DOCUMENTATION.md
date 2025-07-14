# D-Iden Application Documentation

## Overview

D-Iden is a Flutter-based digital identity management application that allows users to create and manage their digital identity credentials, interact with blockchain technology, and manage a digital wallet. The application follows a clean architecture pattern with feature-based organization and includes robust security features.

## Core Features

### 1. Digital Identity Management

**What it does:**
- Create digital identities (DIDs) for users
- Manage and store identity credentials
- Verify identity using blockchain technology
- Display identity information in dashboard format

**Key Components:**
- `IdentityProvider`: Manages state related to digital identities
- `IdentityRepository`: Handles data operations for identities
- `IdentityDashboardScreen`: UI for managing digital identities

**How it works:**
The "Create Digital Identity" button in the Identity Dashboard triggers the identity creation process. The application generates a unique identifier, stores identity data securely, and provides confirmation feedback to the user.

### 2. Blockchain Integration

**What it does:**
- Connect to blockchain networks
- Create and verify blockchain-based DIDs
- Manage blockchain transactions
- Provide blockchain status and information

**Key Components:**
- `BlockchainProvider`: Manages blockchain connection state and operations
- Blockchain service classes: Handle specific blockchain operations

### 3. Wallet Management

**What it does:**
- Create and manage digital wallets
- Handle digital asset transactions
- View transaction history
- Manage wallet security

**Key Components:**
- `WalletProvider`: Manages wallet state and operations
- Wallet service classes: Handle wallet operations

### 4. Authentication System

**What it does:**
- User registration and login
- Session management
- Authentication state tracking

**Key Components:**
- `AuthProvider`: Manages authentication state
- Authentication service classes: Handle authentication operations
- `SplashScreen`: Initial screen that checks authentication status

## Security Features

### 1. Biometric Authentication

**What it does:**
- Allows users to authenticate using fingerprint or face recognition
- Secures sensitive operations like viewing identity details or making transactions
- Provides an additional layer of security beyond PIN/password

**Key Components:**
- `SecurityService.authenticateWithBiometrics()`: Handles biometric authentication logic
- `SecurityProvider.biometricsEnabled`: Tracks whether biometrics are enabled
- UI components in `SecuritySettingsScreen` for enabling/disabling biometrics

**Implementation Details:**
- Uses the `local_auth` package (v2.1.7)
- Checks device capability for biometric authentication
- Provides fallback mechanisms when biometrics fail or are unavailable
- Stores biometric preference securely

**Example Usage:**
```dart
// To authenticate a user with biometrics
final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
bool authenticated = await securityProvider.authenticateWithBiometrics(
  reason: 'Please authenticate to access your digital identity'
);

if (authenticated) {
  // Proceed with the secure operation
} else {
  // Show authentication failure message
}
```

### 2. Data Encryption

**What it does:**
- Encrypts sensitive data before storage
- Ensures that even if device storage is compromised, data remains protected
- Uses industry-standard AES-256 encryption

**Key Components:**
- `SecurityService.encryptData()`: Encrypts string data
- `SecurityService.decryptData()`: Decrypts encrypted data
- Secure key management system

**Implementation Details:**
- Uses the `encrypt` package (v5.0.3) and `crypto` package (v3.0.3)
- Implements AES encryption with secure key generation
- Handles encryption failures gracefully

**Example Usage:**
```dart
// To encrypt sensitive data
final securityProvider = Provider.of<SecurityProvider>(context, listen: false);
String encryptedData = await securityProvider.encryptData('sensitive information');

// To decrypt data
String decryptedData = await securityProvider.decryptData(encryptedData);
```

### 3. Secure Storage

**What it does:**
- Stores sensitive information in secure storage rather than regular app storage
- Uses platform-specific security features (Keystore on Android, Keychain on iOS)
- Protects against unauthorized access to stored data

**Key Components:**
- `SecurityService.secureWrite()`: Writes data to secure storage
- `SecurityService.secureRead()`: Reads data from secure storage
- `SecurityService.secureDelete()`: Removes data from secure storage

**Implementation Details:**
- Uses the `flutter_secure_storage` package (v9.0.0)
- Implements error handling for storage operations
- Provides options for different storage accessibility levels

**Example Usage:**
```dart
// To store data securely
final securityService = SecurityService();
await securityService.secureWrite('api_key', 'your-secret-api-key');

// To retrieve securely stored data
String? apiKey = await securityService.secureRead('api_key');
```

### 4. PIN Protection

**What it does:**
- Requires PIN entry for app access or sensitive operations
- Configurable to require PIN always, for transactions only, or disabled
- Prevents unauthorized access even without biometrics

**Key Components:**
- PIN requirement settings in `SecuritySettingsScreen`
- PIN validation logic
- PIN storage and management

**Implementation Details:**
- PIN is stored securely using encryption
- Configurable PIN requirements (always, transactions only, disabled)
- Warning shown when attempting to disable PIN protection

## Architecture & Technical Design

### Project Structure

The application follows a feature-based architecture with clean separation of concerns:

```
lib/
├── core/                     # Core functionality used across features
│   ├── providers/            # Application-wide state management
│   ├── services/             # Core services (including SecurityService)
│   └── themes/               # App theming
├── features/                 # Feature modules
│   ├── auth/                 # Authentication feature
│   ├── blockchain/           # Blockchain integration feature
│   ├── identity/             # Digital identity feature
│   ├── settings/             # App settings feature
│   └── wallet/               # Digital wallet feature
└── main.dart                 # Application entry point
```

### State Management

The application uses the Provider pattern for state management:

- Each feature has its own provider (AuthProvider, IdentityProvider, etc.)
- The SecurityProvider manages security-related state app-wide
- Providers are initialized in main.dart and accessible throughout the app

### Data Flow

1. User interacts with UI components
2. UI calls provider methods
3. Providers use services and repositories to perform operations
4. Data flows back to UI through provider state changes

## How to Use Security Features

### Enabling Biometric Authentication

1. Navigate to Settings > Security Settings
2. Under the "Authentication" section, toggle "Biometric Authentication" to ON
3. Complete the biometric verification prompt
4. Biometrics will now be required for sensitive operations

### Configuring PIN Requirements

1. Navigate to Settings > Security Settings
2. Under the "Authentication" section, select your preferred PIN requirement:
   - "Always Require PIN": PIN required for all app access
   - "Transactions Only": PIN required only for transactions
   - "Disabled": No PIN required (not recommended)

### Data Backup & Recovery (Planned Feature)

1. Navigate to Settings > Security Settings
2. Under "Advanced Security", select "Backup Wallet & Credentials"
3. Follow the prompts to create an encrypted backup

## Implementation Notes

- The security features use a layered approach with multiple protection mechanisms
- Biometric authentication is implemented as an additional security layer, not a replacement for other security measures
- All sensitive data is both encrypted and stored in secure storage
- The application respects platform-specific security best practices
