import 'package:merrymakin/commons/dao/user_dao.dart';
import 'package:merrymakin/commons/dao/cookies_dao.dart';
import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
// import 'package:merrymakin/dao/event_to_attendee_dao.dart';
// import 'package:merrymakin/dao/event_to_host_dao.dart';
import 'package:merrymakin/dao/events_dao.dart';
import 'package:sqflite/sqflite.dart';

class AppFactory {
  static AppFactory? _instance;
  late final Database _database;

  late final EventsDao eventDao;
  // late final EventToAttendeeDao eventToAttendeeDao;
  // late final EventToHostDao eventToHostDao;
  late final UserDAO userDAO;
  late final CookiesDAO cookiesDAO;
  late final UserService userService;
  late final CookiesService cookiesService;
  factory AppFactory.forFirstTime(Database database) {
    _instance ??= AppFactory._(database);
    return _instance!;
  }

  factory AppFactory() {
    return _instance!;
  }

  AppFactory._(this._database) {
    eventDao = EventsDao(_database);
    // eventToAttendeeDao = EventToAttendeeDao(_database);
    // eventToHostDao = EventToHostDao(_database);
    userDAO = UserDAO(_database);
    cookiesDAO = CookiesDAO(_database);
    cookiesService = CookiesService(cookiesDAO, userDAO);
    userService = UserService(userDAO, cookiesService);
  }
}
