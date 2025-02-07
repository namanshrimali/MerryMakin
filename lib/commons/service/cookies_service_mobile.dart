import '../dao/user_dao.dart';
import '../models/user.dart';
import '../dao/cookies_dao.dart';
import '../models/cookies.dart';
import '../models/country_currency.dart';
import 'cookie_service.dart';

class CookiesServiceMobile implements CookiesService {
  final CookiesDAO cookiesDAO;
  final UserDAO userDAO;
  
  String? internalLocallyAvailableJwtToken;
  User? internalLocallyAvailableUserInfo;
  CountryCurrency internalLocallyStoredCountryCurrency = CountryCurrency.UnitedStatesDollarUnitedStates;

  CookiesServiceMobile(this.cookiesDAO, this.userDAO,) {
    initializeCookie();
  }

  Future<void> setAppCountryCurrency(CountryCurrency countryCurrency) async {
    internalLocallyStoredCountryCurrency = countryCurrency;
        Cookie? cookie = await cookiesDAO.getCookie();
    if (cookie != null) {
      cookie.defaultCountryCurrency = countryCurrency;
      cookiesDAO.updateCookie(cookie);
    }
  }

  Future<void> setAppUser(User? appUser) async {
    if (appUser == null || appUser.id == null) {
      return;
    }
    internalLocallyAvailableUserInfo = appUser;
    
    Cookie? cookie = await cookiesDAO.getCookie();
    if (cookie != null) {
      cookie.userId = appUser.id;
      cookiesDAO.updateCookie(cookie);
    }
  }

  Future<bool> get isCookiesEmpty {
    return cookiesDAO.isTableEmpty();
  }

  void setDefaultCountryCurrency(CountryCurrency currentCountryCurrency) async {
    Cookie? cookie = await cookiesDAO.getCookie();
    internalLocallyStoredCountryCurrency = currentCountryCurrency;
    if (cookie != null) {
      cookie.defaultCountryCurrency = currentCountryCurrency;
      cookiesDAO.updateCookie(cookie);
    }
  }

  Future<void> setJWT(String? jwtToken) async {
    if (jwtToken == null) {
      print("No JWT token to set");
      return;
    }
    internalLocallyAvailableJwtToken = jwtToken;

    Cookie? cookie = await cookiesDAO.getCookie();

    if (cookie != null) {
      cookie.jwt = jwtToken;
      cookiesDAO.updateCookie(cookie);
    } else {
      Cookie newCookie = Cookie(
          hasOnboarded: true,
          preferences: '',
          jwt: jwtToken,
          defaultCountryCurrency:
              CountryCurrency.UnitedStatesDollarUnitedStates);
      cookiesDAO.insertCookie(newCookie);
    }
  }

  Future<void> initializeCookie() async {
    cookiesDAO.alterTableAddColumnOfINTEGERTypeIfDoesntExist(
        "default_country_currency",
        CountryCurrency.UnitedStatesDollarUnitedStates.index.toString());
    cookiesDAO.alterTableAddColumnOfTEXTTypeIfDoesntExist("jwt", '');
    Cookie? cookie = await cookiesDAO.getCookie();
    if (cookie == null) {
      cookiesDAO.insertCookie(Cookie(
          hasOnboarded: false,
          preferences: '',
          jwt: '',
          defaultCountryCurrency:
              CountryCurrency.UnitedStatesDollarUnitedStates));
    } else {
      internalLocallyStoredCountryCurrency = cookie.defaultCountryCurrency;
      if (cookie.userId != null) {
        internalLocallyAvailableUserInfo = await userDAO.getUserById(cookie.userId!);
      }
      internalLocallyAvailableJwtToken = cookie.jwt;
    }
  }

  Future<void> finishOnboarding() async {
    Cookie? cookie = await cookiesDAO.getCookie();
    if (cookie != null) {
      cookie.hasOnboarded = true;
      cookiesDAO.updateCookie(cookie);
    }
  }

  Future<void> clearCookies() async {
    internalLocallyAvailableJwtToken = null;
    internalLocallyAvailableUserInfo = null;
    internalLocallyStoredCountryCurrency = CountryCurrency.UnitedStatesDollarUnitedStates;
    cookiesDAO.deleteCookie();
  }

  String? get currentJwtToken => internalLocallyAvailableJwtToken;
  User? get currentUser => internalLocallyAvailableUserInfo;
  
  CountryCurrency get currentCountryCurrency => internalLocallyStoredCountryCurrency;
  Future<bool> get hasOnboarded => cookiesDAO.isTableEmpty();
  Future<void> setPreference(String key, String value) => throw UnimplementedError();
  Future<String?> getPreference(String key) => throw UnimplementedError();
  
  @override
  User? get locallyAvailableUserInfo => internalLocallyAvailableUserInfo;
  
  @override
  Future<void> setLocallyStoredCountryCurrency(CountryCurrency countryCurrency) async {
    internalLocallyStoredCountryCurrency = countryCurrency;
  }
  
  @override
  Future<void> setLocallyStoredUser(User user) async {
    internalLocallyAvailableUserInfo = user;
  }
  
  @override
  CountryCurrency get locallyStoredCountryCurrency => internalLocallyStoredCountryCurrency;
}

