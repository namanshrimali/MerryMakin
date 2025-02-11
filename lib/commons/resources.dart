import 'package:merrymakin/commons/service/cookies_service.dart';

String DEV_HOST = "merrymakin.com";
int DEV_PORT = 443;
String SCHEME = "https";
// String DEV_HOST = "localhost";
// int DEV_PORT = 8080;
String DEV_PATH_USERS = "user-service/api/v1/user";
String DEV_PATH_EVENTS = "event-service/api/v1/event";
String IMAGE_REPOSITORY_JSON =
    "https://raw.githubusercontent.com/namanshrimali/merrymakinwebsite/refs/heads/main/assets/images_repository.json";
String DEEP_LINK_BEFRIEND_USER_TEXT =
    "Tap this link to add me as a friend on MerryMakin: http://merrymakin.com/u/${CookiesService.locallyAvailableUserInfo?.userNameForDisplay}";
  