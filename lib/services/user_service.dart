import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// CRUD for user profiles in Firestore + profile image upload.
class UserService {
  FirebaseFirestore? get _firestore =>
      AppConfig.useDemoMode ? null : FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    if (AppConfig.useDemoMode) {
      if (uid == DummyData.demoUserId) return DummyData.demoUser;
      for (final u in DummyData.recommendedUsers) {
        if (u.id == uid) return u;
      }
      return null;
    }
    final doc = await _firestore!
        .collection(AppConfig.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> createUser(UserModel user) async {
    if (AppConfig.useDemoMode) return;
    await _firestore!
        .collection(AppConfig.usersCollection)
        .doc(user.id)
        .set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(UserModel user) async {
    if (AppConfig.useDemoMode) return;
    await _firestore!.collection(AppConfig.usersCollection).doc(user.id).update({
      ...user.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> uploadProfileImage(String uid, File file) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return null;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images/$uid.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw AppException('Failed to upload image');
    }
  }

  Future<List<UserModel>> getRecommendedUsers({String? excludeUid}) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return DummyData.recommendedUsers
          .where((u) => u.id != excludeUid)
          .toList();
    }
    final snapshot = await _firestore!
        .collection(AppConfig.usersCollection)
        .limit(20)
        .get();
    return snapshot.docs
        .map((d) => UserModel.fromMap(d.data(), d.id))
        .where((u) => u.id != excludeUid)
        .toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (AppConfig.useDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final q = query.toLowerCase();
      return DummyData.recommendedUsers
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.skillsTeach.any((s) => s.toLowerCase().contains(q)) ||
              u.skillsLearn.any((s) => s.toLowerCase().contains(q)))
          .toList();
    }
    final snapshot = await _firestore!
        .collection(AppConfig.usersCollection)
        .get();
    final q = query.toLowerCase();
    return snapshot.docs
        .map((d) => UserModel.fromMap(d.data(), d.id))
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.skillsTeach.any((s) => s.toLowerCase().contains(q)))
        .toList();
  }
}
