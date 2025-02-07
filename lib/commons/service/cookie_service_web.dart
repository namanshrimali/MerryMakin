import 'dart:convert';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:universal_html/html.dart' as html;
import 'package:merrymakin/commons/service/cookie_service.dart';
class CookiesServiceWeb implements CookiesService {
  static const String _jwtKey = 'jwt_token';
  static const String _userKey = 'current_user';
  static const String _countryCurrencyKey = 'country_currency';
  static const String _onboardingKey = 'has_onboarded';
  static const String _prefixKey = 'mm_pref_';

  @override
  Future<void> clearCookies() async {
    html.window.localStorage.clear();
  }

  @override
  CountryCurrency get currentCountryCurrency {
    final data = html.window.localStorage[_countryCurrencyKey];
    if (data == null) {
      return CountryCurrency.UnitedStatesDollarUnitedStates;
    }
    try {
      return fromJson(jsonDecode(data)) ;
    } catch (e) {
      print('Error parsing country currency: $e');
      return CountryCurrency.UnitedStatesDollarUnitedStates;
    }
  }

  @override
  String? get currentJwtToken {
    return html.window.localStorage[_jwtKey];
  }

  @override
  User? get currentUser {
    final data = html.window.localStorage[_userKey];
    if (data == null) return null;
    try {
      return User.fromMap(jsonDecode(data));
    } catch (e) {
      print('Error parsing user data: $e');
      return null;
    }
  }

  @override
  Future<void> finishOnboarding() async {
    html.window.localStorage[_onboardingKey] = 'true';
  }

  @override
  Future<String?> getPreference(String key) async {
    return html.window.localStorage[_prefixKey + key];
  }

  @override
  Future<bool> get hasOnboarded async {
    return html.window.localStorage[_onboardingKey] == 'true';
  }

  @override
  Future<void> initializeCookie() async {
    // No initialization needed for web localStorage
    return;
  }

  @override
  Future<bool> get isCookiesEmpty async {
    return html.window.localStorage.isEmpty;
  }

  @override
  Future<void> setAppCountryCurrency(CountryCurrency countryCurrency) async {
    html.window.localStorage[_countryCurrencyKey] = jsonEncode(countryCurrency.toJson());
  }

  @override
  Future<void> setAppUser(User? appUser) async {
    if (appUser == null) {
      html.window.localStorage.remove(_userKey);
    } else {
      html.window.localStorage[_userKey] = jsonEncode(appUser.toMap());
    }
  }

  @override
  Future<void> setJWT(String? jwtToken) async {
    if (jwtToken == null) {
      html.window.localStorage.remove(_jwtKey);
    } else {
      html.window.localStorage[_jwtKey] = jwtToken;
    }
  }

  @override
  Future<void> setPreference(String key, String value) async {
    html.window.localStorage[_prefixKey + key] = value;
  }

  @override
  User? get locallyAvailableUserInfo {
    final data = html.window.localStorage[_userKey];
    if (data == null) {
      return null;
    }
    try {
      return User.fromMap(jsonDecode(data));
    } catch (e) {
      print('Error parsing locally stored user data: $e');
      throw Exception('Invalid user data stored locally');
    }
  }

  @override
  CountryCurrency get locallyStoredCountryCurrency {
    final data = html.window.localStorage[_countryCurrencyKey];
    if (data == null) {
      return CountryCurrency.UnitedStatesDollarUnitedStates;
    }
    try {
      return fromJson(jsonDecode(data));
    } catch (e) {
      print('Error parsing locally stored country currency: $e');
      return CountryCurrency.UnitedStatesDollarUnitedStates;
    }
  }

  @override
  Future<void> setLocallyStoredCountryCurrency(CountryCurrency countryCurrency) async {
    html.window.localStorage[_countryCurrencyKey] = jsonEncode(countryCurrency.toJson());
  }

  @override
  Future<void> setLocallyStoredUser(User user) async {
    html.window.localStorage[_userKey] = jsonEncode(user.toMap());
  }

  // Helper methods for data validation
  bool _isValidJson(String str) {
    try {
      jsonDecode(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  void _validateUserData(Map<String, dynamic> data) {
    if (!data.containsKey('id') || !data.containsKey('email')) {
      throw Exception('Invalid user data structure');
    }
  }
}