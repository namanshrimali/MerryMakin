import '../dao/user_dao.dart';
import '../models/user.dart';
import '../dao/cookies_dao.dart';
import '../models/cookies.dart';
import '../models/country_currency.dart';

class CookiesService {
  final CookiesDAO cookiesDAO;
  final UserDAO userDAO;
  
  static String? locallyAvailableJwtToken;
  static User? locallyAvailableUserInfo;
  static CountryCurrency locallyStoredCountryCurrency = CountryCurrency.UnitedStatesDollarUnitedStates;

  CookiesService(this.cookiesDAO, this.userDAO,) {
    initializeCookie();
  }

  Future<void> setAppCountryCurrency(CountryCurrency countryCurrency) async {
    locallyStoredCountryCurrency = countryCurrency;
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
    locallyAvailableUserInfo = appUser;
    
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
    locallyStoredCountryCurrency = currentCountryCurrency;
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
    locallyAvailableJwtToken = jwtToken;

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
      locallyStoredCountryCurrency = cookie.defaultCountryCurrency;
      if (cookie.userId != null) {
        locallyAvailableUserInfo = await userDAO.getUserById(cookie.userId!);
      }
      locallyAvailableJwtToken = cookie.jwt;
    }
  }

  void finishOnboarding() async {
    Cookie? cookie = await cookiesDAO.getCookie();
    if (cookie != null) {
      cookie.hasOnboarded = true;
      cookiesDAO.updateCookie(cookie);
    }
  }

  void clearCookies() {
    locallyAvailableJwtToken = null;
    locallyAvailableUserInfo = null;
    locallyStoredCountryCurrency = CountryCurrency.UnitedStatesDollarUnitedStates;
    cookiesDAO.deleteCookie();
  }
}
