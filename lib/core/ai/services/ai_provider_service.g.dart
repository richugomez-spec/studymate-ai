// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_provider_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeAIProviderHash() => r'cbc04665685391bcd7de9952556fe6f3f8230edb';

/// Reads active AI config from secure storage and returns the correct [AIProvider].
/// Automatically picks Ollama if offline mode is enabled.
///
/// Copied from [activeAIProvider].
@ProviderFor(activeAIProvider)
final activeAIProviderProvider = AutoDisposeFutureProvider<AIProvider>.internal(
  activeAIProvider,
  name: r'activeAIProviderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeAIProviderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveAIProviderRef = AutoDisposeFutureProviderRef<AIProvider>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
