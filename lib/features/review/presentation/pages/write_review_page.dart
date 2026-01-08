import 'package:flutter/material.dart';
import 'package:tutor_finder_app/features/review/presentation/widgets/star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';
import 'package:tutor_finder_app/features/review/data/repositories/review_repository.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';

class WriteReviewPage extends StatefulWidget {
  final UserModel tutor;

  const WriteReviewPage({super.key, required this.tutor});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final _commentController = TextEditingController();
  final _repository = ReviewRepository();
  final _authService = AuthService();
  
  double _rating = 0.0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUserJson = await _authService.getCurrentUser();
    
    // Safety check if user somehow deleted (shouldn't happen here normally)
    if (currentUserJson == null) {
      setState(() { _isLoading = false; });
      return;
    }
    
    // We need the Current User Model to get the Name. 
    // AuthService returns generic obj or stream? 
    // Let's assume we can fetch it. 
    // For MVP fast path: using FirebaseAuth display name or fallback.
    // Ideally we fetch the UserModel.
    // Let's rely on FirebaseAuth profile for now or fetch doc.
    // Let's fetch doc.
    
    // Wait, `AuthService` might store it. 
    // Let's use `AuthService().getUserStream` or similar if available, or just fetch.
    // Actually, let's just fetch it once here.
    
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    // We need the name.
    // Let's assume we can get it from a provider or just fetch simple.
    // I'll fetch it using AuthService if possible or Firestore directly for speed here.
    // But `ReviewRepository` is for reviews.
    // Let's just pass "Anonymous" if fail, or get from FirebaseAuth.currentUser.displayName
    
    final user = FirebaseAuth.instance.currentUser;
    final studentName = user?.displayName ?? 'Student'; 

    final review = ReviewModel(
      id: const Uuid().v4(),
      tutorId: widget.tutor.uid,
      studentId: currentUserId,
      studentName: studentName,
      rating: _rating,
      comment: _commentController.text.trim(),
      timestamp: DateTime.now(),
    );

    final result = await _repository.addReview(review);

    setState(() {
      _isLoading = false;
    });

    result.fold(
      (error) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      ),
      (_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate ${widget.tutor.firstName} ${widget.tutor.lastName}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            // Rating Bar
            StarRating(
              rating: _rating,
              onRatingChanged: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
              size: 40,
            ),
            
            const SizedBox(height: 40),
            
            // Comment Field
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.grey[800] 
                    : Colors.grey[100],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Review',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
