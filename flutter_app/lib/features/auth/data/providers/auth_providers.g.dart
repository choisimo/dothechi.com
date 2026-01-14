// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformStorageHash() => r'214bb455767bc66b4791b08c0d7ef56180cdcb46';

/// See also [platformStorage].
@ProviderFor(platformStorage)
final platformStorageProvider = AutoDisposeProvider<StorageInterface>.internal(
  platformStorage,
  name: r'platformStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlatformStorageRef = AutoDisposeProviderRef<StorageInterface>;
String _$authApiHash() => r'a4caefd02b7c7f025cbc433ffdfa108b999f1783';

/// See also [authApi].
@ProviderFor(authApi)
final authApiProvider = AutoDisposeProvider<AuthApi>.internal(
  authApi,
  name: r'authApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthApiRef = AutoDisposeProviderRef<AuthApi>;
String _$tokenStorageHash() => r'7c502a870026276b260de4e63cc1b114e0918b38';

/// See also [tokenStorage].
@ProviderFor(tokenStorage)
final tokenStorageProvider = AutoDisposeProvider<TokenStorage>.internal(
  tokenStorage,
  name: r'tokenStorageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tokenStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TokenStorageRef = AutoDisposeProviderRef<TokenStorage>;
String _$authRepositoryHash() => r'414b2a534875d1d3f9cfaf060d9d75eeb3499c4d';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$authNotifierHash() => r'86e3ba0a175060943e35c864033ca8f86bc5bacd';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthStatus>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AuthStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
