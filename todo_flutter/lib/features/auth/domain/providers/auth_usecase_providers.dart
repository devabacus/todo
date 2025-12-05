// manifest: startProject
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/providers/auth_data_providers.dart';
import '../usecases/auth_usecases.dart';

part 'auth_usecase_providers.g.dart';

@riverpod
WatchUserUseCase watchUserUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return WatchUserUseCase(repository);
}

@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(repository);
}

@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
}

@riverpod
IsSignedInUseCase isSignedInUseCase(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsSignedInUseCase(repository);
}
