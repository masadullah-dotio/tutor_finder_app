import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add review and update tutor's average rating
  Future<Either<String, void>> addReview(ReviewModel review) async {
    try {
      final userRef = _firestore.collection('users').doc(review.tutorId);
      final reviewRef = _firestore.collection('reviews').doc(review.id);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          throw Exception('Tutor not found');
        }

        final data = userDoc.data()!;
        final double currentRating = (data['averageRating'] ?? 0.0).toDouble();
        final int currentCount = (data['reviewCount'] ?? 0).toInt();

        // Calculate new average
        final newCount = currentCount + 1;
        final newAverage = ((currentRating * currentCount) + review.rating) / newCount;

        // Write review
        transaction.set(reviewRef, review.toMap());

        // Update user stats
        transaction.update(userRef, {
          'averageRating': newAverage,
          'reviewCount': newCount,
        });
      });

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<List<ReviewModel>> getReviewsForTutor(String tutorId) {
    return _firestore
        .collection('reviews')
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    });
  }
}
