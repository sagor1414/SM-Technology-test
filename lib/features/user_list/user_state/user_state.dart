// lib/state/user_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../user_model/user_model.dart';
import '../service/user_service.dart';

class UserState {
  final List<User> users;
  final bool hasMore;
  final bool isLoading;
  final int currentPage;

  UserState({
    required this.users,
    required this.hasMore,
    required this.isLoading,
    required this.currentPage,
  });

  UserState copyWith({
    List<User>? users,
    bool? hasMore,
    bool? isLoading,
    int? currentPage,
  }) {
    return UserState(
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

final userServiceProvider = Provider<UserService>((ref) => UserService());

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.read(userServiceProvider));
});

class UserNotifier extends StateNotifier<UserState> {
  final UserService _userService;

  UserNotifier(this._userService)
      : super(UserState(
            users: [], hasMore: true, isLoading: false, currentPage: 1));

  Future<void> fetchUsers() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _userService.fetchUsers(state.currentPage);
      final List<User> newUsers =
          (response['data'] as List).map((e) => User.fromJson(e)).toList();

      state = state.copyWith(
        users: [...state.users, ...newUsers],
        hasMore: state.currentPage < response['total_pages'],
        isLoading: false,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      // Handle error
      state = state.copyWith(isLoading: false);
    }
  }
}
