# d_iden Project Overview

## Purpose

d_iden is a cross-platform Flutter application for managing decentralized digital identities, verifiable credentials, and blockchain wallets. It enables users to securely create, store, and present digital credentials, leveraging blockchain technology for trust and verification.

---

## Main Features

- **User Authentication**: Secure login, registration, and password management using Firebase Auth.
- **Decentralized Identity (DID)**: Create and manage a DID, stored locally and optionally anchored on a blockchain.
- **Blockchain Wallet**: Generate, import, and manage a blockchain wallet (Ethereum-based), including PIN protection.
- **Verifiable Credentials**: Request, store, present, and manage credentials (active, expired, revoked).
- **Settings & Security**: Manage account details, security settings, and wallet/DID from a unified settings interface.

---

## Architecture

- **Flutter (Dart)**: UI and business logic.
- **Provider**: State management for auth, identity, blockchain, wallet, and settings.
- **Firebase**: Authentication and (optionally) Firestore for user data.
- **SharedPreferences**: Local storage for identities, credentials, and wallet data.
- **Web3dart**: Blockchain wallet and Ethereum interactions.

---

## Module Breakdown

### 1. Authentication
- **Location**: `lib/features/auth/`
- **Flow**: Registration/Login → AuthProvider → Firebase Auth → User session.
- **Account Management**: Edit profile, email, password, and photo. Email updates require re-authentication.

### 2. Blockchain Wallet & DID
- **Location**: `lib/features/blockchain/`
- **Wallet**: Create/import/recover wallet with user PIN. Wallet address and balance shown in dashboard and settings.
- **DID**: Created after wallet setup. DID is derived from wallet public key and stored locally.
- **Error Handling**: Network and blockchain errors are surfaced to the user with clear messages.

### 3. Identity & Credentials
- **Location**: `lib/features/identity/`
- **Digital Identity**: Each user has a DID and associated profile.
- **Credentials**: Issued, stored, and managed per DID. Status (active, expired, revoked) is tracked and displayed.
- **Presentation**: Credentials can be presented for verification.

### 4. Wallet & DID Management
- **Location**: `lib/features/wallet_and_did/`
- **Features**: View wallet address, balance, DID; refresh, copy, or clear data; manage from settings.

### 5. Settings & Security
- **Location**: `lib/features/settings/`
- **Account**: Edit user info, manage email/password, and profile photo.
- **Security**: PIN, biometrics, and session management.
- **Wallet/DID**: Manage from settings.

---

## Data Flow

1. **User logs in/registers** → AuthProvider manages session.
2. **Wallet setup** → User sets PIN, wallet is created/imported, DID is generated.
3. **Identity loaded** → Credentials are fetched for the user's DID.
4. **Credential actions** → Request, present, or revoke credentials.
5. **Settings** → Manage account, security, and wallet/DID.

---

## Extensibility

- **Modular structure**: Easy to add new credential types, blockchain integrations, or authentication providers.
- **Provider-based state**: Centralized, testable, and scalable.
- **UI**: Modern, responsive, and accessible.

---

## Security Considerations

- **PIN and biometrics**: Protect wallet and sensitive actions.
- **Re-authentication**: Required for email/password changes.
- **Local encryption**: (Recommended) for private keys and sensitive data.

---

## Getting Started

1. Clone the repo and run `flutter pub get`.
2. Configure Firebase and blockchain endpoints as needed.
3. Run on your target platform (Android, iOS, Web, Desktop).

---

## Contact & Contribution

See `README.md` for setup, and `SECURITY_FEATURES.md` for security details. Contributions welcome! 