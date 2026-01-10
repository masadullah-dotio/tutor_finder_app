import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';
import 'package:tutor_finder_app/features/report/data/repositories/report_repository.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/core/utils/time_helper.dart';

class TutorReportsPage extends StatelessWidget {
  const TutorReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access Repositories via Provider
    final reportRepository = Provider.of<ReportRepository>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    return VerificationGuard(
      featureName: 'My Reports',
      child: FutureBuilder(
        future: authService.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
           if (!userSnapshot.hasData) {
             return const Center(child: Text('User not found'));
           }
           final userId = userSnapshot.data!.uid;

          return StreamBuilder<List<ReportModel>>(
            // reusing getReportsByStudent which filters by reporterId (generic)
            stream: reportRepository.getReportsByStudent(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final reports = snapshot.data ?? [];

              if (reports.isEmpty) {
                return const Center(child: Text('You haven\'t filed any reports yet.'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                     elevation: 2,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                     child: Padding(
                       padding: const EdgeInsets.all(16.0),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: [
                               Text(
                                 report.reason,
                                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.redAccent),
                               ),
                               Text(
                                  TimeHelper.timeAgo(report.timestamp),
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                               ),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Text(
                             'Reported User ID: ${report.reportedUserId.substring(0,5)}...', // Placeholder for name
                             style: const TextStyle(fontWeight: FontWeight.bold),
                           ),
                           const SizedBox(height: 8),
                           Text(report.description ?? 'No description provided'),
                           const SizedBox(height: 8),
                           Row(
                             children: [
                               const Text('Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: report.status == 'resolved' ? Colors.green[100] : Colors.orange[100],
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Text(
                                   report.status.toUpperCase(),
                                   style: TextStyle(
                                     color: report.status == 'resolved' ? Colors.green[800] : Colors.orange[800],
                                     fontSize: 12,
                                     fontWeight: FontWeight.bold
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                  );
                },
              );
            },
          );
        }
      ),
    );
  }
}
