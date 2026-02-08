import 'package:merrymakin/commons/api/http.dart';
import 'package:merrymakin/commons/models/otp_request_dto.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookie_service.dart';

/// API service for OTP verification operations
/// Handles requesting and verifying OTP codes
class OtpApi {
  final CookiesService cookiesService;

  OtpApi(this.cookiesService);

  /// Request OTP code to be sent to the provided phone number
  /// Returns true if request was successful
  Future<bool> requestOtp(String phoneNumber) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'access-token': cookiesService.currentJwtToken ?? '',
      };

      final uri = Uri(
        scheme: SCHEME,
        host: DEV_HOST,
        port: DEV_PORT,
        path: "$DEV_PATH_LOGIN_V2/otp/request",
      );

      final response = await sendPostRequest(
        uri,
        headers,
        OtpRequestDTO(areaCode: '+1', phoneNumber: phoneNumber).toMap(),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error requesting OTP: $e');
      return false;
    }
  }

  /// Verify the OTP code for the provided phone number
  /// Returns true if verification was successful
  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'access-token': cookiesService.currentJwtToken ?? '',
      };

      final uri = Uri(
        scheme: SCHEME,
        host: DEV_HOST,
        port: DEV_PORT,
        path: "$DEV_PATH_USERS/otp/verify",
      );

      final response = await sendPostRequest(
        uri,
        headers,
        {
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  /// Resend OTP code to the provided phone number
  /// Returns true if resend was successful
  Future<bool> resendOtp(String phoneNumber) async {
    return requestOtp(phoneNumber);
  }
}

