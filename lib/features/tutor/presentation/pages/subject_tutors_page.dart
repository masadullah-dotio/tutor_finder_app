import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/services/location_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/tutor/presentation/widgets/tutor_card.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:geolocator/geolocator.dart';

class SubjectTutorsPage extends StatefulWidget {
  final String subject;

  const SubjectTutorsPage({super.key, required this.subject});

  @override
  State<SubjectTutorsPage> createState() => _SubjectTutorsPageState();
}

class _SubjectTutorsPageState extends State<SubjectTutorsPage> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  
  List<UserModel> _tutors = [];
  bool _isLoading = true;
  Position? _currentPosition;
  
  // View State
  bool _isListView = true;

  // Pagination State
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    
    // Fetch Location and Tutors in parallel
    try {
      final results = await Future.wait([
        _locationService.determinePosition().catchError((e) => null), // Allow location to fail silently
        _authService.getAllTutors(),
      ]);

      if (mounted) {
        setState(() {
          // 1. Set Location
          if (results[0] is Position) {
            _currentPosition = results[0] as Position;
          }

          // 2. Filter Tutors by Subject
          final allTutors = results[1] as List<UserModel>;
          _tutors = allTutors.where((tutor) {
            return tutor.subjects?.contains(widget.subject) ?? false;
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error loading tutors: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Large Header Card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _getIconForSubject(widget.subject),
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Find the best ${widget.subject} tutors near you',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), 
                 Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total Tutors Found: ${_tutors.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

           // View Toggle & Controls
          if (!_isLoading && _tutors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.list),
                          color: _isListView ? AppColors.primary : Colors.grey,
                          onPressed: () => setState(() => _isListView = true),
                          tooltip: 'List View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.grid_view),
                          color: !_isListView ? AppColors.primary : Colors.grey,
                          onPressed: () => setState(() => _isListView = false),
                          tooltip: 'Grid View',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // Tutors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tutors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No ${widget.subject} tutors found.',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _buildResultsList(),
          ),

          // Pagination Controls
           if (!_isLoading && _tutors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    'Page $_currentPage of ${(_tutors.length / _itemsPerPage).ceil()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < (_tutors.length / _itemsPerPage).ceil()
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
    final endIndex = (startIndex + _itemsPerPage < _tutors.length)
        ? startIndex + _itemsPerPage
        : _tutors.length;
    
    // Safety check in case filter changes reduced list size below current page
    if (startIndex >= _tutors.length && _tutors.isNotEmpty) {
       // Reset to page 1 if current page is out of bounds (though typically we reset on filter change)
       // But here we don't have real-time filter changes, just initial load.
       return const SizedBox(); 
    }

    final paginatedTutors = _tutors.sublist(startIndex, endIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_isListView) {
           return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

              return TutorCard(
                tutor: tutor,
                distanceKm: distance,
                onTap: () => _navigateToDetails(context, tutor, distance),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

              return TutorCard(
                tutor: tutor, 
                distanceKm: distance,
                onTap: () => _navigateToDetails(context, tutor, distance),
              );
            },
          );
        }
      },
    );
  }

  void _navigateToDetails(BuildContext context, UserModel tutor, double? distance) {
       Navigator.of(context).pushNamed(
        AppRoutes.tutorDetails,
        arguments: {
          'tutor': tutor,
          'distanceKm': distance,
        },
      );
  }

  IconData _getIconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'math': return Icons.calculate;
      case 'physics': return Icons.science;
      case 'coding': return Icons.code;
      case 'english': return Icons.language;
      case 'chemistry': return Icons.biotech;
      case 'biology': return Icons.eco;
      default: return Icons.school;
    }
  }
}
