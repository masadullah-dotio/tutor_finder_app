import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/tutor/presentation/widgets/tutor_card.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/core/constants/app_constants.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_search_page.dart';  // Import for pushing route if needed or arguments

class StudentDashboardHome extends StatefulWidget {
  final Function(String subject) onSubjectSelected;

  const StudentDashboardHome({
    super.key, 
    required this.onSubjectSelected,
  });

  @override
  State<StudentDashboardHome> createState() => _StudentDashboardHomeState();
}

class _StudentDashboardHomeState extends State<StudentDashboardHome> {
  final AuthService _authService = AuthService();
  List<UserModel> _tutors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTutors();
  }

  Future<void> _fetchTutors() async {
    final tutors = await _authService.getAllTutors();
    if (mounted) {
      setState(() {
        _tutors = tutors;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // For "Recommended", we can just pick the first few or filter by some logic.
    // For now, let's just reverse the list or take the first 5.
    final recommendedTutors = _tutors.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context),
          const SizedBox(height: 24),
          
          const Text(
            'Explore Subjects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.subjects.length,
              itemBuilder: (context, index) {
                final subject = AppConstants.subjects[index];
                return _buildSubjectCard(
                  context, 
                  subject['name'] as String, 
                  subject['icon'] as IconData, 
                  subject['color'] as Color,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Recommended Tutors Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended Tutors',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                   widget.onSubjectSelected(''); // Empty string or null implies 'All'
                }, 
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _tutors.isEmpty 
              ? _buildEmptyState('No tutors available yet.')
              : SizedBox(
                  height: 260, // Height for TutorCard + Padding
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedTutors.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox(
                          width: 280, // Fixed width for horizontal card
                          child: TutorCard(
                            tutor: recommendedTutors[index],
                            onTap: () => _navigateToDetails(context, recommendedTutors[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: 24),
          const Text(
            'All Tutors',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _tutors.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tutors.length,
                  itemBuilder: (context, index) {
                    return TutorCard(
                      tutor: _tutors[index],
                      onTap: () => _navigateToDetails(context, _tutors[index]),
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to learn?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find your perfect tutor and start your journey today.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.school, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        widget.onSubjectSelected(title);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _navigateToDetails(BuildContext context, UserModel tutor) {
    Navigator.of(context).pushNamed(
      AppRoutes.tutorDetails,
      arguments: {
        'tutor': tutor,
        // Calculate distance if needed, or pass null, or get from LocationService if available here
      },
    );
  }
}
