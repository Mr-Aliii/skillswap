import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skill_swap/models/connection_request_model.dart';
import 'package:skill_swap/providers/auth_provider.dart';
import 'package:skill_swap/providers/service_providers.dart';
import 'package:skill_swap/utils/dummy_data.dart';

/// Provider to fetch and watch connection request state between the current user and another user.
final connectionRequestProvider =
    FutureProvider.family<ConnectionRequestModel?, String>((ref, otherUserId) async {
  final currentUserId = ref.watch(authStateProvider).valueOrNull?.uid ?? DummyData.demoUserId;
  final connectionService = ref.watch(connectionServiceProvider);
  return connectionService.getConnectionRequest(currentUserId, otherUserId);
});
