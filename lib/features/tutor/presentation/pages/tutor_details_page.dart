import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/chat/data/services/chat_service.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';
import 'package:tutor_finder_app/features/review/data/repositories/review_repository.dart';
import 'package:tutor_finder_app/features/review/presentation/widgets/star_rating.dart';
import 'package:intl/intl.dart';
import 'package:tutor_finder_app/core/utils/image_helper.dart';
import 'package:tutor_finder_app/features/report/presentation/widgets/report_dialog.dart';
import 'package:tutor_finder_app/core/presentation/widgets/fade_in_slide.dart';

class TutorDetailsPage extends StatelessWidget {
  final UserModel tutor;
  final double? distanceKm;

  const TutorDetailsPage({
    super.key, 
    required this.tutor,
    this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = tutor.subjects ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${tutor.firstName ?? ''} ${tutor.lastName ?? ''}'.trim(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ReportDialog(
                  reportedUserId: tutor.uid,
                  reportedUserName: '${tutor.firstName ?? ''} ${tutor.lastName ?? ''}'.trim(),
                ),
              );
            },
            icon: const Icon(Icons.flag_outlined, color: Colors.white),
            tooltip: 'Report Tutor',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Header
            FadeInSlide(
              duration: const Duration(milliseconds: 600),
              offset: -0.1, // mapped roughly to negative slide
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 100, bottom: 40, left: 24, right: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: ImageHelper.getUserImageProvider(tutor.profileImageUrl),
                        child: tutor.profileImageUrl == null
                            ? Text(
                                (tutor.firstName ?? 'T').isNotEmpty ? (tutor.firstName ?? 'T')[0].toUpperCase() : 'T',
                                style: const TextStyle(fontSize: 48, color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${tutor.firstName ?? ''} ${tutor.lastName ?? ''}'.trim(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    if (tutor.hourlyRate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '\$${tutor.hourlyRate}/hr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    // Average Rating
                    const SizedBox(height: 8),
                    if (tutor.averageRating != null && tutor.averageRating! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StarRating(
                              rating: tutor.averageRating!,
                              starCount: 5,
                              size: 16.0,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${tutor.reviewCount ?? 0})',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            FadeInSlide(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Section
                    if (distanceKm != null) ...[
                      _buildSectionTitle(context, 'Location'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${distanceKm!.toStringAsFixed(1)} km away',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Text(
                                  'Calculated from your current location',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Personal Info
                    _buildSectionTitle(context, 'Contact Info'),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.email, color: AppColors.primary),
                      title: Text(tutor.email),
                      subtitle: const Text('Email'),
                    ),
                    if (tutor.mobilePhone != null && tutor.mobilePhone!.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.phone, color: AppColors.primary),
                        title: Text(tutor.mobilePhone!),
                        subtitle: const Text('Mobile Phone'),
                      ),
                    const SizedBox(height: 24),

                    // Bio
                    _buildSectionTitle(context, 'About Me'),
                    const SizedBox(height: 8),
                    Text(
                      tutor.bio ?? 'No bio available.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 24),

                    // Subjects (Hide for students if empty)
                    if ((tutor.role != UserRole.student) || subjects.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Subjects'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: subjects.map((subject) {
                          return Chip(
                            label: Text(subject),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            labelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () {
                                 // Navigate to Booking Page
                                 Navigator.pushNamed(
                                   context, 
                                   AppRoutes.bookingPage,
                                   arguments: tutor,
                                 );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary, width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text(
                                'Book Session',
                                style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: () async {
                                try {
                                  final currentUser = FirebaseAuth.instance.currentUser;
                                  if (currentUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please sign in to contact tutors')),
                                    );
                                    Navigator.pushNamed(context, AppRoutes.signIn);
                                    return;
                                  }
        
                                  if (currentUser.uid == tutor.uid) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('You cannot message yourself')),
                                    );
                                    return;
                                  }
        
                                  // Show loading
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Starting chat...'), duration: Duration(seconds: 1)),
                                  );
        
                                  final chatService = ChatService();
                                  final roomId = await chatService.createOrGetChatRoom(tutor.uid, tutor);
        
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.chatScreen,
                                      arguments: {
                                        'roomId': roomId,
                                        'otherUser': tutor,
                                      },
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.email),
                              label: const Text(
                                'Message', 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                              ),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                shadowColor: AppColors.primary.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Reviews Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         _buildSectionTitle(context, 'Reviews'),
                         if (tutor.role != UserRole.student) // Only show if not student
                           TextButton.icon(
                             onPressed: () {
                                Navigator.pushNamed(
                                   context, 
                                   AppRoutes.writeReview,
                                   arguments: tutor,
                                 );
                             },
                             icon: const Icon(Icons.rate_review, size: 18),
                             label: const Text('Write a Review'),
                           ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    StreamBuilder<List<ReviewModel>>(
                      stream: ReviewRepository().getReviewsForTutor(tutor.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final reviews = snapshot.data ?? [];
                        
                        if (reviews.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No reviews yet. Be the first to review!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: reviews.length > 3 ? 3 : reviews.length, // Limit to 3 for preview
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey[800] 
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.studentName,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        DateFormat.yMMMd().format(review.timestamp),
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  StarRating(
                                    rating: review.rating,
                                    starCount: 5,
                                    size: 14.0,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(review.comment),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                     const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
