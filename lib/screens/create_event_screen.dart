import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/country_currency.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_date_time_picker.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/service/event_service.dart';

class AddOrEditEvent extends ConsumerStatefulWidget {
  final String? eventId;

  const AddOrEditEvent({
    super.key,
    this.eventId,
  });

  @override
  ConsumerState<AddOrEditEvent> createState() => _AddOrEditEventState();
}

class _AddOrEditEventState extends ConsumerState<AddOrEditEvent> {
  late Event event;
  late Future<List<dynamic>> _future;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    event = Event(
        name: 'Untitled Event',
        hosts: CookiesService.locallyAvailableUserInfo != null
            ? [CookiesService.locallyAvailableUserInfo!]
            : [],
        countryCurrency: CookiesService.locallyStoredCountryCurrency,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());

    Future eventFuture = Future<void>(() {}); // initialize with empty future
    if (widget.eventId != null) {
      eventFuture = findEventWithId(widget.eventId!);
    }
    _future = Future.wait([eventFuture]);
  }

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      addOrUpdateEvent(event, context).then((dbReturnedEvent) {
        if (dbReturnedEvent != null) {
          if (event.id == null) {
            ref.read(eventProvider.notifier).addNewEvent(dbReturnedEvent);
          } else {
            ref.read(eventProvider.notifier).updateEvent(dbReturnedEvent);
          }
          Navigator.pop(context, dbReturnedEvent);
        }
      });
    }
  }

  void onChangedCostPerSpot(value) {
    setState(() {
      event.costPerSpot = value;
    });
  }

  void onSelectDate(DateTime value) {
    event.startDateTime = value;
  }

  String? validateAmountField(String? amount) {
    // final double _enteredAmount = double.parse(_amountController.text);
    if (amount != null &&
        amount.isEmpty &&
        double.tryParse(amount) != null &&
        double.tryParse(amount)! < 0) {
      return 'Amount must be a valid positive number';
    }
    return null;
  }

  String? validateSpotsField(String? spots) {
    // final double _enteredAmount = double.parse(_amountController.text);
    if (spots == null || spots.isEmpty || int.tryParse(spots) == null || int.parse(spots) >= 0) {
      return null;
    }
    return '# spots must be a valid positive number';
  }

  String? validateTitleField(String? text) {
    // final double _enteredAmount = double.parse(_amountController.text);
    if (text == null ||
        text.isEmpty ||
        text.trim().length <= 2 ||
        text.trim().length > 50) {
      return 'Title must be between 2 and 50 characters';
    }
    return null;
  }

  String? validateLocationField(String? text) {
    // final double _enteredAmount = double.parse(_amountController.text);
    if (text != null && text.isNotEmpty && text.trim().length <= 2) {
      return 'Location must be at least 2 characters long';
    }
    return null;
  }

  String? validateDescriptionField(String? text) {
    if (text != null &&
        text.isNotEmpty &&
        text.trim().length <= 2 &&
        text.trim().length > 100) {
      return 'Description must be between 2 and 100 characters';
    }
    return null;
  }

  Widget buildFormWidget(
    BuildContext context,
  ) {
    String addOrUpdate = event.id == null ? "New" : "Edit";
    String costPerSpotLabelText = 'Cost per spot';
    String totalSpotsText = 'Number of Spots';
    String titleText = '$addOrUpdate Event';

    return Scaffold(
      appBar: AppBar(
        title: ProText(titleText),
        actions: [
          TextButton(
            onPressed: () => _submitData(context),
            child: const Text("Save"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            right: generalAppLevelPadding * 2,
            left: generalAppLevelPadding * 2),
        child: Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: generalAppLevelPadding / 2,
                  ),
                  ProTextField(
                    label: 'Title',
                    initialValue: event.name,
                    onValidationCallback: validateTitleField,
                    onChanged: (value) {
                      event.name = value;
                    },
                    onSaved: (value) {
                      event.name = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: generalAppLevelPadding,
                  ),
                  ProDateTimePicker(
                      initialValue: event.startDateTime,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2100),
                      hintText: 'Set date and time',
                      onDateTimeSelected: onSelectDate),
                  const SizedBox(
                    height: generalAppLevelPadding,
                  ),
                  ProTextField(
                    label: 'Location',
                    hintText: 'Place name, address or link',
                    initialValue: event.location,
                    onValidationCallback: validateLocationField,
                    onChanged: (value) {
                      event.location = value;
                    },
                    onSaved: (value) {
                      event.location = value.toString().trim();
                    },
                  ),
                  const SizedBox(
                    height: generalAppLevelPadding,
                  ),
                  ProTextField(
                    label: totalSpotsText,
                    hintText: 'Leave blank for unlimited spots',
                    onChanged: (value) {
                      if (int.tryParse(value) != null) {
                        event.spots = int.parse(value);
                      }
                    },
                    initialValue:
                        event.spots == null ? '' : event.spots.toString(),
                    onValidationCallback: validateSpotsField,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: false, signed: false),
                    onSaved: (value) {
                      if (int.tryParse(value) != null) {
                        event.spots = int.parse(value);
                      }
                    },
                    autofocus: true,
                  ),
                  const SizedBox(
                    height: generalAppLevelPadding,
                  ),
                  ProTextField(
                    label: costPerSpotLabelText,
                    onChanged: (value) {
                      if (double.tryParse(value) != null) {
                        event.costPerSpot = double.parse(value);
                      }
                    },
                    initialValue: event.costPerSpot == null
                        ? ''
                        : event.costPerSpot.toString(),
                    onValidationCallback: validateAmountField,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: false),
                    onSaved: (value) {
                      if (int.tryParse(value) != null) {
                        event.costPerSpot = double.parse(value);
                      }
                    },
                    prefixWidget: Text(
                        "${CookiesService.locallyStoredCountryCurrency.getCurrencySymbol()} "),
                    autofocus: true,
                  ),
                  const SizedBox(
                    height: generalAppLevelPadding,
                  ),
                  ProTextField(
                    label: 'Description',
                    hintText: 'Add a description of your event',
                    initialValue: event.description,
                    onValidationCallback: validateDescriptionField,
                    onChanged: (value) {
                      event.description = value;
                    },
                    onSaved: (value) {
                      event.description = value.toString().trim();
                    },
                  ),

                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     if (event.id != null &&
                  //         widget.deleteTransaction != null)
                  //       IconButton(
                  //           onPressed: widget.deleteTransaction!,
                  //           color: const Color.fromARGB(255, 255, 81, 69),
                  //           icon: const Icon(Icons.delete)),
                  //   ],
                  // ),
                ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if ((snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != null && snapshot.data!.isNotEmpty && snapshot.data![0] != null) {
            event = snapshot.data![0];
          }

          return buildFormWidget(context);
        });
  }
}
