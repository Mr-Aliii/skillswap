import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:skill_swap/core/constants/premium_plans.dart';
import 'package:skill_swap/config/app_config.dart';
import 'package:skill_swap/core/errors/app_exception.dart';
import 'package:skill_swap/models/user_model.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// CRUD for user profiles in Firestore + profile image upload.
class UserService {
  FirebaseFirestore? get _firestore =>
      AppConfig.isDemoMode ? null : FirebaseFirestore.instance;

  Future<UserModel?> getUser(String uid) async {
    if (AppConfig.isDemoMode) {
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
    if (AppConfig.isDemoMode) return;
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
    if (AppConfig.isDemoMode) return;
    await _firestore!.collection(AppConfig.usersCollection).doc(user.id).update({
      ...user.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> uploadProfileImage(String uid, File file) async {
    if (AppConfig.isDemoMode) {
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
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final users = DummyData.recommendedUsers
          .where((u) => u.id != excludeUid)
          .toList();
      return PremiumPlans.sortPremiumFirst(users);
    }
    final snapshot = await _firestore!
        .collection(AppConfig.usersCollection)
        .limit(50)
        .get();
    final users = snapshot.docs
        .map((d) => UserModel.fromMap(d.data(), d.id))
        .where((u) => u.id != excludeUid)
        .toList();
    return PremiumPlans.sortPremiumFirst(users);
  }

  /// Skill-based matching: returns exactly 6 recommended users.
  ///
  /// Order:
  ///   1-3: Premium users (sorted by rating high→low)
  ///   4-6: Non-premium users sorted by teaching skill match count (3→2→1)
  ///
  /// Only users whose [skillsTeach] overlap with [currentUser.skillsLearn]
  /// are included. Zero-match users are completely excluded.
  ///
  /// Firebase path uses `array-contains-any` on `skillsTeach` for efficient
  /// server-side filtering — only matching users are fetched from Firestore.
  Future<List<UserModel>> getSkillMatchedUsers(
    UserModel currentUser,
  ) async {
    final excludeUid = currentUser.id;
    final myLearnSkills = currentUser.skillsLearn;

    // If user has no learning skills, no matches possible
    if (myLearnSkills.isEmpty) return [];

    List<UserModel> allUsers;
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      allUsers = DummyData.recommendedUsers
          .where((u) => u.id != excludeUid)
          .toList();
    } else {
      // ── Firebase: Use array-contains-any for server-side filtering ──
      // This queries Firestore for users whose `skillsTeach` array
      // contains ANY of the current user's `skillsLearn` values.
      // Only matching users come from the database — no wasted reads.
      final snapshot = await _firestore!
          .collection(AppConfig.usersCollection)
          .where('skillsTeach', arrayContainsAny: myLearnSkills)
          .limit(30)
          .get();
      allUsers = snapshot.docs
          .map((d) => UserModel.fromMap(d.data(), d.id))
          .where((u) => u.id != excludeUid)
          .toList();
    }

    // Score each user: count teaching skill overlaps with my learning skills
    final scored = <_ScoredUser>[];
    for (final other in allUsers) {
      // How many of their teaching skills match my learning skills
      final teachMatchCount = myLearnSkills
          .where((s) => other.skillsTeach.contains(s))
          .length;

      // Bonus: I teach what they want to learn
      final learnMatchCount = currentUser.skillsTeach
          .where((s) => other.skillsLearn.contains(s))
          .length;

      // Fuzzy/partial matches (e.g. "Flutter" ↔ "Flutter Development")
      int fuzzyCount = 0;
      for (final mySkill in myLearnSkills) {
        final myLower = mySkill.toLowerCase();
        for (final theirSkill in other.skillsTeach) {
          final theirLower = theirSkill.toLowerCase();
          if (myLower != theirLower &&
              (myLower.contains(theirLower) ||
                  theirLower.contains(myLower))) {
            fuzzyCount++;
          }
        }
      }

      // Only include users with at least ONE skill match
      if (teachMatchCount > 0 || fuzzyCount > 0) {
        scored.add(_ScoredUser(
          user: other,
          teachMatchCount: teachMatchCount,
          learnMatchCount: learnMatchCount,
          fuzzyCount: fuzzyCount,
          isPremium: other.showVerifiedBadge,
        ));
      }
    }

    // ── Split into premium & non-premium ──
    final premium = scored.where((s) => s.isPremium).toList();
    final nonPremium = scored.where((s) => !s.isPremium).toList();

    // Sort premium by rating (high → low)
    premium.sort((a, b) => b.user.rating.compareTo(a.user.rating));

    // Sort non-premium by teachMatchCount (3 → 2 → 1), then by rating
    nonPremium.sort((a, b) {
      final cmp = b.teachMatchCount.compareTo(a.teachMatchCount);
      if (cmp != 0) return cmp;
      return b.user.rating.compareTo(a.user.rating);
    });

    // Take up to 3 premium + up to 3 non-premium = max 6
    final result = <UserModel>[];
    result.addAll(premium.take(3).map((s) => s.user));
    result.addAll(nonPremium.take(3).map((s) => s.user));

    return result;
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (AppConfig.isDemoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final q = query.toLowerCase();
      final users = DummyData.recommendedUsers
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.skillsTeach.any((s) => s.toLowerCase().contains(q)) ||
              u.skillsLearn.any((s) => s.toLowerCase().contains(q)))
          .toList();
      return PremiumPlans.sortPremiumFirst(users);
    }
    final snapshot = await _firestore!
        .collection(AppConfig.usersCollection)
        .get();
    final q = query.toLowerCase();
    final users = snapshot.docs
        .map((d) => UserModel.fromMap(d.data(), d.id))
        .where((u) =>
            u.name.toLowerCase().contains(q) ||
            u.skillsTeach.any((s) => s.toLowerCase().contains(q)))
        .toList();
    return PremiumPlans.sortPremiumFirst(users);
  }
}

class _ScoredUser {
  _ScoredUser({
    required this.user,
    required this.teachMatchCount,
    required this.learnMatchCount,
    required this.fuzzyCount,
    this.isPremium = false,
  });
  final UserModel user;
  final int teachMatchCount;
  final int learnMatchCount;
  final int fuzzyCount;
  final bool isPremium;
}
