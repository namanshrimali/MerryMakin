import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:merrymakin/api/events_api.dart';
import 'package:merrymakin/commons/dao/user_dao.dart';
import 'package:merrymakin/commons/dao/cookies_dao.dart';
import 'package:merrymakin/commons/notification/event_live_activity_controller.dart';
import 'package:merrymakin/commons/notification/event_notification_scheduler.dart';
import 'package:merrymakin/commons/notification/notification_scheduler.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';
import 'package:merrymakin/commons/service/image_service.dart';
import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/service/cookies_service_mobile.dart';
import 'package:sqflite/sqflite.dart';

import '../commons/service/cookie_service_web.dart';

class AppFactory {
  static AppFactory? _instance;
  late final Database _database;

  // late final EventsDao eventDao;
  // late final EventToAttendeeDao eventToAttendeeDao;
  // late final EventToHostDao eventToHostDao;
  late final UserDAO userDAO;
  late final CookiesDAO cookiesDAO;
  late final UserService userService;
  late final CookiesService cookiesService;
  late final ImageService imageService;
  late final ImageService userIconService;
  late final EventsApi eventsApi;
  late final Function deleteEverything;
  late final ImageService gifService;
  late final NotificationScheduler notificationScheduler;
  late final EventLiveActivityController? liveActivityController;

  factory AppFactory.forFirstTimeMobile(Database database) {
    _instance ??= AppFactory._forMobile(database);
    return _instance!;
  }

  factory AppFactory.forFirstTimeWeb() {
    _instance ??= AppFactory._forWeb();
    return _instance!;
  }

  factory AppFactory() {
    return _instance!;
  }

  AppFactory._forMobile(this._database) {
    userDAO = UserDAO(_database);
    cookiesDAO = CookiesDAO(_database);
    cookiesService = CookiesServiceMobile(cookiesDAO, userDAO);
    userService = UserService(cookiesService);
    // Initialize image service
    imageService = ImageService(IMAGE_REPOSITORY_JSON, cookiesService);
    userIconService = ImageService(USER_ICON_REPOSITORY_JSON, cookiesService);
    gifService = ImageService(GIF_REPOSITORY_JSON, cookiesService);
    eventsApi = EventsApi(cookiesService);
    notificationScheduler = kIsWeb
        ? NoOpNotificationScheduler()
        : EventNotificationScheduler();
    liveActivityController = (kIsWeb || !Platform.isIOS)
        ? null
        : EventLiveActivityController(appGroupId: 'group.com.namanshrimali.merrymakin');
    deleteEverything = () {
      notificationScheduler.cancelAll();
      liveActivityController?.endAll();
      cookiesService.clearCookies();
      userService.deleteAllUsers();
    };
  }

  AppFactory._forWeb() {
    cookiesService = CookiesServiceWeb();
    userService = UserService(cookiesService);
    imageService = ImageService(IMAGE_REPOSITORY_JSON, cookiesService);
    userIconService = ImageService(USER_ICON_REPOSITORY_JSON, cookiesService);
    gifService = ImageService(GIF_REPOSITORY_JSON, cookiesService);

    eventsApi = EventsApi(cookiesService);
    notificationScheduler = NoOpNotificationScheduler();
    liveActivityController = null;
    deleteEverything = () {
      cookiesService.clearCookies();
      // userService.deleteAllUsers();
    };
  }
}
