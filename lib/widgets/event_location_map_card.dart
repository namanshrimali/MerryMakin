import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:merrymakin/commons/models/event.dart';
import 'package:merrymakin/commons/resources.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/utils/location_launcher.dart';
import 'package:merrymakin/commons/widgets/cards/pro_card.dart';
import 'package:merrymakin/commons/widgets/pro_snackbar.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';

/// Dark map style JSON for Google Maps (silver/grey theme).
const String _kDarkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
  {"featureType": "administrative.locality", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "poi", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#263c3f"}]},
  {"featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [{"color": "#6b9a76"}]},
  {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#38414e"}]},
  {"featureType": "road", "elementType": "geometry.stroke", "stylers": [{"color": "#212a37"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#9ca5b3"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#746855"}]},
  {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f2835"}]},
  {"featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [{"color": "#f3d19c"}]},
  {"featureType": "transit", "elementType": "geometry", "stylers": [{"color": "#2f3948"}]},
  {"featureType": "transit.station", "elementType": "labels.text.fill", "stylers": [{"color": "#d59563"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]},
  {"featureType": "water", "elementType": "labels.text.stroke", "stylers": [{"color": "#17263c"}]}
]
''';

class EventLocationMapCard extends StatefulWidget {
  final Event event;
  final ThemeData? theme;
  final void Function(String)? showSnackBarCallback;

  const EventLocationMapCard({
    super.key,
    required this.event,
    this.theme,
    this.showSnackBarCallback,
  });

  @override
  State<EventLocationMapCard> createState() => _EventLocationMapCardState();
}

class _EventLocationMapCardState extends State<EventLocationMapCard> {
  double? _geocodedLat;
  double? _geocodedLng;
  bool _geocodeFailed = false;
  bool _geocoding = false;
  GoogleMapController? _mapController;

  String? get _address {
    if (widget.event.locationDetails?.address != null &&
        widget.event.locationDetails!.address!.isNotEmpty) {
      return widget.event.locationDetails!.address;
    }
    if (widget.event.location != null && widget.event.location!.isNotEmpty) {
      return widget.event.location;
    }
    return null;
  }

  double? get _lat {
    if (widget.event.locationDetails?.locationLat != null) {
      return widget.event.locationDetails!.locationLat;
    }
    return _geocodedLat;
  }

  double? get _lng {
    if (widget.event.locationDetails?.locationLng != null) {
      return widget.event.locationDetails!.locationLng;
    }
    return _geocodedLng;
  }

  bool get _hasLocationToShow {
    final addr = _address;
    if (addr == null || addr.isEmpty) return false;
    return true;
  }

  void _showSnackBar(String message) {
    if (widget.showSnackBarCallback != null) {
      widget.showSnackBarCallback!(message);
    } else if (mounted) {
      showSnackBar(context, message);
    }
  }

  void _applyMapStyle() {
    final brightness = widget.theme?.brightness ?? (mounted ? Theme.of(context).brightness : Brightness.light);
    _mapController?.setMapStyle(brightness == Brightness.dark ? _kDarkMapStyle : null);
  }

  void _showMapOptionsSheet() {
    final address = _address;
    if (address == null) return;
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Open in Google Maps'),
                onTap: () {
                  Navigator.of(context).pop();
                  openInGoogleMaps(address, _showSnackBar);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Open in Apple Maps'),
                onTap: () {
                  Navigator.of(context).pop();
                  openInAppleMaps(address, _showSnackBar);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _geocodeAddress() async {
    final addr = _address;
    if (addr == null || addr.isEmpty || _geocoding || _geocodeFailed) return;
    if (_lat != null && _lng != null) return;
    setState(() => _geocoding = true);
    try {
      final locations = await geo.locationFromAddress(addr);
      if (!mounted) return;
      if (locations.isNotEmpty) {
        setState(() {
          _geocodedLat = locations.first.latitude;
          _geocodedLng = locations.first.longitude;
          _geocoding = false;
        });
      } else {
        setState(() {
          _geocodeFailed = true;
          _geocoding = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _geocodeFailed = true;
          _geocoding = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (_hasLocationToShow && _lat == null && _lng == null && !_geocodeFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _geocodeAddress());
    }
  }

  @override
  void didUpdateWidget(EventLocationMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.location != widget.event.location ||
        oldWidget.event.locationDetails != widget.event.locationDetails) {
      if (_hasLocationToShow &&
          _lat == null &&
          _lng == null &&
          !_geocodeFailed) {
        _geocodeAddress();
      }
    }
    if (oldWidget.theme?.brightness != widget.theme?.brightness) {
      _applyMapStyle();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLocationToShow) return const SizedBox.shrink();

    String address = _address!;
    if (widget.event.locationDetails?.unit != null && widget.event.locationDetails!.unit!.isNotEmpty) {
      address += ' $DOT ${widget.event.locationDetails!.unit}';
    }
    final lat = _lat;
    final lng = _lng;
    final hasCoordinates = lat != null && lng != null;

    return Padding(
      padding: const EdgeInsets.only(
        left: generalAppLevelPadding,
        right: generalAppLevelPadding,
      ),
      child: ProCard(
        elevation: 10,
        applyPadding: false,
        surfaceTintColor: Colors.white.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: generalAppLevelPadding, right: generalAppLevelPadding, top: generalAppLevelPadding),
                child: Column(children: [
                  ProText(
                    'Directions',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ProText(
                      address,
                      textStyle: const TextStyle(fontSize: 14),
                      maxLines: 3,
                    ),
                  ),
                ])),
            if (hasCoordinates) ...[
              const SizedBox(height: generalAppLevelPadding),
              SizedBox(
                height: 180,
                width: double.infinity,
                child: GestureDetector(
                  onTap: _showMapOptionsSheet,
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 15.2,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('event-location'),
                              position: LatLng(lat, lng),
                            ),
                          },
                          liteModeEnabled: true,
                          zoomControlsEnabled: false,
                          scrollGesturesEnabled: false,
                          zoomGesturesEnabled: false,
                          myLocationButtonEnabled: false,
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            _applyMapStyle();
                          },
                        ),
                        // Tap target overlay so map tap is reliably detected
                        const ColoredBox(
                          color: Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else if (_geocoding)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_geocodeFailed)
              const SizedBox.shrink(),
            SizedBox(height: generalAppLevelPadding / 2),
          ],
        ),
      ),
    );
  }
}
