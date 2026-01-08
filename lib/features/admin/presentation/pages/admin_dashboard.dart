import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_up_page.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveDashboardLayout(
      title: 'Admin Dashboard',
      child: Center(
        child: Text('Welcome Admin!'),
      ),
    );
  }
}
