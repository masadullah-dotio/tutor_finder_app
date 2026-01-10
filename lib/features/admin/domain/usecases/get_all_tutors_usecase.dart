import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';

class GetAllTutorsUseCase {
  final AdminRepository repository;

  GetAllTutorsUseCase(this.repository);

  Stream<List<UserModel>> call() {
    return repository.getAllTutors();
  }
}
