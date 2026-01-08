import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/booking/data/repositories/booking_repository.dart';
import 'package:dartz/dartz.dart';

class BookingService {
  final BookingRepository _repository;

  BookingService({BookingRepository? repository}) 
      : _repository = repository ?? BookingRepository();

  // Create a booking after validating availability
  Future<Either<String, void>> createBooking(BookingModel booking) async {
    // 1. Check availability
    final isAvailable = await _isSlotAvailable(
      booking.tutorId,
      booking.startTime,
      booking.endTime,
    );

    if (!isAvailable) {
      return const Left('This slot is already booked.');
    }

    // 2. Create booking
    return await _repository.createBooking(booking);
  }

  // Check if a time slot is free for a specific tutor
  Future<bool> _isSlotAvailable(
    String tutorId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    // Get all bookings for this tutor
    // NOTE: In a real app, we would query by date range to optimize.
    // For MVP, we fetch ongoing stream or simple query.
    // Since repository returns a stream, we might need a one-time fetch or subscribe.
    // Let's modify repository to have a one-time fetch if needed, 
    // or just listen to the stream for a bit. 
    // Actually, for this check, a direct Firestore query is better, 
    // but to keep it simple with existing repo, let's use a simpler approach:
    // We will assume client-side check on the list we already have or fetch once.
    
    // For now, let's just query Firestore directly here for simplicity of the check,
    // or add a method to repository. Let's add 'getFutureBookings' to repository?
    // Or just use the stream? Stream is async.
    
    // Let's add a simple fetch method to Repository? 
    // No, let's stick to the pattern. We can just take the list from the UI
    // passed down, OR we make this service fetch. 
    
    // Let's implement a direct fetch in this service for now to be safe.
    
    // Wait, let's just use the repo's stream and take first element? 
    // That might be empty if no bookings.
    
    final bookingsStream = _repository.getBookingsForTutor(tutorId);
    final bookings = await bookingsStream.first; 
    
    for (var booking in bookings) {
      // Check overlap
      // Overlap exists if: (StartA < EndB) and (EndA > StartB)
      if (booking.status != 'cancelled' &&
          startTime.isBefore(booking.endTime) &&
          endTime.isAfter(booking.startTime)) {
        return false;
      }
    }
    return true;
  }
}
