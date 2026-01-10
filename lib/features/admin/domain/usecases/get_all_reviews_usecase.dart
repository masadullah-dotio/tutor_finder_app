import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';

class GetAllReviewsUseCase {
  final AdminRepository repository;

  GetAllReviewsUseCase(this.repository);

  Stream<List<ReviewModel>> call() {
    return repository.getAllReviews();
  }
}
