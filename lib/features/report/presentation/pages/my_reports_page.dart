import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/features/report/data/repositories/report_repository.dart';
import 'package:tutor_finder_app/features/report/data/models/report_model.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/utils/time_helper.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
     final authService = Provider.of<AuthService>(context, listen: false);

    return VerificationGuard(
      featureName: 'Reports',
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
              stream: Provider.of<ReportRepository>(context, listen: false).getReportsByStudent(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reports = snapshot.data ?? [];

                if (reports.isEmpty) {
                  return const Center(child: Text('You haven\'t submitted any reports.'));
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
                                 Container(
                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                   decoration: BoxDecoration(
                                     color: Colors.red[100],
                                     borderRadius: BorderRadius.circular(8),
                                   ),
                                   child: Text(
                                     report.reason,
                                     style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 12),
                                   ),
                                 ),
                                 Text(
                                    TimeHelper.timeAgo(report.timestamp),
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                 ),
                               ],
                             ),
                             const SizedBox(height: 8),
                             Text(
                               'Reported Tutor ID: ${report.reportedUserId.substring(0,5)}...',
                               style: const TextStyle(fontWeight: FontWeight.bold),
                             ),
                             const SizedBox(height: 8),
                             Text(report.description ?? 'No description provided'),
                             const SizedBox(height: 8),
                             Text(
                               'Status: ${report.status}',
                               style: TextStyle(
                                 color: report.status == 'open' ? Colors.orange : Colors.green,
                                 fontWeight: FontWeight.bold
                               ),
                             ),
                           ],
                         ),
                       ),
                    );
                  },
                );
              },
            );
         },
      ),
    );
  }
}
