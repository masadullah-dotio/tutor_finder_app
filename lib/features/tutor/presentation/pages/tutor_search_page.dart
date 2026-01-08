import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/tutor/presentation/widgets/tutor_card.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_details_page.dart';
import 'package:tutor_finder_app/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/location_permission_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/constants/app_constants.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/presentation/widgets/fade_in_slide.dart';

class TutorSearchPage extends StatefulWidget {
  final String? initialSubject;
  const TutorSearchPage({super.key, this.initialSubject});

  @override
  State<TutorSearchPage> createState() => _TutorSearchPageState();
}

class _TutorSearchPageState extends State<TutorSearchPage> {
  final AuthService _authService = AuthService();
  
  // Data State
  List<UserModel> _allTutors = [];
  List<UserModel> _filteredTutors = [];
  List<String> _subjects = [];
  bool _isLoading = true;

  // Filter State
  String? _selectedSubject; // null means "All"
  RangeValues _priceRange = const RangeValues(10, 100);
  final double _minPriceLimit = 10;
  final double _maxPriceLimit = 100;
  String? _selectedGender;
  double _minRating = 0.0;

  // View State
  bool _isListView = true;
  
  // Pagination State
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  // Location State
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  double _searchRadiusKm = 10.0; // Default radius
  bool _useLocationFilter = true; // Default to TRUE as per requirement
  bool _hasLocationPermission = false;
  final double _maxRadius = 50.0;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
    _checkLocationPermission();
    _fetchTutors();
    _searchController.addListener(_applyFilters);
  }

  @override
  void didUpdateWidget(TutorSearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubject != oldWidget.initialSubject) {
      setState(() {
        _selectedSubject = widget.initialSubject;
        _applyFilters();
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      await _locationService.determinePosition();
      setState(() {
        _hasLocationPermission = true;
      });
      _getCurrentLocation();
    } catch (_) {
      // Permission not granted or service disabled
      setState(() {
        _hasLocationPermission = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.determinePosition();
      setState(() {
        _currentPosition = position;
        if (_useLocationFilter) _applyFilters();
      });

      // Auto-update Student Profile with new location
      _updateStudentLocation(position);

    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _updateStudentLocation(Position position) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // We can use a partial update or fetch-then-update. 
        // Since we don't have the full UserModel here in state, we can do a direct Firestore update
        // OR fetch it. Direct update is more efficient if we just want to patch fields.
        // BUT AuthService.updateUser takes a UserModel.
        // Let's use direct Firestore patch for efficiency and safety against overwriting other fields.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        print('Student location updated in background.');
      }
    } catch (_) {
      // Ignore errors in background update
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _fetchTutors() async {
    setState(() => _isLoading = true);
    final tutors = await _authService.getAllTutors();
    
    // Use AppConstants for subjects + any others found in existing tutors?
    // Requirement says "same list", so let's stick to AppConstants primarily, 
    // or maybe merge them if we want to be safe. 
    // Given the requirement "they should be same", let's strict it to AppConstants.
    // However, to implementation properly, let's map AppConstants to just names string list.
    
    final constantSubjects = AppConstants.subjects.map((s) => s['name'] as String).toList();

    if (mounted) {
      setState(() {
        _allTutors = tutors;
        _subjects = constantSubjects..sort();
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredTutors = _allTutors.where((tutor) {
        // 1. Search Query
        final name = '${tutor.firstName} ${tutor.lastName}'.toLowerCase();
        final subjects = tutor.subjects?.join(' ').toLowerCase() ?? '';
        final matchesQuery = name.contains(query) || subjects.contains(query);

        // 2. Subject Filter
        final matchesSubject = _selectedSubject == null || 
            (tutor.subjects?.contains(_selectedSubject) ?? false);

        // 3. Price Filter
        final double rate = tutor.hourlyRate ?? 0.0;
        final matchesPrice = rate >= _priceRange.start && rate <= _priceRange.end;

        // 4. Location Filter (Radius)
        bool matchesLocation = true;
        
        if (_useLocationFilter && _currentPosition != null && 
            tutor.latitude != null && tutor.longitude != null) {
          
          final distance = _locationService.calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            tutor.latitude!,
            tutor.longitude!,
          );
          
          matchesLocation = distance <= _searchRadiusKm;
        }

        // 5. Gender Filter
        final matchesGender = _selectedGender == null || tutor.gender == _selectedGender;

        // 6. Rating Filter
        final double rating = tutor.averageRating ?? 0.0;
        final matchesRating = rating >= _minRating;

        return matchesQuery && matchesSubject && matchesPrice && matchesLocation && matchesGender && matchesRating;
      }).toList();

      // Reset to page 1 on filter change
      _currentPage = 1;
    });
  }

  void _requestLocationPermission() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPermissionPage(
          onPermissionGranted: () {
            Navigator.pop(context); // Close permission page
            _checkLocationPermission(); // Re-check
          },
        ),
      ),
    );
  }

  void _showPriceFilterDialog() {
    // Sync controllers with current range
    _minPriceController.text = _priceRange.start.round().toString();
    _maxPriceController.text = _priceRange.end.round().toString();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Filter by Hourly Rate'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('\$'),
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min'),
                          onChanged: (val) {
                            final min = double.tryParse(val) ?? _minPriceLimit;
                            if (min < _maxPriceLimit) {
                               setStateDialog(() {
                                 _priceRange = RangeValues(min, _priceRange.end);
                               });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('-'),
                      const SizedBox(width: 10),
                      const Text('\$'),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Max'),
                          onChanged: (val) {
                            final max = double.tryParse(val) ?? _maxPriceLimit;
                            if (max > _priceRange.start) {
                               setStateDialog(() {
                                 _priceRange = RangeValues(_priceRange.start, max);
                               });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPriceLimit,
                    max: _maxPriceLimit, // Or a higher max if needed dynamically
                    divisions: 90,
                    labels: RangeLabels(
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setStateDialog(() {
                        _priceRange = values;
                        _minPriceController.text = values.start.round().toString();
                        _maxPriceController.text = values.end.round().toString();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset
                    setStateDialog(() {
                      _priceRange = RangeValues(_minPriceLimit, _maxPriceLimit);
                    });
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 1. Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or subject',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Filters & View Toggles Row
          Row(
            children: [
              // Filters Section (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All" Filter
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedSubject == null,
                        onSelected: (bool selected) {
                          if (selected) {
                            setState(() {
                              _selectedSubject = null;
                              _applyFilters();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),

                      // "Subjects" Dropdown
                      PopupMenuButton<String>(
                        initialValue: _selectedSubject,
                        onSelected: (String subject) {
                           setState(() {
                             _selectedSubject = subject;
                             _applyFilters();
                           });
                        },
                        itemBuilder: (BuildContext context) {
                          return _subjects.map((String subject) {
                            return PopupMenuItem<String>(
                              value: subject,
                              child: Text(subject),
                            );
                          }).toList();
                        },
                        child: Chip(
                          label: Text(_selectedSubject ?? 'Subjects'),
                          deleteIcon: const Icon(Icons.arrow_drop_down),
                          onDeleted: () {}, 
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Price Filter
                      ActionChip(
                        avatar: const Icon(Icons.attach_money, size: 16),
                        label: Text('\$${_priceRange.start.round()} - \$${_priceRange.end.round()}'),
                        onPressed: _showPriceFilterDialog,
                      ),
                      const SizedBox(width: 8),

                      // Gender Filter
                      DropdownButton<String>(
                        value: _selectedGender,
                        hint: const Text("Gender"),
                        icon: const Icon(Icons.arrow_drop_down, size: 20),
                        underline: Container(), // Remove underline
                        items: [
                          const DropdownMenuItem<String>(value: null, child: Text("All")),
                          const DropdownMenuItem<String>(value: "Male", child: Text("Male")),
                          const DropdownMenuItem<String>(value: "Female", child: Text("Female")),
                        ],
                        onChanged: (val) {
                          setState(() {
                            _selectedGender = val;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(width: 8),

                      // Rating Filter
                      DropdownButton<double>(
                        value: _minRating,
                        hint: const Text("Rating"),
                        icon: const Icon(Icons.star, size: 16, color: AppColors.warning),
                        underline: Container(),
                        items: [0.0, 3.0, 4.0, 4.5].map((double val) {
                          return DropdownMenuItem<double>(
                            value: val,
                            child: Text(val == 0.0 ? "All Ratings" : "$val+ Stars"),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _minRating = val;
                              _applyFilters();
                            });
                          }
                        },
                      ),
                      const SizedBox(width: 8),

                      // Location Filter
                      ActionChip(
                        avatar: Icon(
                          _hasLocationPermission ? Icons.location_on : Icons.location_off,
                          size: 16,
                          color: _useLocationFilter ? Colors.white : null,
                        ),
                        label: Text(_useLocationFilter 
                            ? '${_searchRadiusKm.round()} km' 
                            : 'Location'),
                        backgroundColor: _useLocationFilter ? Theme.of(context).primaryColor : null,
                        labelStyle: TextStyle(
                          color: _useLocationFilter ? Colors.white : null,
                        ),
                        onPressed: () {
                          if (!_hasLocationPermission) {
                            _requestLocationPermission();
                          } else {
                            _showLocationFilterDialog();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // View Toggles Section (Fixed on Right)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).cardColor 
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.list),
                      color: _isListView ? Theme.of(context).primaryColor : Colors.grey,
                      onPressed: () => setState(() => _isListView = true),
                      tooltip: 'List View',
                    ),
                    IconButton(
                      icon: const Icon(Icons.grid_view),
                      color: !_isListView ? Theme.of(context).primaryColor : Colors.grey,
                      onPressed: () => setState(() => _isListView = false),
                      tooltip: 'Grid View',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Results Area
          Expanded(
            child: _filteredTutors.isEmpty
                ? const Center(child: Text('No tutors match your filters.'))
                : _buildResultsList(),
          ),

          // 4. Pagination Controls
          if (_filteredTutors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text(
                    'Page $_currentPage of ${(_filteredTutors.length / _itemsPerPage).ceil()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < (_filteredTutors.length / _itemsPerPage).ceil()
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    // Pagination Logic
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < _filteredTutors.length)
        ? startIndex + _itemsPerPage
        : _filteredTutors.length;
    
    final paginatedTutors = _filteredTutors.sublist(startIndex, endIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isListView) {
            return ListView.builder(
              itemCount: paginatedTutors.length,
              itemBuilder: (context, index) {
                final tutor = paginatedTutors[index];
                double? distance;
                if (_currentPosition != null && tutor.latitude != null && tutor.longitude != null) {
                  distance = _locationService.calculateDistance(
                    _currentPosition!.latitude, 
                    _currentPosition!.longitude, 
                    tutor.latitude!, 
                    tutor.longitude!
                  );
                }

                return FadeInSlide(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 50 * index), // Staggered delay
                  child: TutorCard(
                    tutor: tutor,
                    distanceKm: distance,
                    onTap: () => _navigateToDetails(context, tutor),
                  ),
                );
              },
            );
        } else {
           // Grid View Responsive Logic
           int crossAxisCount = 2; 
           if (constraints.maxWidth > 900) {
             crossAxisCount = 3;
           }
           
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: paginatedTutors.length,
              itemBuilder: (context, index) {
                final tutor = paginatedTutors[index];
                double? distance;
                if (_currentPosition != null && tutor.latitude != null && tutor.longitude != null) {
                  distance = _locationService.calculateDistance(
                    _currentPosition!.latitude, 
                    _currentPosition!.longitude, 
                    tutor.latitude!, 
                    tutor.longitude!
                  );
                }

                return FadeInSlide(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 50 * index),
                  child: TutorCard(
                    tutor: tutor, 
                    distanceKm: distance,
                    onTap: () => _navigateToDetails(context, tutor),
                  ),
                );
              },
            );
        }
      },
    );
  }

  void _showLocationFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Filter by Distance'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   SwitchListTile(
                    title: const Text('Enable Location Filter'),
                    value: _useLocationFilter,
                    onChanged: (val) {
                      setStateDialog(() {
                        _useLocationFilter = val;
                      });
                      setState(() {
                         _useLocationFilter = val;
                         _applyFilters();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_useLocationFilter) ...[
                     Text('Radius: ${_searchRadiusKm.round()} km'),
                     Slider(
                      value: _searchRadiusKm,
                      min: 1,
                      max: _maxRadius,
                      divisions: 49,
                      label: '${_searchRadiusKm.round()} km',
                      onChanged: (val) {
                        setStateDialog(() {
                          _searchRadiusKm = val;
                        });
                        setState(() {
                           _searchRadiusKm = val;
                           _applyFilters();
                        });
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, UserModel tutor) {
    double? distance;
    if (_currentPosition != null && tutor.latitude != null && tutor.longitude != null) {
      distance = _locationService.calculateDistance(
        _currentPosition!.latitude, 
        _currentPosition!.longitude, 
        tutor.latitude!, 
        tutor.longitude!
      );
    }

    Navigator.of(context).pushNamed(
      AppRoutes.tutorDetails,
      arguments: {
        'tutor': tutor,
        'distanceKm': distance,
      },
    );
  }
}
