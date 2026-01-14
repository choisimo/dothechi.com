import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_chat_client/app/go_router.dart';
import 'package:flutter_chat_client/app/app_theme.dart';
import 'package:flutter_chat_client/core/config/app_config.dart';
import 'package:flutter_chat_client/core/network/api_client.dart';
import 'package:flutter_chat_client/core/storage/storage_factory.dart';
import 'package:flutter_chat_client/features/auth/data/datasources/token_storage.dart';

void main() {
  AppConfig.initialize(Environment.development);

  final storage = StorageFactory.create();
  final tokenStorage = TokenStorage(storage);
  final apiClient = ApiClient.create(tokenStorage);

  runApp(
    ProviderScope(
      overrides: [
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
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
