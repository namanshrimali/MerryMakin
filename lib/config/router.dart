import 'package:go_router/go_router.dart';
import 'package:merrymakin/screens/create_event_screen.dart';
import 'package:merrymakin/screens/event_details.dart';
import 'package:merrymakin/screens/base_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const BaseScreen();
      },
    ),
    GoRoute(
      path: '/:id',
      builder: (context, state) {
        final String? eventId = state.pathParameters['id'];
        return EventDetailsScreen(eventId: eventId);
      },
    ),
    // GoRoute(
    //   path: '/edit/:id',
    //   builder: (context, state) {
    //     final String? eventId = state.pathParameters['id'];
    //     return AddOrEditEvent(
    //       eventId: eventId,
    //     );
    //   },
    // ),
    GoRoute(
      path: '/events/new',
      builder: (context, state) {
        return const AddOrEditEvent();
      },
    ),
    GoRoute(
      path: '/events/:id/edit',
      builder: (context, state) {
        final String? eventId = state.pathParameters['id'];
        return AddOrEditEvent(eventId: eventId);
      },
    ),
  ],
);
