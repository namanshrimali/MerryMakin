import 'dart:convert';

import 'package:http/src/response.dart';
import '../api/user_api.dart';
import '../dao/user_dao.dart';
import '../models/user.dart';
import '../models/user_request_dto.dart';
import '../service/cookies_service.dart';

class UserService {
  UserDAO userDAO;
  CookiesService cookiesService;

  UserService(this.userDAO, this.cookiesService);

  Future<User?> addOrUpdateUser(
      UserRequestDTO userRequestDTO, String accessToken, String sprylyService,
      {bool isApple = false}) async {
    try {
      Response response = await postUser(userRequestDTO, accessToken,
          sprylyService, isApple: isApple);

      if (response.statusCode == 200) {
        User user = User.fromMap(jsonDecode(response.body));
        await internalAddOrUpdateUser(user);
        await cookiesService.setAppUser(user);
        // successfully created user or user already existed in the system
        await cookiesService.setJWT(response.headers['access-token']);
        return user;
      } else {
        print('Failed to post user ${response.statusCode}');
        return Future.error('Failed to post user ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      return Future.error(e);
    }
  }

  Future<void> internalAddOrUpdateUser(User user) async {
    if (user.id == null) {
      return;
    }
    User? internalUserInfo = await getUserById(user.id!);
    if (internalUserInfo == null) {
      await userDAO.addUser(user);
    } else {
      // update user info
      await userDAO.updateUser(user);
    }
  }

  Future<User?> getUserById(String userId) async {
    return await userDAO.getUserById(userId);
  }


  Future<void> deleteAllUsers() {
    return userDAO.deleteAllUsers();
  }
}
