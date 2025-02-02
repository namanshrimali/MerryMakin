import 'package:http/http.dart';
import 'package:merrymakin/commons/api/http.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/event_request_dto.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/resources.dart';

import '../commons/models/event.dart';
import '../commons/service/cookie_service.dart';

class EventsApi {
  final CookiesService cookiesService;

  EventsApi(this.cookiesService);
  Future<Response> createEvent(
    EventRequestDTO eventRequestDTO,
    Uri uri,
  ) async {
    // attempt to add user to the user table
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'access-token':
          cookiesService.currentJwtToken ?? '',
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
      'access-token':
          cookiesService.currentJwtToken ?? '',
    };

    return await sendPatchRequest(uri, headers, event.toMap());
  }

  Future<Response> addCommentApi(
    String eventId,
    Comment comment,
  ) async {
    if (cookiesService.currentJwtToken == null) {
      await cookiesService.initializeCookie();
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'access-token':
          cookiesService.currentJwtToken ?? '',
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
      'access-token':
          cookiesService.currentJwtToken ?? '',
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
    if (cookiesService.currentJwtToken == null) {
      await Future.delayed(const Duration(seconds: 1));
    }
    Map<String, String> headers = {
      "access-token":
          cookiesService.currentJwtToken ?? ""
    };
    Response response = await sendGetRequest(
      Uri(
          scheme: SCHEME,
          host: DEV_HOST,
          port: DEV_PORT,
          path: DEV_PATH_EVENTS),
      headers,
    );
    return response;
  }

  Future<Response> deleteEventFromServer(final String eventId) async {
    Map<String, String> headers = {
      "access-token":
          cookiesService.currentJwtToken ?? ""
    };
    Uri uri = Uri(
        scheme: SCHEME,
        host: DEV_HOST,
        port: DEV_PORT,
        path: "$DEV_PATH_EVENTS/$eventId");
    return await sendDeleteRequest(uri, headers);
  }

  Future<Response> getEventById(String eventId) async {
    if (cookiesService.currentJwtToken == null) {
      await cookiesService.initializeCookie();
    }
    Map<String, String> headers = {
      "access-token":
          cookiesService.currentJwtToken ?? ""
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
}
