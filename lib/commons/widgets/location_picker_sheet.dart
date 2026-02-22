import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:merrymakin/commons/models/location.dart';
import 'package:merrymakin/commons/themes/pro_themes.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/utils/google_maps_config.dart';
import 'package:merrymakin/commons/widgets/buttons/pro_primary_button.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_bottom_modal_sheet.dart';
import 'package:merrymakin/commons/widgets/pro_list_item.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/factory/app_factory.dart';
import 'package:merrymakin/service/event_service.dart';

class LocationPickerSheet extends StatefulWidget {
  final Location? initialLocation;
  final void Function(Location location) onSelect;
  final ProThemeType? themeType;

  const LocationPickerSheet({
    super.key,
    this.initialLocation,
    required this.onSelect,
    this.themeType,
  });

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<_PlacePrediction> _predictions = [];
  bool _isLoadingPredictions = false;
  Timer? _debounceTimer;
  String? _selectedAddress;
  double? _selectedLat;
  double? _selectedLng;
  bool _isLoadingDetails = false;

  /// Which suggested location is currently playing selection feedback (scale + checkmark).
  Location? _pendingSuggestedSelection;
  late AnimationController _selectionFeedbackController;
  late Animation<double> _selectionScale;
  late Animation<double> _selectionHighlight;

