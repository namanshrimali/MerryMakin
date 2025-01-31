import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:merrymakin/api/events_api.dart';
import 'package:merrymakin/commons/models/comment.dart';
import 'package:merrymakin/commons/models/event.dart';
// import 'package:merrymakin/commons/models/event_to_attendee.dart';
// import 'package:merrymakin/commons/models/event_to_host.dart';
import 'package:merrymakin/commons/models/rsvp.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
// import 'package:merrymakin/dao/event_to_attendee_dao.dart';
// import 'package:merrymakin/dao/event_to_host_dao.dart';
// import 'package:merrymakin/dao/events_dao.dart';
import 'package:merrymakin/factory/app_factory.dart';

// final EventToHostDao eventToHostDao = AppFactory().eventToHostDao;
final UserService userService = AppFactory().userService;
// final EventsDao eventsDao = AppFactory().eventDao;
// final EventToAttendeeDao eventToAttendeeDao = AppFactory().eventToAttendeeDao;
final EventsApi eventsApi = AppFactory().eventsApi;
Future<List<Event>> get allEvents async {
  return eventsApi.getAllEvents().then((Response response) {
    if (response.statusCode == 200) {
      try {
        final List<Event> eventsFromCloud = List<Event>.from(
            jsonDecode(response.body).map((map) => Event.fromMap(map)));
        // deleteAllEvents();
        for (Event event in eventsFromCloud) {
          _saveUsersToDatabase(event);
        }
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
        _saveUsersToDatabase(event);
        return event;
    }
    return Future.error('Failed to get event: ${response.body}, ${response.statusCode}');

  // try {
  //   Event? event = await eventsDao.getEventWithId(eventId);
  //   if (event == null) {
  //     // database event is not found, get it from cloud
      
  //   }

  //   event.hosts = await _getHostsForEvent(eventId);
  //   event.eventToAttendees =
  //       await eventToAttendeeDao.getEventToAttendeesForEvent(eventId);
  //   _populateAttendeesForEvent(event);
  //   return event;
  // } catch (e) {
  //   print(e);
  //   return Future.error(e);
  // }
}

// Future<String?> getRsvpForEvent(final String eventId, final User? user) async {
//   if (user == null || user.id == null) {
//     return null;
//   }
//   EventToAttendee? eventToAttendee =
//       await eventToAttendeeDao.queryForEventAndUser(eventId, user.id!);
//   return eventToAttendee?.rsvpStatus;
// }

Future<void> rsvpForEvent(
  final Event event,
  final RSVPStatus rsvpStatus,
  final User? user,
) {
  if (user == null || user.id == null) {
    return Future.error('Please login to RSVP');
  }


  return eventsApi.sendRsvpForEvent(event.id!, rsvpStatus).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to RSVP: ${response.body}, ${response.statusCode}');
      // EventToAttendee eventToAttendee = EventToAttendee(
      //     eventId: event.id!, userId: user.id!, rsvpStatus: rsvpStatus.name);
      // _addOrUpdateRsvpForEvent(eventToAttendee);
    } 
  });
}

Future<void> addCommentToEvent(final Event event, final Comment comment, BuildContext context) {
  return eventsApi.addCommentApi(event.id!, comment).then((response) {
    if (response.statusCode != 200) {
      return Future.error(
          'Failed to Comment: ${response.body}, ${response.statusCode}');
    } 
  });
}

// Future<int?> _addOrUpdateRsvpForEvent(
//     final EventToAttendee eventToAttendee) async {
//   try {
//     await eventToAttendeeDao.delete(
//         eventToAttendee.eventId, eventToAttendee.userId);
//   } catch (error) {
//     print(error);
//   }
//   return eventToAttendeeDao.insert(eventToAttendee);
// }

Future<Event?> addOrUpdateEvent(final Event event, BuildContext context) {
  if (event.id == null) {
    return _addEvent(event, context);
  }
  return _updateEvent(event, context);
}

Future<Event?> _updateEvent(final Event event, BuildContext context) {
  final Uri uri = Uri(
      scheme: SCHEME, host: DEV_HOST, port: DEV_PORT, path: '$DEV_PATH_EVENTS/${event.id!}');
  return eventsApi.updateEvent(event, uri)
      .then((Response response) {
    if (response.statusCode == 200) {
      final Event savedEvent = Event.fromMap(jsonDecode(response.body));
      return _saveUsersToDatabase(savedEvent).onError((error, stackTrace) {
        if (context.mounted) {
          showSnackBar(context, error.toString());
        }
        return savedEvent;
      });
    } else {
      if (context.mounted) {
          showSnackBar(context, 'Failed to save event, ${response.body}, ${response.statusCode}');
      }
    }
    return Future.error('Event cannot be updated');
  });
}

