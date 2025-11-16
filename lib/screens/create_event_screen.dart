import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/service/image_service.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/utils/date_time.dart';
import 'package:merrymakin/commons/utils/colors.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_outlined_button.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/commons/widgets/pro_date_time_picker.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/providers/events_provider.dart';
import 'package:merrymakin/service/event_service.dart';
import 'package:merrymakin/commons/widgets/pro_image_picker.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:merrymakin/commons/widgets/pro_theme_effects.dart';
import 'package:merrymakin/widgets/ai_enabled_description.dart';
import '../commons/service/cookie_service.dart';
import '../commons/widgets/pro_font_selector.dart';

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
  ProThemeType? selectedTheme;
  ProEffectType? selectedEffect;
  ProFontType? selectedFont;
  ThemeData defaultTheme = ProThemes.themes[ProThemeType.midnight]!.theme;
  ProThemeType defaultThemeType = ProThemeType.midnight;
  ProEffectType defaultEffect = ProEffectType.none;
  final CookiesService cookiesService = AppFactory().cookiesService;
  late final FocusNode _eventNameFocusNode;
  late final TextEditingController _descriptionController;
  bool _hasSyncedDescription = false;
  Color? _gradientColor;
  List<Color> _gradientColors = [Colors.black, Colors.black, Colors.black];
  String? _lastImageUrl;

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
        startDateTime: getNextSaturdayAt7pmUtc(),
        hosts: cookiesService.currentUser != null
            ? [cookiesService.currentUser!]
            : [],
        countryCurrency: cookiesService.locallyStoredCountryCurrency,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        imageUrl: imageService.getRandomImage(),
        effect: defaultEffect.toString(),
        theme: defaultThemeType.toString());
    _eventNameFocusNode = FocusNode();
    _eventNameFocusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _descriptionController =
        TextEditingController(text: event.description ?? '');
    _descriptionController.addListener(() {
      event.description = _descriptionController.text;
    });
    _hasSyncedDescription = widget.eventId == null;

    Future eventFuture = Future<void>(() {}); // initialize with empty future
    if (widget.eventId != null) {
      eventFuture = findEventWithId(widget.eventId!);
    }
    _future = Future.wait([eventFuture]);
    
    // Initialize gradient from initial image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeGradient();
      }
    });
  }

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      event.theme = selectedTheme.toString();

      addOrUpdateEvent(event, context).then((dbReturnedEvent) {
        if (dbReturnedEvent != null) {
          if (event.id == null) {
            ref.read(eventProvider.notifier).addNewEvent(dbReturnedEvent);
          } else {
            ref.read(eventProvider.notifier).updateEvent(dbReturnedEvent);
          }
          AppRouter.goToEventDetails(context, dbReturnedEvent.id!);
        }
      });
    }
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

  String? validateDressCodeField(String? dressCode) {
    if (dressCode == null ||
        dressCode.isEmpty ||
        dressCode.trim().length >= 2) {
      return null;
    }
    return 'Dress code must be at least 2 characters long';
  }

  String? validateFoodSituationField(String? foodSituation) {
    if (foodSituation == null ||
        foodSituation.isEmpty ||
        foodSituation.trim().length >= 2) {
      return null;
    }
    return 'Food situation must be at least 2 characters long';
  }

  String? validateSpotsField(String? spots) {
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

  String? _validateField(String fieldName, String? value) {
    switch (fieldName) {
      case 'spots':
        return validateSpotsField(value);
      case 'costPerSpot':
        return validateAmountField(value);
      case 'dressCode':
        return validateDressCodeField(value);
      case 'food':
        return validateFoodSituationField(value);
      default:
        return null;
    }
  }

  List<Widget> _buildEditableField(String fieldName, String hintText) {
    if (_visibleFields[fieldName]!) {
      return [
        const SizedBox(height: generalAppLevelPadding),
        ProTextField(
          hintText: hintText,
          initialValue: _getInitialValue(fieldName),
          onValidationCallback: (String? value) =>
              _validateField(fieldName, value),
          onSaved: (value) {
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

  String? _getInitialValue(
    String fieldName,
  ) {
    switch (fieldName) {
      case 'spots':
        return event.spots == null || event.spots! > 0
            ? event.spots?.toString()
            : null;
      case 'costPerSpot':
        return event.costPerSpot == null || event.costPerSpot! > 0
            ? event.costPerSpot?.toString()
            : null;
      case 'dressCode':
        return event.dressCode;
      case 'food':
        return event.foodSituation;
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
            // Initialize gradient when image changes
            _initializeGradient();
          },
          imageService: imageService,
        ),
      ),
    );
  }

  Gradient _buildHeroGradient() {
    // Apply gradient only at the bottom 25% of the image for text readability
    // Keep the rest of the image completely transparent and visible
    if (_gradientColors.length >= 3) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          _gradientColors[1].withOpacity(0.4),
          _gradientColors[2].withOpacity(0.9),
          _gradientColors[2].withOpacity(1),
        ],
        stops: const [0.5, 0.55, 0.8, 1.0],
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          _gradientColors[0].withOpacity(0.3),
          _gradientColors[1].withOpacity(0.6),
          _gradientColors[1].withOpacity(0.75),
        ],
        stops: const [0.0, 0.75, 0.8, 0.9, 0.95, 1.0],
      );
    } else {
      // Fallback to single color
      final gradientColor = _gradientColor ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.transparent,
          Colors.transparent,
          gradientColor.withOpacity(0.4),
          gradientColor.withOpacity(0.6),
          gradientColor.withOpacity(0.75),
        ],
        stops: const [0.0, 0.75, 0.7, 0.9, 0.95, 1.0],
      );
    }
  }

  Gradient _buildFullScreenGradient() {
    // Background gradient starts with same colors as hero overlay gradient at bottom
    // Then continues to evolve after the image area for seamless blending
    if (_gradientColors.length >= 3) {
      // Start with hero gradient's bottom colors, then evolve
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[1].withOpacity(0.4), // Match hero gradient at 0.75 stop
          _gradientColors[2].withOpacity(0.9), // Match hero gradient at 0.8 stop
          _gradientColors[2].withOpacity(1), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[2].withOpacity(0.95), // Continue evolving
          _gradientColors[1].withOpacity(0.9), // Transition to second color
          // _gradientColors[0].withOpacity(0.9), // Loop back - first color at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.7, 1.0],
      );
    } else if (_gradientColors.length == 2) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _gradientColors[0].withOpacity(0.3), // Match hero gradient at 0.9 stop
          _gradientColors[1].withOpacity(0.6), // Match hero gradient at 0.95 stop
          _gradientColors[1].withOpacity(0.75), // Match hero gradient at 1.0 stop (seamless transition)
          _gradientColors[1].withOpacity(0.85), // Continue evolving
          _gradientColors[1].withOpacity(0.9),
          _gradientColors[0].withOpacity(0.85), // Transition to first color
          _gradientColors[0].withOpacity(0.9), // Loop back - first color at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.3, 0.5, 0.75, 1.0],
      );
    } else {
      // Fallback to single color - match hero gradient then evolve
      final gradientColor = _gradientColor ?? Colors.black;
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColor.withOpacity(0.4), // Match hero gradient at 0.9 stop
          gradientColor.withOpacity(0.6), // Match hero gradient at 0.95 stop
          gradientColor.withOpacity(0.75), // Match hero gradient at 1.0 stop (seamless transition)
          gradientColor.withOpacity(0.85), // Continue evolving
          gradientColor.withOpacity(0.92),
          gradientColor.withOpacity(0.95), // Loop back at bottom
        ],
        stops: const [0.0, 0.05, 0.1, 0.4, 0.7, 1.0],
      );
    }
  }

  void _initializeGradient() {
    if (event.imageUrl.isNotEmpty && event.imageUrl != _lastImageUrl) {
      _lastImageUrl = event.imageUrl;
      // Extract multiple colors for gradient
      extractMultipleColorsFromImage(event.imageUrl, mounted, colorCount: 3).then((colors) {
        if (mounted && event.imageUrl == _lastImageUrl) {
          setState(() {
            _gradientColors = colors;
            _gradientColor = colors.isNotEmpty ? colors.last : Colors.black;
          });
        }
      });
      // Also extract single color for backward compatibility
      extractGradientFromImage(event.imageUrl, mounted).then((value) {
        if (mounted && event.imageUrl == _lastImageUrl) {
          setState(() {
            _gradientColor = value;
          });
        }
      });
    } else if (event.imageUrl.isEmpty) {
      setState(() {
        _gradientColor = Colors.black;
        _gradientColors = [Colors.black, Colors.black, Colors.black];
        _lastImageUrl = null;
      });
    }
  }

  Widget _buildHeroSection(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double heroHeight = size.height * 0.8;

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: event.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: _buildHeroGradient(),
              ),
            ),
          ),
          _buildChangeBackgroundButton(),
          _buildHeroContentOverlay(context),
        ],
      ),
    );
  }

  Widget _buildTopActionBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + generalAppLevelPadding,
      left: generalAppLevelPadding,
      right: generalAppLevelPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeroActionChip(
            onTap: () {
              AppRouter.goHome(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          _buildHeroActionChip(
            onTap: () => _submitData(context),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: const ProText(
              'Save',
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionChip({
    required VoidCallback onTap,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildChangeBackgroundButton() {
    return Align(
      alignment: Alignment.center,
      child: _buildHeroActionChip(
        onTap: _handleImageSelection,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const ProText(
              'Change Background',
              textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroContentOverlay(BuildContext context) {
    // final TextStyle whiteTextStyle = TextStyle(
    //   color: Colors.white,
    //   fontFamily: selectedFont?.fontFamily,
    // );

    return Positioned(
      left: generalAppLevelPadding,
      right: generalAppLevelPadding,
      bottom: generalAppLevelPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProTextField(
            key: ValueKey('event-name-${event.id ?? 'new'}'),
            initialValue: event.name,
            onValidationCallback: validateTitleField,
            focusNode: _eventNameFocusNode,
            onChanged: (value) {
              setState(() {
                event.name = (value as String);
              });
            },
            onSaved: (value) {
              event.name = ((value as String?) ?? '').trim();
            },
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                fontFamily: selectedFont?.fontFamily),
            hintText: 'Enter Event Name',
            hintStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: selectedFont?.fontFamily,
                color: event.theme != null &&
                        ProThemes.themes[event.theme!] != null
                    ? ProThemes
                        .themes[event.theme!]!.theme.colorScheme.onSurface
                    : Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProDateTimePicker(
            initialValue: event.startDateTime,
            firstDate: DateTime(2024),
            lastDate: DateTime(2100),
            hintText: 'Set date and time',
            onDateTimeSelected: (selectedDate) {
              setState(() {
                event.startDateTime = selectedDate;
              });
            },
            // style: whiteTextStyle,
            // hintStyle: whiteTextStyle.copyWith(color: Colors.white70),
            // filled: true,
            // fillColor: Colors.white.withOpacity(0.08),

            suffixIcon: const Icon(Icons.access_time),
          ),
          const SizedBox(height: generalAppLevelPadding),
          ProTextField(
            key: ValueKey('event-location-${event.id ?? 'new'}'),
            initialValue: event.location,
            onValidationCallback: validateLocationField,
            onChanged: (value) {
              setState(() {
                event.location = (value as String);
              });
            },
            onSaved: (value) {
              event.location = (value as String?)?.trim();
            },
            // style: whiteTextStyle,
            hintText: 'Add location or link',
            // hintStyle: whiteTextStyle.copyWith(color: Colors.white70),
            suffixWidget: const Icon(Icons.location_on),
            // filled: true,
            // fillColor: Colors.white.withOpacity(0.08),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingControls(ThemeData currentTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Container(
        //   margin: const EdgeInsets.only(bottom: 16),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(16),
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(0.2),
        //         spreadRadius: 1,
        //         blurRadius: 3,
        //         offset: const Offset(0, 2),
        //       ),
        //     ],
        //   ),
        //   child: Material(
        //     color: currentTheme.colorScheme.surface,
        //     borderRadius: BorderRadius.circular(16),
        //     child: InkWell(
        //       onTap: _openThemeSelector,
        //       borderRadius: BorderRadius.circular(16),
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 16,
        //           vertical: 12,
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             // Container(
        //             //   width: 32,
        //             //   height: 32,
        //             //   padding: const EdgeInsets.all(4),
        //             //   decoration: BoxDecoration(
        //             //     borderRadius: BorderRadius.circular(8),
        //             //     border: Border.all(color: Colors.grey[300]!),
        //             //   ),
        //             //   child: Column(
        //             //     children: [
        //             //       Expanded(
        //             //         flex: 2,
        //             //         child: Row(
        //             //           children: [
        //             //             Expanded(
        //             //               flex: 2,
        //             //               child: Container(
        //             //                 decoration: BoxDecoration(
        //             //                   color: currentTheme.primaryColor,
        //             //                   borderRadius: const BorderRadius.only(
        //             //                     topLeft: Radius.circular(4),
        //             //                   ),
        //             //                 ),
        //             //               ),
        //             //             ),
        //             //             Expanded(
        //             //               child: Container(
        //             //                 decoration: BoxDecoration(
        //             //                   color: currentTheme.colorScheme.secondary,
        //             //                   borderRadius: const BorderRadius.only(
        //             //                     topRight: Radius.circular(4),
        //             //                   ),
        //             //                 ),
        //             //               ),
        //             //             ),
        //             //           ],
        //             //         ),
        //             //       ),
        //             //       Expanded(
        //             //         child: Row(
        //             //           children: [
        //             //             Expanded(
        //             //               child: Container(
        //             //                 decoration: BoxDecoration(
        //             //                   color: currentTheme.colorScheme.surface,
        //             //                   borderRadius: const BorderRadius.only(
        //             //                     bottomLeft: Radius.circular(4),
        //             //                   ),
        //             //                 ),
        //             //               ),
        //             //             ),
        //             //             Expanded(
        //             //               child: Container(
        //             //                 decoration: BoxDecoration(
        //             //                   color: currentTheme.colorScheme.tertiary,
        //             //                   borderRadius: const BorderRadius.only(
        //             //                     bottomRight: Radius.circular(4),
        //             //                   ),
        //             //                 ),
        //             //               ),
        //             //             ),
        //             //           ],
        //             //         ),
        //             //       ),
        //             //     ],
        //             //   ),
        //             // ),
        //             const SizedBox(width: 8),
        //             // ProText(
        //             //   'Theme',
        //             //   textStyle: TextStyle(
        //             //     color: currentTheme.primaryColor,
        //             //     fontWeight: FontWeight.bold,
        //             //   ),
        //             // ),
        //             // const SizedBox(width: 4),
        //             // Icon(
        //             //   Icons.chevron_right,
        //             //   size: 20,
        //             //   color: currentTheme.primaryColor,
        //             // ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: _openEffectSelector,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getEffectIcon(selectedEffect ?? defaultEffect),
                      size: 32,
                      color: currentTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    ProText(
                      'Effect',
                      textStyle: TextStyle(
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: currentTheme.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontSelectorOverlay(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool shouldShow = _eventNameFocusNode.hasFocus && bottomInset > 0;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: generalAppLevelPadding,
      right: generalAppLevelPadding,
      bottom: 0,
      child: ProCard(
        applyPadding: false,
        radius: 20,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: SizedBox(
            height: 48,
            child: ProFontSelector(
              selectedFont: selectedFont ?? ProFontType.system,
              onSelected: (font) {
                setState(() {
                  selectedFont = font;
                  event.font = font.toString();
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEventOptions() {
    return [
      ..._buildEditableField('spots', 'Enter number of spots'),
      ..._buildEditableField('costPerSpot', 'Enter cost per spot'),
      ..._buildEditableField(
          'dressCode', 'Enter dress code. Casual, black tie, etc.'),
      ..._buildEditableField(
          'food', 'Enter food situation. BYOB, potluck, etc.'),
      const SizedBox(
        height: generalAppLevelPadding,
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (!_visibleFields['dressCode']!)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProOutlinedButton(
                  child: ProText('Dress code'),
                  onPressed: () =>
                      setState(() => _visibleFields['dressCode'] = true),
                ),
              ),
            if (!_visibleFields['food']!)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProOutlinedButton(
                  child: ProText('Food situation'),
                  onPressed: () =>
                      setState(() => _visibleFields['food'] = true),
                ),
              ),
            if (!_visibleFields['spots']!)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProOutlinedButton(
                  child: ProText('Spots'),
                  onPressed: () =>
                      setState(() => _visibleFields['spots'] = true),
                ),
              ),
            if (!_visibleFields['costPerSpot']!)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ProOutlinedButton(
                  child: ProText('Cost per spot'),
                  onPressed: () =>
                      setState(() => _visibleFields['costPerSpot'] = true),
                ),
              ),
          ],
        ),
      ),
      if (!_visibleFields['spots']! ||
          !_visibleFields['costPerSpot']! ||
          !_visibleFields['dressCode']! ||
          !_visibleFields['food']!)
        const SizedBox(height: generalAppLevelPadding),
      // const SizedBox(height: generalAppLevelPadding / 2),
    ];
  }

  void _openThemeSelector() {
    openProBottomModalSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ProThemes.themes.length,
            itemBuilder: (context, index) {
              final themeType = ProThemeType.values[index];
              final theme = ProThemes.themes[themeType]!;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedTheme = themeType;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedTheme == themeType
                          ? theme.theme.primaryColor
                          : Colors.grey[300]!,
                      width: selectedTheme == themeType ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.theme.primaryColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color:
                                            theme.theme.colorScheme.secondary,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.theme.colorScheme.surface,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: theme.theme.colorScheme.tertiary,
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProText(
                        theme.name,
                        textStyle: TextStyle(
                          fontSize: 12,
                          color: selectedTheme == themeType
                              ? theme.theme.primaryColor
                              : Colors.grey[800],
                          fontWeight: selectedTheme == themeType
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
      titleText: 'Select Theme',
    );
  }

  Widget buildThemeSelector() {
    final currentTheme = ProThemes.themes[selectedTheme]!;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: generalAppLevelPadding * 2,
      ),
      child: InkWell(
        onTap: _openThemeSelector,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: currentTheme.theme.primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: currentTheme.theme.colorScheme.secondary,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: currentTheme.theme.colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: currentTheme.theme.colorScheme.tertiary,
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProText(
                      currentTheme.name,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ProText(
                      'Tap to change theme',
                      textStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEffectSelector() {
    openProBottomModalSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ProText(
              'Choose Effect',
              textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 400,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: ProEffectType.values.length,
              itemBuilder: (context, index) {
                final effectType = ProEffectType.values[index];
                final isSelected = selectedEffect == effectType;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedEffect = effectType;
                      event.effect = effectType.toString();
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getEffectIcon(effectType),
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        ProText(
                          effectType.displayName,
                          textStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEffectIcon(ProEffectType? effectType) {
    if (effectType == null) {
      return Icons.block;
    }
    switch (effectType) {
      case ProEffectType.none:
        return Icons.block;
      case ProEffectType.balloons:
        return Icons.toys;
      case ProEffectType.snowflake:
        return Icons.ac_unit;
      case ProEffectType.stars:
        return Icons.star;
      case ProEffectType.bubbles:
        return Icons.circle;
      case ProEffectType.confetti:
        return Icons.celebration;
      case ProEffectType.hearts:
        return Icons.favorite;
      case ProEffectType.fall_leaves:
        return Icons.eco;
      // TODO: Handle this case.
    }
  }

  bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  Widget buildFormWidget(
    BuildContext context,
  ) {
    if (selectedTheme == null) {
      selectedTheme = defaultThemeType;
    }

    final ProThemeType themeType = selectedTheme ?? defaultThemeType;
    final ProEffectType effectType = selectedEffect ?? defaultEffect;

    return Theme(
      data: ProThemes.themes[selectedTheme!]!.theme,
      child: ProThemeEffects(
        size: MediaQuery.sizeOf(context),
        themeType: themeType,
        effectType: effectType,
        child: ProScaffold(
          floatingActionButton: isKeyboardVisible(context)
              ? null
              : _buildFloatingControls(ProThemes.themes[selectedTheme!]!.theme),
          backgroundColor: _gradientColor ?? Colors.black,
          body: Container(
            decoration: BoxDecoration(
              gradient: _buildFullScreenGradient(),
            ),
            child: Stack(
              children: [
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: (_eventNameFocusNode.hasFocus &&
                            MediaQuery.of(context).viewInsets.bottom > 0)
                        ? 260
                        : generalAppLevelPadding * 4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroSection(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: generalAppLevelPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProTextField(
                              multiline: true,
                              maxLines: 5,
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                final dynamic result =
                                    await openProBottomModalSheet(
                                  context,
                                  AIEnabledDescription(
                                    event: event,
                                    controller: _descriptionController,
                                  ),
                                );
                                if (!mounted) {
                                  return;
                                }
                                if (result is String) {
                                  final String trimmed = result.trim();
                                  setState(() {
                                    _descriptionController.value =
                                        _descriptionController.value.copyWith(
                                      text: trimmed,
                                      selection: TextSelection.collapsed(
                                        offset: trimmed.length,
                                      ),
                                    );
                                    event.description = trimmed;
                                  });
                                }
                              },
                              hintText: 'Tap to let AI do the talking 🤖✨',
                              textEditingController: _descriptionController,
                              onValidationCallback: validateDescriptionField,
                              onChanged: (value) {
                                event.description = value;
                              },
                              onSaved: (value) {
                                event.description = value.toString().trim();
                              },
                            ),
                            const SizedBox(height: generalAppLevelPadding),
                            // ..._buildEventOptions(),
                            ProListItem(
                              swipeForEditAndDelete: false,
                              key: const Key('hide-guest-list'),
                              title: const ProText('Hide Guest List'),
                              subtitle: const ProText(
                                'Hide the guest names to RSVP\'d guests',
                                maxLines: 2,
                              ),
                              trailing: Switch(
                                value: event.isGuestListHidden,
                                onChanged: (bool selected) {
                                  setState(() {
                                    event.isGuestListHidden = selected;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: generalAppLevelPadding / 2),
                            ProListItem(
                              key: const Key('hide-guest-count'),
                              title: const ProText('Hide Guest Count'),
                              subtitle: const ProText(
                                'Hide number of guests to RSVP\'d guests',
                              ),
                              swipeForEditAndDelete: false,
                              trailing: Switch(
                                value: event.isGuestCountHidden,
                                onChanged: (bool selected) {
                                  setState(() {
                                    event.isGuestCountHidden = selected;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: generalAppLevelPadding * 10),
                    ],
                  ),
                ),
              ),
              _buildFontSelectorOverlay(context),
              _buildTopActionBar(context),
            ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventNameFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
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

            if (event.spots != null && event.spots! > 0) {
              _visibleFields['spots'] = true;
            }
            if (event.costPerSpot != null && event.costPerSpot! > 0) {
              _visibleFields['costPerSpot'] = true;
            }
            if (event.dressCode != null && event.dressCode!.isNotEmpty) {
              _visibleFields['dressCode'] = true;
            }
            if (event.foodSituation != null &&
                event.foodSituation!.isNotEmpty) {
              _visibleFields['food'] = true;
            }

            // Set the initial theme if one exists
            if (selectedTheme == null && event.theme != null) {
              selectedTheme = ProThemeType.values.firstWhere(
                (type) => type.toString() == event.theme,
                orElse: () => ProThemeType.classic,
              );
            }
            if (selectedEffect == null && event.effect != null) {
              selectedEffect = ProEffectType.values.firstWhere(
                (type) => type.toString() == event.effect,
                orElse: () => ProEffectType.none,
              );
            }
            if (selectedFont == null && event.font != null) {
              selectedFont = ProFontType.values.firstWhere(
                (type) => type.toString() == event.font,
                orElse: () => ProFontType.system,
              );
            }
            if (!_hasSyncedDescription) {
              final String descriptionText = event.description ?? '';
              _descriptionController.value =
                  _descriptionController.value.copyWith(
                text: descriptionText,
                selection: TextSelection.collapsed(
                  offset: descriptionText.length,
                ),
              );
              _hasSyncedDescription = true;
            }
            
            // Initialize gradient when event is loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _initializeGradient();
              }
            });
          }

          return buildFormWidget(context);
        });
  }
}