  @override
  void initState() {
    super.initState();
    final loc = widget.initialLocation;
    if (loc != null) {
      _nameController.text = loc.name ?? '';
      _unitController.text = loc.unit ?? '';
      _searchController.text = '';
      _selectedAddress = loc.address;
      _selectedLat = loc.locationLat;
      _selectedLng = loc.locationLng;
    }
    _searchController.addListener(_onSearchChanged);

    _selectionFeedbackController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );
    _selectionScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.97)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.97, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_selectionFeedbackController);
    _selectionHighlight = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.14)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.14, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_selectionFeedbackController);

    _selectionFeedbackController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _pendingSuggestedSelection != null) {
        final location = _pendingSuggestedSelection;
        _pendingSuggestedSelection = null;
        _selectionFeedbackController.reset();
        if (location != null) _selectSuggestedLocation(location);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _selectionFeedbackController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();
    // if (query.isEmpty) {
    //   setState(() {
    //     _predictions = [];
    //     _selectedAddress = null;
    //     _selectedLat = null;
    //     _selectedLng = null;
    //   });
    //   return;
    // }
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String input) async {
    if (googleMapsApiKey.isEmpty) {
      setState(() {
        _predictions = [];
        _isLoadingPredictions = false;
      });
      return;
    }
    setState(() => _isLoadingPredictions = true);
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$googleMapsApiKey',
      );
      final response = await http.get(uri);
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
        setState(() {
          _predictions = [];
          _isLoadingPredictions = false;
        });
        return;
      }
      final list = (data['predictions'] as List?) ?? [];
      setState(() {
        _predictions = list
            .map((e) => _PlacePrediction(
                  placeId: (e as Map)['place_id'] as String? ?? '',
                  description: e['description'] as String? ?? '',
                ))
            .toList();
        _isLoadingPredictions = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _predictions = [];
          _isLoadingPredictions = false;
        });
      }
    }
  }

  Future<void> _selectPlace(_PlacePrediction prediction) async {
    if (googleMapsApiKey.isEmpty) return;
    setState(() {
      _isLoadingDetails = true;
      _predictions = [];
    });
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=${Uri.encodeComponent(prediction.placeId)}'
        '&fields=formatted_address,geometry'
        '&key=$googleMapsApiKey',
      );
      final response = await http.get(uri);
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') {
        setState(() => _isLoadingDetails = false);
        return;
      }
      final result = data['result'] as Map<String, dynamic>?;
      final formattedAddress =
          result?['formatted_address'] as String? ?? prediction.description;
      final geometry = result?['geometry'] as Map<String, dynamic>?;
      double? lat;
      double? lng;
      if (geometry != null && geometry['location'] != null) {
        final loc = geometry['location'] as Map<String, dynamic>;
        lat = (loc['lat'] is num) ? (loc['lat'] as num).toDouble() : null;
        lng = (loc['lng'] is num) ? (loc['lng'] as num).toDouble() : null;
      }
      setState(() {
        _selectedAddress = formattedAddress;
        _selectedLat = lat;
        _selectedLng = lng;
        _predictions = [];
        _searchController.text = '';
        _isLoadingDetails = false;
      });
      _searchFocusNode.unfocus();
    } catch (_) {
      if (mounted) setState(() => _isLoadingDetails = false);
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedAddress = null;
      _selectedLat = null;
      _selectedLng = null;
    });
  }

  void _selectSuggestedLocation(Location location) {
    setState(() {
      _nameController.text = location.name ?? '';
      _unitController.text = location.unit ?? '';
      _selectedAddress = location.address;
      _selectedLat = location.locationLat;
      _selectedLng = location.locationLng;
      _predictions = [];
      _searchController.text = '';
    });
    _searchFocusNode.unfocus();
  }

  void _onConfirm() {
    final address = _selectedAddress ?? _searchController.text.trim();
    if (address.isEmpty) return;
    final name = _nameController.text.trim();
    final unit = _unitController.text.trim();
    widget.onSelect(Location(
      name: name.isEmpty ? null : name,
      unit: unit.isEmpty ? null : unit,
      address: address,
      locationLat: _selectedLat,
      locationLng: _selectedLng,
    ));
    closeProBottomModalSheet(context);
  }

  /// Splits "Street, City, State, Country" into (street, rest).
  (String, String?) _splitAddress(String address) {
    final i = address.indexOf(',');
    if (i <= 0) return (address, null);
    return (
      address.substring(0, i).trim(),
      address.substring(i + 1).trim(),
    );
  }

  List<Widget> _buildPredictionList(
    List<_PlacePrediction> predictions,
    ThemeData theme,
    Color primary,
  ) {
    return predictions
        .map((p) => Padding(
              padding: const EdgeInsets.symmetric(
                vertical: generalAppLevelPadding / 2,
              ),
              child: ProListItem(
                key: Key(p.description),
                leading: Icon(Icons.place_outlined, size: 20, color: primary),
                title: ProText(
                  p.description,
                  maxLines: 2,
                  textStyle: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                ),
                onTap: () => _selectPlace(p),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final List<Location?> suggestedLocations = getPreviouslyHostedLocationsForUser(AppFactory().cookiesService.locallyAvailableUserInfo!.id!);

    final hasSelection =
        _selectedAddress != null && _selectedAddress!.isNotEmpty;
    final canConfirm = hasSelection || _searchController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: generalAppLevelPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search
          ProTextField(
            key: const Key('location-search-field'),
            textEditingController: _searchController,
            focusNode: _searchFocusNode,
            hintText: 'Search Locations.',
            textAlign: TextAlign.start,
            prefixWidget: Icon(
              Icons.search,
              size: 22,
              color: onSurfaceVariant,
            ),
            suffixWidget: _isLoadingPredictions || _isLoadingDetails
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary,
                    ),
                  )
                : null,
          ),

          // Suggested Locations (when no selection)
          if (!hasSelection && _predictions.isEmpty && suggestedLocations.isNotEmpty) ...[
            const SizedBox(height: generalAppLevelPadding),
            ProText(
              'Suggested',
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            ...suggestedLocations.map((location) => location != null ? Padding(
              padding: const EdgeInsets.only(top: generalAppLevelPadding / 2),
              child: _SuggestedLocationCard(
                location: location,
                theme: theme,
                onSurfaceVariant: onSurfaceVariant,
                primary: primary,
                splitAddress: _splitAddress,
                isPlayingSelectionFeedback: _pendingSuggestedSelection?.address == location.address,
                selectionScale: _selectionScale,
                selectionHighlight: _selectionHighlight,
                selectionFeedbackController: _selectionFeedbackController,
                onTap: () {
                  if (_pendingSuggestedSelection != null) return;
                  HapticFeedback.lightImpact();
                  setState(() => _pendingSuggestedSelection = location);
                  _selectionFeedbackController.forward(from: 0);
                },
              ),
            ) : const SizedBox.shrink())
          ],
          // Event Location (when selected)
          if (hasSelection && _predictions.isEmpty) ...[
            const SizedBox(height: generalAppLevelPadding),
            ProText(
              'Event Location',
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: generalAppLevelPadding / 2),
            TweenAnimationBuilder<double>(
              key: ValueKey(_selectedAddress),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    alignment: Alignment.centerLeft,
                    scale: 0.94 + 0.06 * value,
                    child: child,
                  ),
                );
              },
              child: ProCard(
                elevation: 10,
                surfaceTintColor: Colors.white.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: generalAppLevelPadding / 2,
                    horizontal: generalAppLevelPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: generalAppLevelPadding),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ProText(
                              _splitAddress(_selectedAddress!).$1,
                              textStyle: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_splitAddress(_selectedAddress!).$2 != null) ...[
                              const SizedBox(height: 2),
                              ProText(
                                _splitAddress(_selectedAddress!).$2!,
                                textStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        key: const Key('location-clear-button'),
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 22,
                          color: onSurfaceVariant,
                        ),
                        onPressed: _clearSelection,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Map Locations (predictions)
          if (_predictions.isNotEmpty) ...[
            const SizedBox(height: generalAppLevelPadding),
            Padding(
              padding: const EdgeInsets.only(left: generalAppLevelPadding / 2),
              child: ProText(
                'Map Locations',
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: generalAppLevelPadding / 2),
            ProCard(
              elevation: 10,
              surfaceTintColor: Colors.white.withValues(alpha: 0.1),
              child: Column(
                children: _buildPredictionList(
                  _predictions,
                  theme,
                  primary,
                ),
              ),
            ),
          ],

          if (hasSelection && _predictions.isEmpty) ...[
            const SizedBox(height: generalAppLevelPadding),
            // Apartment, Unit, or Floor
            ProText(
              'Apartment, Unit, or Floor',
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: generalAppLevelPadding / 2),
            ProTextField(
              key: const Key('location-unit-field'),
              textEditingController: _unitController,
              hintText: 'Example: Apt 1A.',
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 4),
            ProText(
              'Optional. This appears on the invitation.',
              textStyle: theme.textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],

          if (_predictions.isEmpty) ...[
            const SizedBox(height: generalAppLevelPadding),

            // Location Name
            ProText(
              'Location Name',
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: generalAppLevelPadding / 2),
            ProTextField(
              key: const Key('location-name-field'),
              textEditingController: _nameController,
              hintText: 'Example: ${AppFactory().cookiesService.locallyAvailableUserInfo!.getFirstAndLastName()}\'s House.',
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 4),
            ProText(
              'Optional. This appears on the invitation.',
              textStyle: theme.textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant,
                fontSize: 12,
                height: 1.3,
              ),
            ),
            const SizedBox(height: generalAppLevelPadding),
          ProPrimaryButton(
            isBig: true,
            const ProText('Confirm'),
            onPressed: canConfirm ? _onConfirm : null,
          ),
          ],

          

          SizedBox(
            height:
                MediaQuery.of(context).padding.bottom + generalAppLevelPadding,
          ),
        ],
      ),
    );
  }
}

