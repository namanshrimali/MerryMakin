import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:merrymakin/api/events_api.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/factory/app_factory.dart';

final UserService userService = AppFactory().userService;
final EventsApi eventsApi = AppFactory().eventsApi;

Future<List<Event>> get allEvents async {
  return eventsApi.getAllEvents().then((Response response) {
    if (response.statusCode == 200) {
      try {
        final List<Event> eventsFromCloud = List<Event>.from(
            jsonDecode(response.body).map((map) => Event.fromMap(map)));
        return eventsFromCloud;
      } catch (e) {
        print(e);
        return Future.error(e);
      }
    } else {
      return Future.error(
          'Failed to get events ${response.body}, ${response.statusCode}');
    }
  });
}

Future<Event?> findEventWithId(final String eventId) async {
  // Get event from database
  final Response response = await eventsApi.getEventById(eventId);
  if (response.statusCode == 200) {
    Event event = Event.fromMap(jsonDecode(response.body));
    return event;
  }
  return Future.error(
      'Failed to get event: ${response.body}, ${response.statusCode}');
}

Future<void> rsvpForEvent(
  final Event event,
  final List<String> plusOnes,
  final RSVPStatus rsvpStatus,
) {

  return eventsApi.sendRsvpForEvent(event.id!, plusOnes, rsvpStatus).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to RSVP: ${response.body}, ${response.statusCode}');
    }
  });
}

Future<Comment?> addCommentToEvent(
    final Event event, final Comment comment, BuildContext context) {
  return eventsApi.addCommentApi(event.id!, comment).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to Comment: ${response.body}, ${response.statusCode}');
    }
    return Comment.fromMap(jsonDecode(response.body));
  });
}

Future<void> deleteCommentFromEvent(final Event event, final Comment comment, BuildContext context) {
  return eventsApi.deleteCommentFromEventApi(event.id!, comment.id!).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to delete comment: ${response.body}, ${response.statusCode}');
    }
  });
}

Future<Event?> addOrUpdateEvent(final Event event, BuildContext context) {
  if (event.id == null) {
    return _addEvent(event, context);
  }
  return _updateEvent(event, context);
}

Future<Event?> _updateEvent(final Event event, BuildContext context) {
  final Uri uri = Uri(
      scheme: SCHEME,
      host: DEV_HOST,
      port: DEV_PORT,
      path: '$DEV_PATH_EVENTS/${event.id!}');
  return eventsApi.updateEvent(event, uri).then((Response response) {
    if (response.statusCode == 200) {
      return Event.fromMap(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        showSnackBar(context,
            'Failed to save event, ${response.body}, ${response.statusCode}');
      }
    }
    return Future.error('Event cannot be updated');
  });
}

Future<Event?> _addEvent(final Event event, BuildContext context) async {
  final Uri uri = Uri(
      scheme: SCHEME, host: DEV_HOST, port: DEV_PORT, path: DEV_PATH_EVENTS);
  return eventsApi
      .createEvent(event.toEventRequestDTO(), uri)
      .then((Response response) {
    if (response.statusCode == 200) {
      final Event savedEvent = Event.fromMap(jsonDecode(response.body));
      return savedEvent;
    } else {
      if (context.mounted) {
        showSnackBar(context,
            'Failed to save event: ${response.body}, ${response.statusCode}');
      }
    }
    return Future.error(
        'Failed to save event, ${response.body}, ${response.statusCode}');
  });
}

Future<void> deleteEvent(String eventId) async {
  await eventsApi.deleteEventFromServer(eventId);
  // await eventsDao.delete(eventId.toString());
}
