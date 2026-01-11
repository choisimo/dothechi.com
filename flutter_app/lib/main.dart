import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_chat_client/app/go_router.dart';
import 'package:flutter_chat_client/core/config/app_config.dart';
import 'package:flutter_chat_client/core/network/api_client.dart';
import 'package:flutter_chat_client/features/auth/data/datasources/token_storage.dart';

void main() {
  // Initialize app configuration
  // Change to Environment.staging or Environment.production for other environments
  AppConfig.initialize(Environment.development);

  // Create dependencies
  const secureStorage = FlutterSecureStorage();
  final tokenStorage = TokenStorage(secureStorage);
  final apiClient = ApiClient.create(tokenStorage);

  runApp(
    ProviderScope(
      overrides: [
        // Override the apiClient provider with the initialized instance
        apiClientProvider.overrideWithValue(apiClient),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = MyAppRouter.initializeRouter(ref);

    return MaterialApp.router(
      title: 'Nodove Community',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
