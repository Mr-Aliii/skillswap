import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/services/auth_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider =
    FutureProvider<UserModel?>((ref) async {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return null;
  final userService = ref.watch(userServiceProvider);
  var profile = await userService.getUser(authUser.uid);
  if (profile == null && authUser.email != null) {
    profile = UserModel(
      id: authUser.uid,
      email: authUser.email!,
      name: authUser.displayName ?? authUser.email!.split('@').first,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await userService.createUser(profile);
  }
  return profile;
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  AuthService get _auth => _ref.read(authServiceProvider);

  Future<UserModel?> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await _auth.signIn(email, password);
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await _auth.register(
        email: email,
        password: password,
        name: name,
      );
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      await _auth.resetPassword(email);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
