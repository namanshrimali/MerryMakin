import 'package:http/http.dart';
import 'package:merrymakin/commons/api/http.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/event_request_dto.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/factory/app_factory.dart';

import '../commons/models/event.dart';

Future<Response> createEvent(
  EventRequestDTO eventRequestDTO,
  Uri uri,
) async {
  // attempt to add user to the user table
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'access-token': CookiesService.locallyAvailableJwtToken ?? '',
  };

  return await sendPostRequest(
    uri,
    headers,
    eventRequestDTO.toMap(),
  );
}

Future<Response> updateEvent(
  Event event,
  Uri uri,
) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'access-token': CookiesService.locallyAvailableJwtToken ?? '',
  };

  return await sendPatchRequest(uri, headers, event.toMap());
}

Future<Response> addCommentApi(
  String eventId,
  Comment comment,
) async {
  if (CookiesService.locallyAvailableJwtToken == null) {
    await AppFactory().cookiesService.initializeCookie();
  }
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'access-token': CookiesService.locallyAvailableJwtToken ?? '',
  };
  Uri uri = Uri(
      scheme: SCHEME,
      host: DEV_HOST,
      port: DEV_PORT,
      path: "$DEV_PATH_EVENTS/$eventId/comment");
  return await sendPostRequest(uri, headers, comment.toMap());
}


Future<Response> sendRsvpForEvent(
  String eventId,
  RSVPStatus rsvpStatus,
) async {
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'access-token': CookiesService.locallyAvailableJwtToken ?? '',
  };
  Uri uri = Uri(
      scheme: SCHEME,
      host: DEV_HOST,
      port: DEV_PORT,
      path: "$DEV_PATH_EVENTS/$eventId/rsvp",
      query: "rsvpStatus=${rsvpStatus.name}");
  return await sendPostRequest(
    uri,
    headers,
    null,
  );
}

Future<Response> getAllEvents() async {
  if (CookiesService.locallyAvailableJwtToken == null) {
    await Future.delayed(const Duration(seconds: 1));
  }
  Map<String, String> headers = {
    "access-token": CookiesService.locallyAvailableJwtToken ?? ""
  };
  Response response = await sendGetRequest(
    Uri(scheme: SCHEME, host: DEV_HOST, port: DEV_PORT, path: DEV_PATH_EVENTS),
    headers,
  );
  return response;
}

Future<Response> deleteEventFromServer(final String eventId) async {
  Map<String, String> headers = {
    "access-token": CookiesService.locallyAvailableJwtToken ?? ""
  };
  Uri uri = Uri(scheme: SCHEME, host: DEV_HOST, port: DEV_PORT, path: "$DEV_PATH_EVENTS/$eventId");
  return await sendDeleteRequest(uri, headers);
}

Future<Response> getEventById(String eventId) async {
  if (CookiesService.locallyAvailableJwtToken == null) {
    await AppFactory().cookiesService.initializeCookie();
  }
  Map<String, String> headers = {
    "access-token": CookiesService.locallyAvailableJwtToken ?? ""
  };
  Response response = await sendGetRequest(
    Uri(
        scheme: SCHEME,
        host: DEV_HOST,
        port: DEV_PORT,
        path: "$DEV_PATH_EVENTS/$eventId"),
    headers,
  );
  return response;
}

