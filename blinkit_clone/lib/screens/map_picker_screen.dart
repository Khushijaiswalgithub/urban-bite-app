import 'dart:async';

import 'package:blinkit_clone/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;
  String? _addressSummary;
  geocoding.Placemark? _lastPlacemark;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePositionAndInit();
  }

  Future<void> _determinePositionAndInit() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    await _reverseGeocode(pos.latitude, pos.longitude);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final places = await geocoding.placemarkFromCoordinates(lat, lng);
      if (places.isNotEmpty) {
        final p = places.first;
        _lastPlacemark = p;

        // Build a readable summary but keep the full placemark for structured values
        _addressSummary =
            '${p.name ?? ''}, ${p.subLocality ?? p.locality ?? ''}, ${p.administrativeArea ?? ''} - ${p.postalCode ?? ''}';
      }
    } catch (e) {
      debugPrint('Reverse geocode failed: $e');
    }
  }

  void _confirmLocation() {
    if (_currentLatLng == null) return;

    // Build AddressModel from last reverse-geocoded placemark if available
    String house = '';
    String area = '';
    String city = '';
    String state = '';
    String pincode = '';

    if (_lastPlacemark != null) {
      final p = _lastPlacemark!;
      // subThoroughfare is often house/door number, thoroughfare is street
      house = [
        p.subThoroughfare,
        p.thoroughfare,
        p.name,
      ].where((s) => s != null && s.isNotEmpty).join(' ').trim();
      area = (p.subLocality ?? p.subAdministrativeArea ?? '').trim();
      city = (p.locality ?? p.subAdministrativeArea ?? '').trim();
      state = (p.administrativeArea ?? '').trim();
      pincode = (p.postalCode ?? '').trim();
    } else {
      final parts = (_addressSummary ?? '').split(',');
      area = parts.length > 1 ? parts[1].trim() : '';
      city = parts.length > 2 ? parts[2].trim() : '';
      final pincodeMatch = RegExp(r"\d{5,6}").firstMatch(_addressSummary ?? '');
      pincode = pincodeMatch?.group(0) ?? '';
      house = parts.isNotEmpty ? parts[0].trim() : '';
    }

    final address = AddressModel(
      house: house,
      area: area,
      city: city,
      latitude: _currentLatLng?.latitude,
      longitude: _currentLatLng?.longitude,
      state: state,
      pincode: pincode,
    );

    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: const Color(0xFF00C853),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _currentLatLng == null
                      ? const Center(child: Text('Unable to get location'))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLatLng!,
                            zoom: 16,
                          ),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onMapCreated: (controller) {
                            if (!_controller.isCompleted) {
                              _controller.complete(controller);
                            }
                          },
                          onTap: (latlng) async {
                            setState(() {
                              _currentLatLng = latlng;
                              _isLoading = true;
                            });
                            await _reverseGeocode(
                              latlng.latitude,
                              latlng.longitude,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _addressSummary ?? 'Selected location',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${_currentLatLng?.latitude.toStringAsFixed(5)}, ${_currentLatLng?.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

