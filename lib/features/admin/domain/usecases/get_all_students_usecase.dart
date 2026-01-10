import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';

class GetAllStudentsUseCase {
  final AdminRepository repository;

  GetAllStudentsUseCase(this.repository);

  Stream<List<UserModel>> call() {
    return repository.getAllStudents();
  }
}
