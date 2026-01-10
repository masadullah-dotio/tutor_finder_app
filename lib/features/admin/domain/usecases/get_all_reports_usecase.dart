import 'package:tutor_finder_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';

class GetAllReportsUseCase {
  final AdminRepository repository;

  GetAllReportsUseCase(this.repository);

  Stream<List<ReportModel>> call() {
    return repository.getAllReports();
  }
}
