import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  Future<bool> ensurePermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final ok = await ensurePermission();
    if (!ok) return null;
    _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    notifyListeners();
    return _currentPosition;
  }

  Future<void> openNavigation({
    required double latitude,
    required double longitude,
  }) async {
    final String schemeUrl = Platform.isIOS
        ? 'http://maps.apple.com/?daddr=$latitude,$longitude'
        : 'google.navigation:q=$latitude,$longitude&mode=d';
    final schemeUri = Uri.parse(schemeUrl);

    try {
      if (await canLaunchUrl(schemeUri)) {
        await launchUrl(schemeUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Fallback: universally supported HTTPS Maps link that is always launchable
    final fallbackUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving';
    final fallbackUri = Uri.parse(fallbackUrl);
    try {
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}
