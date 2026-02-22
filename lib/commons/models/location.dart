import 'package:merrymakin/commons/resources.dart';

class Location {
  final String? name;
  final String? address;
  /// Optional: Apartment, Unit, or Floor (e.g. "Apt 4", "Unit 2B", "Floor 3").
  final String? unit;
  final String? city;
  final String? state;
  final String? zipcode;
  final double? locationLat;
  final double? locationLng;

  Location({
    this.name,
    this.address,
    this.unit,
    this.city,
    this.state,
    this.zipcode,
    this.locationLat,
    this.locationLng,
  });

  factory Location.fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return Location();
    }
    return Location(
      name: map['name'] as String?,
      address: map['address'] as String?,
      unit: map['unit'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      zipcode: map['zipcode'] as String?,
      locationLat: map['locationLat'] != null
          ? (map['locationLat'] is num
              ? (map['locationLat'] as num).toDouble()
              : double.tryParse(map['locationLat'].toString()))
          : null,
      locationLng: map['locationLng'] != null
          ? (map['locationLng'] is num
              ? (map['locationLng'] as num).toDouble()
              : double.tryParse(map['locationLng'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (unit != null) 'unit': unit,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (zipcode != null) 'zipcode': zipcode,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
    };
  }

  Location deepCopy() {
    return Location(
      name: name,
      address: address,
      unit: unit,
      city: city,
      state: state,
      zipcode: zipcode,
      locationLat: locationLat,
      locationLng: locationLng,
    );
  }

  @override
  String toString() {
    return 'Location{name: $name, address: $address, unit: $unit, city: $city, state: $state, zipcode: $zipcode, locationLat: $locationLat, locationLng: $locationLng}';
  }

  String getAddress() {
    if (address == null || address!.isEmpty) {
      return '';
    }
    if (unit != null && unit!.isNotEmpty) {
      return '$address $DOT $unit';
    }
    return address!;
  }
}
