import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, UserModel?>((ref) {
  final notifier = ProfileEditNotifier(ref);
  ref.listen(currentUserProfileProvider, (prev, next) {
    final profile = next.valueOrNull;
    if (profile != null) {
      notifier.setProfileIfEmpty(profile);
    }
  });
  return notifier;
});

class ProfileEditNotifier extends StateNotifier<UserModel?> {
  ProfileEditNotifier(this._ref) : super(null) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final profile = await _ref.read(currentUserProfileProvider.future);
    if (profile != null) state = profile;
  }

  void setProfileIfEmpty(UserModel user) {
    if (state == null) state = user;
  }

  void updateLocal(UserModel user) => state = user;

  Future<void> save() async {
    final user = state;
    if (user == null) return;
    await _ref.read(userServiceProvider).updateUser(user);
    _ref.invalidate(currentUserProfileProvider);
  }

  Future<String?> uploadPhoto(File file) async {
    final user = state;
    if (user == null) return null;
    final url =
        await _ref.read(userServiceProvider).uploadProfileImage(user.id, file);
    if (url != null) {
      state = user.copyWith(photoUrl: url);
    }
    return url;
  }
}
