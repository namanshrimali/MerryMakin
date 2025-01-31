
import '../models/country_currency.dart';
import '../models/user.dart';

abstract class CookiesService {
  // JWT Token management
  Future<void> setJWT(String? jwtToken);
  String? get currentJwtToken;
  
  // User management
  Future<void> setAppUser(User? appUser);
  User? get currentUser;
  
  // Country/Currency management
  Future<void> setAppCountryCurrency(CountryCurrency countryCurrency);
  CountryCurrency get currentCountryCurrency;
  
  // Onboarding status
  Future<bool> get hasOnboarded;
  Future<void> finishOnboarding();
  
  // Cookie management
  Future<bool> get isCookiesEmpty;
  Future<void> clearCookies();
  
  // Initialization
  Future<void> initializeCookie();
  
  // Optional: Add methods for cookie preferences if needed
  Future<void> setPreference(String key, String value);
  Future<String?> getPreference(String key);

  // Local storage
  Future<void> setLocallyStoredCountryCurrency(CountryCurrency countryCurrency);
  CountryCurrency get locallyStoredCountryCurrency;

  Future<void> setLocallyStoredUser(User user);
  User get locallyAvailableUserInfo;
}

// Optional: Add common exceptions
class CookieServiceException implements Exception {
  final String message;
  CookieServiceException(this.message);
  
  @override
  String toString() => 'CookieServiceException: $message';
}

class CookieNotFoundException extends CookieServiceException {
  CookieNotFoundException() : super('Cookie not found');
}

class InvalidCookieDataException extends CookieServiceException {
  InvalidCookieDataException(String detail) : super('Invalid cookie data: $detail');
}