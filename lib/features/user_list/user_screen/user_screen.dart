// lib/screens/user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../user_state/user_state.dart';
import '../widgets/user_details_card.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProvider.notifier).fetchUsers();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(userProvider.notifier).fetchUsers();
      }
    });
  }

  Future<void> _refreshUsers() async {
    // Reset the state and fetch the users again
    ref.read(userProvider.notifier).state = UserState(
      users: [],
      hasMore: true,
      isLoading: false,
      currentPage: 1,
    );
    await ref.read(userProvider.notifier).fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: RefreshIndicator(
        onRefresh: _refreshUsers,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: userState.users.length + (userState.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < userState.users.length) {
                final user = userState.users[index];
                return UserDetailsCard(
                  user: user,
                );
              } else {
                return const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ));
              }
            },
          ),
        ),
      ),
    );
  }
}
