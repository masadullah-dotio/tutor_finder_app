import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/core/services/location_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
// import 'dart:io'; // Removed for Web compatibility
import 'package:image_picker/image_picker.dart';
import 'package:tutor_finder_app/core/services/storage_service.dart';
import 'package:tutor_finder_app/core/utils/image_helper.dart';
import 'package:tutor_finder_app/core/utils/app_constants.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  // final _subjectsController = TextEditingController(); // Removed for Chips
  
  List<String> _selectedSubjects = [];
  
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
        // _subjectsController.text = _currentUser?.subjects?.join(', ') ?? '';
        _selectedSubjects = List<String>.from(_currentUser?.subjects ?? []);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _bioController.dispose();
    // _subjectsController.dispose();
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
        updatedAt: DateTime.now(),
      );

      await _authService.updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile Updated Successfully')),
        );
        _fetchUserData(); // Refresh
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
    // Reduced quality to 20 for Base64 storage optimization
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null && _currentUser != null && mounted) {
      setState(() => _isLoading = true);
      try {
        // final File imageFile = File(pickedFile.path); // Removed for Web
        final storageService = StorageService();
        final downloadUrl = await storageService.uploadProfileImage(pickedFile, _currentUser!.uid);

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

    if (_currentUser == null) {
      return const Center(child: Text("User not found"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: ImageHelper.getUserImageProvider(_currentUser?.profileImageUrl),
                    child: _currentUser?.profileImageUrl == null
                        ? Text(
                            (_currentUser?.firstName ?? '').isNotEmpty 
                                ? _currentUser!.firstName![0].toUpperCase() 
                                : 'S',
                            style: const TextStyle(fontSize: 40, color: AppColors.primary, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            Text(
              '${_currentUser!.firstName ?? ''} ${_currentUser!.lastName ?? ''}'.trim(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              _currentUser!.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio / About Me',
                hintText: 'Tell tutors about yourself...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Subjects (Interests)
            // Interests (Chips)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Interests / Subjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
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
                child: Text('Add some interests to help us find tutors', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            
            // Location Info
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('Location'),
              subtitle: Text((_currentUser!.latitude != null) ? 'Location Set' : 'Not Set'),
              trailing: OutlinedButton(
                onPressed: _isLoading ? null : _updateLocation,
                child: const Text('Update'),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
