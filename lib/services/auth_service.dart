import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/services/user_service.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// Email/password authentication via Firebase Auth (or demo mode).
class AuthService {
  AuthService({UserService? userService})
      : _userService = userService ?? UserService() {
    if (AppConfig.useDemoMode) {
      _demoAuthController.add(null);
    }
  }

  final UserService _userService;
  User? _demoUser;
  final _demoAuthController = StreamController<User?>.broadcast();

  Stream<User?> get authStateChanges {
    if (AppConfig.useDemoMode) {
      return _demoAuthController.stream;
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser {
    if (AppConfig.useDemoMode) return _demoUser;
    return FirebaseAuth.instance.currentUser;
  }

  void _emitDemoUser() => _demoAuthController.add(_demoUser);

  Future<UserModel?> signIn(String email, String password) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _demoUser = _MockUser(email);
      _emitDemoUser();
      return DummyData.demoUser;
    }
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _userService.getUser(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    }
  }

  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      _demoUser = _MockUser(email);
      _emitDemoUser();
      return DummyData.demoUser.copyWith(name: name, email: email);
    }
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = UserModel(
        id: cred.user!.uid,
        email: email.trim(),
        name: name.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userService.createUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    }
  }

  Future<void> resetPassword(String email) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AppException(_mapAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    if (AppConfig.useDemoMode) {
      _demoUser = null;
      _emitDemoUser();
      return;
    }
    await FirebaseAuth.instance.signOut();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

class _MockUser implements User {
  _MockUser(this.email);
  @override
  final String? email;
  @override
  String get uid => DummyData.demoUserId;
  @override
  bool get emailVerified => true;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
