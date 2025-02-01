import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:merrymakin/commons/screen/settings_screen.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/screens/create_celebration.dart';
import 'package:merrymakin/screens/create_event_screen.dart';
import 'package:merrymakin/screens/event_details.dart';
import 'package:merrymakin/screens/base_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';
  static const String eventDetails = '/:id';
  static const String newEvent = '/events/new';
  static const String editEvent = '/events/:id/edit';
  static const String newCelebration = '/events/celebration/new';
  static const String editCelebration = '/events/:id/celebration/edit';
  static const String login = '/login';

  static final router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const BaseScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => SettingsScreen(
          userService: AppFactory().userService,
          cookiesService: AppFactory().cookiesService,
          onLogout: () {
            AppFactory().deleteEverything();
          },
        ),
      ),
      GoRoute(
        path: eventDetails,
        name: 'eventDetails',
        builder: (context, state) {
          final String eventId = state.pathParameters['id'] ?? '';
          return EventDetailsScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: newEvent,
        name: 'newEvent',
        builder: (context, state) => AddOrEditEvent(),
      ),
      GoRoute(
        path: editEvent,
        name: 'editEvent',
        builder: (context, state) {
          final String eventId = state.pathParameters['id'] ?? '';
          return AddOrEditEvent(eventId: eventId);
        },
      ),
      GoRoute(
        path: newCelebration,
        name: 'newCelebration',
        builder: (context, state) => AddOrEditCelebration(),
      ),
      GoRoute(
        path: editCelebration,
        name: 'editCelebration',
        builder: (context, state) {
          final String celebrationId = state.pathParameters['id'] ?? '';
          return AddOrEditCelebration(eventId: celebrationId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );

  // Helper methods for navigation
  static void goHome(BuildContext context) {
    context.goNamed('home');
  }

  static void goToSettings(BuildContext context) {
    context.goNamed('settings');
  }

  static void goToEventDetails(BuildContext context, String eventId) {
    context.goNamed('eventDetails', pathParameters: {'id': eventId});
  }

  static void goToNewEvent(BuildContext context) {
    context.goNamed('newEvent');
  }

  static void goToEditEvent(BuildContext context, String eventId) {
    context.goNamed('editEvent', pathParameters: {'id': eventId});
  }

  static void goToNewCelebration(BuildContext context) {
    context.goNamed('newCelebration');
  }

  static void goToEditCelebration(BuildContext context, String celebrationId) {
    context.goNamed('editCelebration', pathParameters: {'id': celebrationId});
  }

  // Helper methods for pushing routes (maintains back stack)
  static void pushEventDetails(BuildContext context, String eventId) {
    context.pushNamed('eventDetails', pathParameters: {'id': eventId});
  }

  static void pushNewEvent(BuildContext context) {
    context.pushNamed('newEvent');
  }

  static void pushEditEvent(BuildContext context, String eventId) {
    context.pushNamed('editEvent', pathParameters: {'id': eventId});
  }

  static void goToLogin(BuildContext context) {
    context.pushNamed('login');
  }
}
