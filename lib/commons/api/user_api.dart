import 'dart:convert';

import 'package:http/http.dart';
import '../models/user.dart';
import './http.dart';
import '../models/user_request_dto.dart';
import '../resources.dart';

Future<Response> postUser(
    UserRequestDTO userRequestDTO, String accessToken, String sprylyService,
    {bool isApple = false}) async {
  // attempt to add user to the user table
  Map<String, String> headers;
  if (isApple) {
    headers = {
      'Content-Type': 'application/json',
      'access-token-apple': accessToken,
      'spryly-service': sprylyService,
    };
  } else {
    headers = {
      'Content-Type': 'application/json',
      'access-token-google': accessToken,
      'spryly-service': sprylyService,
    };
  }

  return await sendPostRequest(
    Uri(scheme: 'http', host: DEV_HOST, port: DEV_PORT, path: DEV_PATH_USERS),
    headers,
    userRequestDTO.toMap(),
  );
}

Future<User?> findByUsername(final String username, final String? jwtToken) async {
  Map<String, String> headers = {"access-token": jwtToken ?? ""};
  Response response = await sendGetRequest(
    Uri(
        scheme: 'http',
        host: DEV_HOST,
        port: DEV_PORT,
        path: DEV_PATH_USERS + "/${username}"),
    headers,
  );
  return response.statusCode == 200
      ? User.fromMap(jsonDecode(response.body))
      : null;
}