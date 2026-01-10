import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Either<String, void>> submitReport(ReportModel report) async {
    try {
      await _firestore.collection('reports').doc(report.id).set(report.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Stream<List<ReportModel>> getReportsByStudent(String studentId) {
    return _firestore
        .collection('reports')
        .where('reporterId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    });
  }
}
