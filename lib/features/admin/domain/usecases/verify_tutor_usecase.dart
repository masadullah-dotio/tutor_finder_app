import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';

class VerifyTutorUseCase {
  final AdminRepository repository;

  VerifyTutorUseCase(this.repository);

  Future<void> call(String uid) {
    return repository.verifyTutor(uid);
  }
}
