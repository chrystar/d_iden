import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/providers/security_provider.dart';
import 'core/services/security_service.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/identity/presentation/providers/identity_provider.dart';
import 'features/identity/data/repositories/identity_repository_impl.dart';
import 'features/wallet/presentation/providers/wallet_provider.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/blockchain/presentation/providers/blockchain_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/identity/presentation/screens/credential_request_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IdentityProvider(
          identityRepository: IdentityRepositoryImpl(),
        )),
        ChangeNotifierProvider(create: (_) => WalletProvider(
          walletRepository: WalletRepositoryImpl(
            rpcUrl: AppConstants.networkRpcUrl,
            chainId: AppConstants.networkChainId,
          ),
        )),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => BlockchainProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) => MaterialApp(
          title: 'D-Iden',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.isLoaded 
              ? settingsProvider.themeMode 
              : ThemeMode.system,
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/credential-request': (context) => const CredentialRequestScreen(),
          },
        ),
      ),
    );
  }
}

