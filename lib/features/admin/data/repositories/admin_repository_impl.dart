import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/review/data/models/review_model.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';

class AdminRepositoryImpl implements AdminRepository {
  final FirebaseFirestore firestore;

  AdminRepositoryImpl(this.firestore);

  @override
  Stream<List<UserModel>> getAllStudents() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<UserModel>> getAllTutors() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'tutor')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<BookingModel>> getAllBookings() {
    return firestore.collection('bookings').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<ReviewModel>> getAllReviews() {
    return firestore.collection('reviews').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<ReportModel>> getAllReports() {
    return firestore.collection('reports').snapshots().map((doc) { // assuming 'reports' collection
       // Use doc.docs.map... but wait, in snapshots it's a QuerySnapshot
       return doc.docs.map((d) => ReportModel.fromMap(d.data())).toList(); 
    });
  }

  @override
  Future<void> verifyTutor(String uid) async {
    await firestore.collection('users').doc(uid).update({
      'isEmailVerified': true, 
      'isMobilePhoneVerified': true,
    });
  }
}
