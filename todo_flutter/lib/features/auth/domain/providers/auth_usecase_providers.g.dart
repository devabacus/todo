// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(watchUserUseCase)
const watchUserUseCaseProvider = WatchUserUseCaseProvider._();

final class WatchUserUseCaseProvider
    extends
        $FunctionalProvider<
          WatchUserUseCase,
          WatchUserUseCase,
          WatchUserUseCase
        >
    with $Provider<WatchUserUseCase> {
  const WatchUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchUserUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WatchUserUseCase create(Ref ref) {
    return watchUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchUserUseCase>(value),
    );
  }
}

String _$watchUserUseCaseHash() => r'b3520547b1cf154991270a223c9e69b5d4270ea4';

@ProviderFor(signOutUseCase)
const signOutUseCaseProvider = SignOutUseCaseProvider._();

final class SignOutUseCaseProvider
    extends $FunctionalProvider<SignOutUseCase, SignOutUseCase, SignOutUseCase>
    with $Provider<SignOutUseCase> {
  const SignOutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutUseCaseHash();

  @$internal
  @override
  $ProviderElement<SignOutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOutUseCase create(Ref ref) {
    return signOutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutUseCase>(value),
    );
  }
}

String _$signOutUseCaseHash() => r'8cc2470ed44022c6868a2e710009d5234e1a80fc';

@ProviderFor(getCurrentUserUseCase)
const getCurrentUserUseCaseProvider = GetCurrentUserUseCaseProvider._();

final class GetCurrentUserUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentUserUseCase,
          GetCurrentUserUseCase,
          GetCurrentUserUseCase
        >
    with $Provider<GetCurrentUserUseCase> {
  const GetCurrentUserUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentUserUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentUserUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentUserUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentUserUseCase create(Ref ref) {
    return getCurrentUserUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentUserUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentUserUseCase>(value),
    );
  }
}

String _$getCurrentUserUseCaseHash() =>
    r'1e9d6222283b80c2b6fc6ed8c89f4130614c0a11';

@ProviderFor(isSignedInUseCase)
const isSignedInUseCaseProvider = IsSignedInUseCaseProvider._();

final class IsSignedInUseCaseProvider
    extends
        $FunctionalProvider<
          IsSignedInUseCase,
          IsSignedInUseCase,
          IsSignedInUseCase
        >
    with $Provider<IsSignedInUseCase> {
  const IsSignedInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSignedInUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSignedInUseCaseHash();

  @$internal
  @override
  $ProviderElement<IsSignedInUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IsSignedInUseCase create(Ref ref) {
    return isSignedInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IsSignedInUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IsSignedInUseCase>(value),
    );
  }
}

String _$isSignedInUseCaseHash() => r'738b8033e9e32427d63a8a2e3307987e4f93e137';
