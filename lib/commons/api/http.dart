import 'package:http/http.dart' as http;
import 'dart:convert';

Future<http.Response> sendGetRequest(
    final Uri url, final Map<String, String> headers) async {
  try {
    return http.get(url, headers: headers);
  } catch (e) {
    // Handle error cases here, such as a network error or server error.
    print('Error: $e');
    Future.error(e);
  }
  return Future.error("");
}

Future<http.Response> sendPostRequest(final Uri url,
    final Map<String, String> headers, final Map<String, dynamic>? body) {
  // Encode the body as JSON
  String? jsonBody;
  if (body != null) {
    jsonBody = json.encode(body);
  }

  try {
    // Send the POST request
    return http.post(
      url,
      headers: headers,
      body: jsonBody,
    );
  } catch (e) {
    // Error occurred during the request
    print(e);
    return Future.error(e);
  }
}

Future<http.Response> sendPatchRequest(final Uri url,
    final Map<String, String> headers, final Map<String, dynamic>? body) {
  String? jsonBody;
  if (body != null) {
    jsonBody = json.encode(body);
  }
  try {
    return http.patch(url, headers: headers, body: jsonBody);
  } catch (e) {
    print(e);
    return Future.error(e);
  }
}

Future<http.Response> sendDeleteRequest(final Uri url, final Map<String, String> headers) {
  try {
    return http.delete(url, headers: headers);
  } catch (e) {
    print(e);
    return Future.error(e);
  }
}