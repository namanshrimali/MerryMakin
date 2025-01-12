import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/cookies_service.dart';
import 'package:merrymakin/commons/service/image_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/pro_date_time_picker.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:merrymakin/commons/widgets/pro_image_picker.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddOrEditEvent extends ConsumerStatefulWidget {
  final String? eventId;
  AddOrEditEvent({
    super.key,
    this.eventId,
  });

  @override
  ConsumerState<AddOrEditEvent> createState() => _AddOrEditEventState();
}

class _AddOrEditEventState extends ConsumerState<AddOrEditEvent> {
  late Event event;
  late Future<List<dynamic>> _future;
  final ImageService imageService = AppFactory().imageService;
  final _formKey = GlobalKey<FormState>();

  final Map<String, bool> _visibleFields = {
    'spots': false,
    'costPerSpot': false,
    'dressCode': false,
    'food': false,
  };

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
        updatedAt: DateTime.now(), imageUrl: imageService.getRandomImage());

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
    if (spots == null ||
        spots.isEmpty ||
        int.tryParse(spots) == null ||
        int.parse(spots) >= 0) {
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

  List<Widget> _buildEditableField(String fieldName, String hintText) {
    if (_visibleFields[fieldName]!) {
      return [
        const SizedBox(height: generalAppLevelPadding),
        ProTextField(
          hintText: hintText,
          initialValue: _getInitialValue(fieldName),
          onSubmitted: (value) {
            setState(() {
              _updateEventField(fieldName, value);
              _visibleFields[fieldName] = false;
            });
          },
          width: double.infinity,
        ),
      ];
    }
    return [const SizedBox.shrink()];
  }

  String _getInitialValue(String fieldName) {
    switch (fieldName) {
      case 'spots':
        return event.spots?.toString() ?? '';
      case 'costPerSpot':
        return event.costPerSpot?.toString() ?? '';
      case 'dressCode':
        return event.dressCode ?? '';
      case 'food':
        return event.foodSituation ?? '';
      default:
        return '';
    }
  }

  void _updateEventField(String fieldName, String value) {
    switch (fieldName) {
      case 'spots':
        event.spots = int.tryParse(value);
        break;
      case 'costPerSpot':
        event.costPerSpot = double.tryParse(value);
        break;
      case 'dressCode':
        event.dressCode = value;
        break;
      case 'food':
        event.foodSituation = value;
        break;
    }
  }

  void _handleImageSelection() {
    openProBottomModalSheet(
      context,
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: ProImagePicker(
          onImageSelected: (String imageUrl) {
            setState(() {
              event.imageUrl = imageUrl;
            });
            Navigator.pop(context); // Close bottom sheet
          }, imageService: imageService,
        ),
      ),
    );
  }

  Widget _buildEventImage(final double height) {
    return GestureDetector(
      onTap: _handleImageSelection,
      child: Container(
          height: height, // Adjust height as needed
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(generalAppLevelPadding),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(generalAppLevelPadding),
          child: CachedNetworkImage(
                  imageUrl: event.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              ,
        ),
      ),
    );
  }

  Widget buildFormWidget(
    BuildContext context,
  ) {
    String addOrUpdate = event.id == null ? "New" : "Edit";
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
      body: LayoutBuilder(builder: (context, constraints) {
        double height = constraints.maxHeight;
        return Padding(
          padding: const EdgeInsets.only(
              right: generalAppLevelPadding * 2,
              left: generalAppLevelPadding * 2),
          child: Form(
              key: _formKey,
              child: ProListView(height: height, listItems: [
                const SizedBox(
                  height: generalAppLevelPadding / 2,
                ),
                ProTextField(
                  initialValue: event.name,
                  onValidationCallback: validateTitleField,
                  onChanged: (value) {
                    event.name = value;
                  },
                  onSaved: (value) {
                    event.name = value.toString().trim();
                  },
                ),
                const SizedBox(height: generalAppLevelPadding),
                _buildEventImage(height * 0.5),
                const SizedBox(height: generalAppLevelPadding),
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

                ..._buildEditableField('spots', 'Enter number of spots'),
                ..._buildEditableField('costPerSpot', 'Enter cost per spot'),
                ..._buildEditableField('dressCode', 'Enter dress code. Casual, black tie, etc.'),
                ..._buildEditableField('food', 'Enter food situation. BYOB, potluck, etc.'),
                const SizedBox(
                  height: generalAppLevelPadding,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (!_visibleFields['spots']!)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ProOutlinedButton(
                            text: 'Spots',
                            onPressed: () =>
                                setState(() => _visibleFields['spots'] = true),
                          ),
                        ),
                      if (!_visibleFields['costPerSpot']!)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ProOutlinedButton(
                            text: 'Cost per spot',
                            onPressed: () => setState(
                                () => _visibleFields['costPerSpot'] = true),
                          ),
                        ),
                      if (!_visibleFields['dressCode']!)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ProOutlinedButton(
                            text: 'Dress code',
                            onPressed: () => setState(
                                () => _visibleFields['dressCode'] = true),
                          ),
                        ),
                      if (!_visibleFields['food']!)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ProOutlinedButton(
                            text: 'Food situation',
                            onPressed: () =>
                                setState(() => _visibleFields['food'] = true),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: generalAppLevelPadding),
                ProTextField(
                  hintText: 'Add a description of your event',
                  initialValue: event.description,
                  onValidationCallback: validateDescriptionField,
                  onChanged: (value) {
                    event.description = value;
                  },
                  onSaved: (value) {
                    event.description = value.toString().trim();
                  },
                  multiline: true,
                  maxLines: 5,
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
        );
      }),
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

          if (snapshot.data != null &&
              snapshot.data!.isNotEmpty &&
              snapshot.data![0] != null) {
            event = snapshot.data![0];
          }

          return buildFormWidget(context);
        });
  }
}
