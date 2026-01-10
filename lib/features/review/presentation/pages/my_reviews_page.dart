import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/features/review/data/repositories/review_repository.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/utils/time_helper.dart';
import 'package:tutor_finder_app/core/presentation/widgets/simple_star_rating.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We assume AuthService can provide the UID immediately or via FutureBuilder if needed.
    // Reusing the pattern from SchedulePage.
    final authService = Provider.of<AuthService>(context, listen: false);

    return VerificationGuard(
      featureName: 'Reviews',
      child: FutureBuilder(
        future: authService.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           if (!userSnapshot.hasData) {
             return const Center(child: Text('User not found'));
           }
           final userId = userSnapshot.data!.uid;

          return StreamBuilder<List<ReviewModel>>(
            stream: Provider.of<ReviewRepository>(context, listen: false).getReviewsByStudent(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final reviews = snapshot.data ?? [];

              if (reviews.isEmpty) {
                return const Center(child: Text('You haven\'t written any reviews yet.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Card(
                     elevation: 2,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               SimpleStarRating(
                                 rating: review.rating,
                                 size: 20.0,
                               ),
                               Text(
                                  TimeHelper.timeAgo(review.timestamp),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Text(
                             'Review for tutor (ID: ${review.tutorId.substring(0,5)}...)', // Ideally fetch Tutor Name
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                           ),
                           const SizedBox(height: 8),
                           Text(review.comment),
                         ],
                       ),
                     ),
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}
