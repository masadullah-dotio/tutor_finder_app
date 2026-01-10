import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/core/services/location_service.dart';
// import 'dart:io'; // Removed for Web compatibility
import 'package:image_picker/image_picker.dart';
import 'package:tutor_finder_app/core/services/storage_service.dart';
import 'package:tutor_finder_app/core/utils/image_helper.dart';
import 'package:tutor_finder_app/core/utils/app_constants.dart';
import 'package:geolocator/geolocator.dart';

class TutorProfilePage extends StatefulWidget {
  const TutorProfilePage({super.key});

  @override
  State<TutorProfilePage> createState() => _TutorProfilePageState();
}

class _TutorProfilePageState extends State<TutorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  // final _subjectsController = TextEditingController(); // Removed for Chips
  final _hourlyRateController = TextEditingController();
  
  // New Controllers
  final _travelRadiusController = TextEditingController();
  final _homeRateDiffController = TextEditingController();
  
  List<String> _selectedSubjects = [];
  List<String> _selectedTeachingModes = [];
  
  bool _isLoading = false;
  UserModel? _currentUser;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        _bioController.text = _currentUser?.bio ?? '';
        _bioController.text = _currentUser?.bio ?? '';
        // _subjectsController.text = _currentUser?.subjects?.join(', ') ?? '';
        _selectedSubjects = List<String>.from(_currentUser?.subjects ?? []);
        _hourlyRateController.text = _currentUser?.hourlyRate?.toString() ?? '';
        _selectedTeachingModes = List<String>.from(_currentUser?.teachingModes ?? []);
        _travelRadiusController.text = _currentUser?.travelRadiusKm?.toString() ?? '';
        _homeRateDiffController.text = _currentUser?.homeRateDifferential?.toString() ?? '';
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _bioController.dispose();
    // _subjectsController.dispose();
    _hourlyRateController.dispose();
    _travelRadiusController.dispose();
    _homeRateDiffController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      /* final subjectsList = _subjectsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(); */

      final updatedUser = _currentUser!.copyWith(
        bio: _bioController.text.trim(),
        subjects: _selectedSubjects,
        hourlyRate: double.tryParse(_hourlyRateController.text.trim()),
        teachingModes: _selectedTeachingModes,
        travelRadiusKm: double.tryParse(_travelRadiusController.text.trim()),
        homeRateDifferential: double.tryParse(_homeRateDiffController.text.trim()),
        updatedAt: DateTime.now(),
      );

      await _authService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully')),
        );
        _fetchUserData(); // Refresh data to reflect saved state
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    // Reduced quality to 20 for Base64 storage
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null && _currentUser != null && mounted) {
      setState(() => _isLoading = true);
      try {
        // final File imageFile = File(pickedFile.path); // Removed to fix Web
        final storageService = StorageService();
        final downloadUrl = await storageService.uploadProfileImage(pickedFile, _currentUser!.uid);

        // Update User Profile with new URL immediately
        final updatedUser = _currentUser!.copyWith(
          profileImageUrl: downloadUrl,
          updatedAt: DateTime.now(),
        );

        await _authService.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated!')),
          );
          _fetchUserData();
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateLocation() async {
    setState(() => _isLoading = true);
    final locationService = LocationService();
    try {
      final position = await locationService.determinePosition();
      
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          updatedAt: DateTime.now(),
        );

        await _authService.updateUser(updatedUser);
        
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location updated successfully!')),
          );
          _fetchUserData();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: ImageHelper.getUserImageProvider(_currentUser?.profileImageUrl),
                    child: _currentUser?.profileImageUrl == null
                        ? Text(
                            (_currentUser?.firstName ?? '').isNotEmpty 
                                ? _currentUser!.firstName![0].toUpperCase() 
                                : 'T',
                            style: const TextStyle(fontSize: 40, color: Colors.grey),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        onPressed: _pickAndUploadImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 8),
            const Text('Update your professional details below.'),
            const SizedBox(height: 24),
            
            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Bio / About Me',
                hintText: 'Tell students about your experience and teaching style...',
                alignLabelWithHint: true,
              ),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a bio' : null,
            ),
            const SizedBox(height: 16),

            // Subjects (Chips)
            const Text('Subjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: AppConstants.subjectsList.map((subject) {
                return FilterChip(
                  label: Text(subject),
                  selected: _selectedSubjects.contains(subject),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedSubjects.add(subject);
                      } else {
                        _selectedSubjects.remove(subject);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            if (_selectedSubjects.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text('Please select at least one subject', style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            const SizedBox(height: 16),

            // Teaching Modes
            const Text('Teaching Modes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Online Tuition'),
              value: _selectedTeachingModes.contains('online'),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedTeachingModes.add('online');
                  } else {
                    _selectedTeachingModes.remove('online');
                  }
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Home Tuition (In-Person)'),
              value: _selectedTeachingModes.contains('home'),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedTeachingModes.add('home');
                  } else {
                    _selectedTeachingModes.remove('home');
                  }
                });
              },
            ),
            const SizedBox(height: 16),

            // Home Tuition Specific Fields
            if (_selectedTeachingModes.contains('home')) ...[
               TextFormField(
                controller: _travelRadiusController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Travel Radius (km)',
                  prefixIcon: Icon(Icons.map),
                  helperText: 'How far are you willing to travel?',
                ),
              ),
              const SizedBox(height: 16),
               TextFormField(
                controller: _homeRateDiffController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Home Tuition Rate Extra (\u0024)',
                  prefixIcon: Icon(Icons.add_circle_outline),
                  helperText: 'Extra amount added to hourly rate for home tuition',
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),

            // Hourly Rate
            TextFormField(
              controller: _hourlyRateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Hourly Rate (\u0024)',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Required';
                if (double.tryParse(val) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),

             // Gender Dropdown
            DropdownButtonFormField<String>(
              value: _currentUser?.gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.person),
              ),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null && _currentUser != null) {
                  setState(() {
                    _currentUser = _currentUser!.copyWith(gender: newValue);
                  });
                }
              },
            ),
            const SizedBox(height: 32),

            // Location Update Section
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _updateLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Update My Location to Current Position'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
