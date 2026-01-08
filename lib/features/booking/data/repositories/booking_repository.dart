import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:dartz/dartz.dart';

class BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Either<String, void>> createBooking(BookingModel booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<List<BookingModel>> getBookingsForTutor(String tutorId) {
    return _firestore
        .collection('bookings')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();
    });
  }

  Stream<List<BookingModel>> getBookingsForStudent(String studentId) {
    return _firestore
        .collection('bookings')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data()))
          .toList();
    });
  }
}
