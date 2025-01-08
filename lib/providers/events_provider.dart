import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/crud_operation.dart';
import 'package:merrymakin/commons/models/event.dart';

class EventProviderState {
  Event? event;
  CrudOperation crudOperation;

  EventProviderState({this.event, required this.crudOperation});
}

class EventNotifier extends StateNotifier<EventProviderState> {
  EventNotifier()
      : super(EventProviderState(
          crudOperation: CrudOperation.read,
        ));

  void addNewEvent(Event event) {
    state = EventProviderState(
        crudOperation: CrudOperation.create, event: event);
  }

  void updateEvent(Event event) {
    state = EventProviderState(
        crudOperation: CrudOperation.update, event: event);
  }

  void deleteEvent(Event event) {
    state = EventProviderState(
        crudOperation: CrudOperation.delete, event: event);
  }
}

final eventProvider =
    StateNotifierProvider<EventNotifier, EventProviderState>((ref) {
  return EventNotifier();
});