/// A single suggested location card with optional selection feedback animation
/// (scale press, subtle highlight, checkmark pop).
class _SuggestedLocationCard extends StatelessWidget {
  final Location location;
  final ThemeData theme;
  final Color onSurfaceVariant;
  final Color primary;
  final (String, String?) Function(String) splitAddress;
  final bool isPlayingSelectionFeedback;
  final Animation<double> selectionScale;
  final Animation<double> selectionHighlight;
  final AnimationController selectionFeedbackController;
  final VoidCallback onTap;

  const _SuggestedLocationCard({
    required this.location,
    required this.theme,
    required this.onSurfaceVariant,
    required this.primary,
    required this.splitAddress,
    required this.isPlayingSelectionFeedback,
    required this.selectionScale,
    required this.selectionHighlight,
    required this.selectionFeedbackController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        ProCard(
          
          elevation: 10,
          surfaceTintColor: Colors.white.withValues(alpha: 0.1),
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: generalAppLevelPadding / 2,
                horizontal: generalAppLevelPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: generalAppLevelPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProText(
                          location.name ?? splitAddress(location.address!).$1,
                          textStyle: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (location.name != null && location.name!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          ProText(
                            location.getAddress(),
                            textStyle: theme.textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                        if ((location.name == null || location.name!.isEmpty) &&
                            splitAddress(location.address!).$2 != null) ...[
                          const SizedBox(height: 2),
                          ProText(
                            splitAddress(location.address!).$2!,
                            textStyle: theme.textTheme.bodySmall?.copyWith(
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Checkmark that appears during selection feedback
                  if (isPlayingSelectionFeedback)
                    AnimatedBuilder(
                      animation: selectionFeedbackController,
                      builder: (context, _) {
                        final checkProgress = Curves.easeOut.transform(
                          (selectionFeedbackController.value - 0.15).clamp(0.0, 1.0) / 0.85,
                        );
                        return Opacity(
                          opacity: checkProgress,
                          child: Transform.scale(
                            scale: 0.5 + 0.5 * Curves.elasticOut.transform(checkProgress),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 28,
                              color: primary,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    const SizedBox(width: 28, height: 28),
                ],
              ),
            ),
          ),
        ),
        // Subtle highlight overlay during selection feedback
        if (isPlayingSelectionFeedback)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: selectionHighlight,
              builder: (context, _) => IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: primary.withValues(alpha: selectionHighlight.value),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (!isPlayingSelectionFeedback) return card;

    return AnimatedBuilder(
      animation: selectionScale,
      builder: (context, child) => Transform.scale(
        scale: selectionScale.value,
        alignment: Alignment.center,
        child: child,
      ),
      child: card,
    );
  }
}

class _PlacePrediction {
  final String placeId;
  final String description;

  _PlacePrediction({required this.placeId, required this.description});
}
