import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';

class GetAllBookingsUseCase {
  final AdminRepository repository;

  GetAllBookingsUseCase(this.repository);

  Stream<List<BookingModel>> call() {
    return repository.getAllBookings();
  }
}
