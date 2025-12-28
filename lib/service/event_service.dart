import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:merrymakin/api/events_api.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/utils/colors.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/factory/app_factory.dart';

final UserService userService = AppFactory().userService;
final EventsApi eventsApi = AppFactory().eventsApi;
List<Event>? eventsCache;

Future<List<Event>> get allEvents async {
  if (eventsCache != null && eventsCache!.isNotEmpty) {
    return eventsCache!;
  }
  return eventsApi.getAllEvents().then((Response response) {
    if (response.statusCode == 200) {
      try {
        final List<Event> eventsFromCloud = List<Event>.from(
            jsonDecode(response.body).map((map) => Event.fromMap(map)));
        eventsCache = eventsFromCloud;
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

Future<List<Color>> getGradientColorsForEvent(final String eventId) async {
  final Event? event = await findEventWithId(eventId);
  if (event != null) {
    return extractSectionDominantColors(event.imageUrl, true);
  }
  return [Colors.black, Colors.black, Colors.black];
}

Future<Event?> findEventWithId(final String eventId) async {
  // Get event from database
  if (eventsCache != null && eventsCache!.isNotEmpty) {
    // return deep copy of event
    return eventsCache!.map((event) => event).firstWhere((event) => event.id == eventId).deepCopy();
  }
  final Response response = await eventsApi.getEventById(eventId);
  if (response.statusCode == 200) {
    Event event = Event.fromMap(jsonDecode(response.body));
    if (eventsCache != null && eventsCache!.isNotEmpty) {
      eventsCache!.removeWhere((event) => event.id == event.id);
      eventsCache!.add(event);
    }
    return event.deepCopy();
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
      if (eventsCache != null && eventsCache!.isNotEmpty) {
        eventsCache!.removeWhere((event) => event.id == event.id);
        eventsCache!.add(event);
      }
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
    if (eventsCache != null && eventsCache!.isNotEmpty) {
      eventsCache!.firstWhere((e) => e.id == event.id).comments?.removeWhere((c) => c.id == comment.id);
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
      final Event updatedEvent = Event.fromMap(jsonDecode(response.body));
      if (eventsCache != null && eventsCache!.isNotEmpty) {
        eventsCache!.map((event) {
          if (event.id == updatedEvent.id) {
            return updatedEvent;
          }
          return event;
        });
      }
      return updatedEvent;
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
      if (eventsCache != null && eventsCache!.isNotEmpty) {
        eventsCache!.add(savedEvent);
      }
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
  if (eventsCache != null && eventsCache!.isNotEmpty) {
    eventsCache!.removeWhere((event) => event.id == eventId);
  }
}

Future<void> sendTextBlastForEvent(final Event event, final String? gifUrl, final String message, final List<String> rsvpStatuses, BuildContext context) {
  // response is a comment that was posted to the event
  return eventsApi.sendTextBlast(event.id!, message, gifUrl, rsvpStatuses).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to send text blast: ${response.body}, ${response.statusCode}');
    }
    return Comment.fromMap(jsonDecode(response.body));
  });
}

Future<Comment?> addReplyToComment(
    final Event event, final String parentCommentId, final Comment reply, BuildContext context) {
  return eventsApi.addReplyToCommentApi(event.id!, parentCommentId, reply).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to add reply: ${response.body}, ${response.statusCode}');
    }
    return Comment.fromMap(jsonDecode(response.body));
  });
}

Future<Comment?> addReactionToComment(
    final Event event, final String commentId, final String emoji, BuildContext context) {
  return eventsApi.addReactionToCommentApi(event.id!, commentId, emoji).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to add reaction: ${response.body}, ${response.statusCode}');
    }
    // Response should contain the updated comment with reactions
    // if (response.body.isNotEmpty) {
    //   return Comment.fromMap(jsonDecode(response.body));
    // }
    return null;
  });
}

Future<void> removeReactionFromComment(
    final Event event, final String commentId, final String emoji, BuildContext context) {
  return eventsApi.removeReactionFromCommentApi(event.id!, commentId, emoji).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to remove reaction: ${response.body}, ${response.statusCode}');
    }
  });
}