Future<Event?> _addEvent(final Event event, BuildContext context) async {
  final Uri uri = Uri(
      scheme: SCHEME, host: DEV_HOST, port: DEV_PORT, path: DEV_PATH_EVENTS);
  return eventsApi.createEvent(event.toEventRequestDTO(), uri)
      .then((Response response) {
    if (response.statusCode == 200) {
      final Event savedEvent = Event.fromMap(jsonDecode(response.body));
      _saveUsersToDatabase(
        savedEvent,
      ).onError((error, stackTrace) {
        if (context.mounted) {
          showSnackBar(context, error.toString());
        }
        return savedEvent;
      });
      return savedEvent;
    } else {
      if (context.mounted) {
        showSnackBar(context, 'Failed to save event: ${response.body}, ${response.statusCode}');
      }
    }
    return Future.error(
        'Failed to save event, ${response.body}, ${response.statusCode}');
  });
}

// Future<Event> _updateEventInDatabase(final Event event) async {
//   try {
//     await eventsDao.update(event);
//     if (event.attendees != null) {
//       for (var user in event.attendees!) {
//         await userService.internalAddOrUpdateUser(user);
//       }
//     }
//     if (event.eventToAttendees != null) {
//       if (event.eventToAttendees != null) {
//         for (EventToAttendee eventToAttendee in event.eventToAttendees!) {
//           try {
//             eventToAttendeeDao.insert(EventToAttendee(
//                 eventId: event.id!,
//                 userId: eventToAttendee.userId,
//                 rsvpStatus: eventToAttendee.rsvpStatus));
//           } catch (e) {
//             print(e);
//           }
//         }
//       }
//     }
//     for (var user in event.hosts) {
//       await userService.internalAddOrUpdateUser(user);
//       try {
//         eventToHostDao
//             .insert(EventToHost(eventId: event.id!, userId: user.id!));
//       } catch (e) {
//         print(e);
//       }
//     }
//   } catch (e) {
//     print(e);
//     return Future.error(e);
//   }
//   return event;
// }

Future<Event> _saveUsersToDatabase(final Event event) async {
  try {
    // await eventsDao.insert(event);
    if (event.attendees != null) {
      for (var attendee in event.attendees!) {
        await userService.internalAddOrUpdateUser(attendee.user);
      }
    }
    // if (event.eventToAttendees != null) {
    //   for (EventToAttendee eventToAttendee in event.eventToAttendees!) {
    //     try {
    //       eventToAttendeeDao.insert(EventToAttendee(
    //           eventId: event.id!,
    //           userId: eventToAttendee.userId,
    //           rsvpStatus: eventToAttendee.rsvpStatus));
    //     } catch (e) {
    //       print(e);
    //     }
    //   }
    // }
    for (var user in event.hosts) {
      await userService.internalAddOrUpdateUser(user);
      // try {
      //   eventToHostDao
      //       .insert(EventToHost(eventId: event.id!, userId: user.id!));
      // } catch (e) {
      //   print(e);
      // }
    }
    return event;
  } catch (e) {
    print(e);
    return Future.error(e);
  }
}

Future<void> deleteEvent(String eventId) async {
  await eventsApi.deleteEventFromServer(eventId);
  // await eventsDao.delete(eventId.toString());
}

// Future<List<User>> _getHostsForEvent(final String eventId) async {
//   try {
//     final List<EventToHost> eventToHostForEventList =
//         await eventToHostDao.getHostsForEvent(eventId);
//     List<User> hosts = [];
//     for (EventToHost eventToHost in eventToHostForEventList) {
//       final User? user = await userService.getUserById(eventToHost.userId);
//       if (user != null) {
//         hosts.add(user);
//       }
//     }
//     return hosts;
//   } catch (e) {
//     print(e);
//     return Future.error(e);
//   }
// }

// void _populateAttendeesForEvent(final Event event) async {
//   try {
//     event.eventToAttendees =
//         await eventToAttendeeDao.getEventToAttendeesForEvent(event.id!);
//     if (event.eventToAttendees != null) {
//       List<User> guests = [];

//       for (EventToAttendee eventToAttendee in event.eventToAttendees!) {
//         final String userId = eventToAttendee.userId;
//         final User? user = await userService.getUserById(userId);
//         if (user != null) {
//           guests.add(user);
//         }
//       }
//       event.attendees = guests;
//     }
//   } catch (e) {
//     print(e);
//     return Future.error(e);
//   }
// }

// void deleteAllEvents() {
//   eventsDao.deleteAll();
//   // eventToAttendeeDao.deleteAll();
//   // eventToHostDao.deleteAll();
// }
