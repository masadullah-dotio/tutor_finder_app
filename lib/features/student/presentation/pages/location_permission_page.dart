import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tutor_finder_app/core/services/location_service.dart';

class LocationPermissionPage extends StatefulWidget {
  final VoidCallback onPermissionGranted;

  const LocationPermissionPage({
    super.key,
    required this.onPermissionGranted,
  });

  @override
  State<LocationPermissionPage> createState() => _LocationPermissionPageState();
}

class _LocationPermissionPageState extends State<LocationPermissionPage> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = LocationService();
      await service.determinePosition();
      // If successful, callback
      widget.onPermissionGranted();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
        
        // If permanently denied, offer to open settings
        if (e.toString().contains('permanently denied')) {
           // On Web, we cannot open app settings programmatically in the same way,
           // and generic "permanently denied" might behave differently.
           // Usually the browser prompts again or shows a blocked icon.
           if (!kIsWeb) {
             _showOpenSettingsDialog();
           } else {
             // For web, just show the error
             setState(() {
                _errorMessage = "Location is blocked. Please reset permissions in your browser address bar.";
             });
           }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Location permission is permanently denied. Please enable it in app settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(ctx);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Find Tutors Near You',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'To show you the best tutors in your area, we need access to your device\'s location. This allows you to filter search results by distance.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 48),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _requestPermission,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Enable Location'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Skip/Close
              },
              child: const Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }
}
