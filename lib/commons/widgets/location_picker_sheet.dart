import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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

class _LocationPickerSheetState extends State<LocationPickerSheet> {
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
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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
              child: InkWell(
                onTap: () => _selectSuggestedLocation(location),
                borderRadius: BorderRadius.circular(12),
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
                                location.name ?? _splitAddress(location.address!).$1,
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
                              if ((location.name == null || location.name!.isEmpty) && _splitAddress(location.address!).$2 != null) ...[
                                const SizedBox(height: 2),
                                ProText(
                                  _splitAddress(location.address!).$2!,
                                  textStyle: theme.textTheme.bodySmall?.copyWith(
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            ProCard(
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

class _PlacePrediction {
  final String placeId;
  final String description;

  _PlacePrediction({required this.placeId, required this.description});
}
