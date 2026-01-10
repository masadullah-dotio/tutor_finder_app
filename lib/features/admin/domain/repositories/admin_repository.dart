import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';

abstract class AdminRepository {
  Stream<List<UserModel>> getAllTutors();
  Stream<List<UserModel>> getAllStudents();
  Stream<List<BookingModel>> getAllBookings();
  Stream<List<ReviewModel>> getAllReviews();
  Stream<List<ReportModel>> getAllReports();
  Future<void> verifyTutor(String uid);
}
