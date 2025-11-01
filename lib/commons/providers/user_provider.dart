import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';

class UserProviderState {
  User? user;
  UserProviderState({this.user});
}

class UserNotifier extends Notifier<UserProviderState> {
  @override
  UserProviderState build() => UserProviderState();

  void login(User? user) {
    state = UserProviderState(user: user);
  }

  void logout() {
    state = UserProviderState();
  }
}

final userProvider = NotifierProvider<UserNotifier, UserProviderState>(UserNotifier.new);
