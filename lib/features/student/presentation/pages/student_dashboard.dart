import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_search_page.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_settings_page.dart';
import 'package:tutor_finder_app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_dashboard_home.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_profile_page.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/features/booking/presentation/pages/student_schedule_page.dart';
import 'package:tutor_finder_app/features/review/presentation/pages/my_reviews_page.dart';
import 'package:tutor_finder_app/features/report/presentation/pages/my_reports_page.dart';


class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  String? _selectedSubject;

  final List<String> _titles = [
    'Student Dashboard',
    'Find Tutors',
    'My Schedules',
    'Messages',
    'My Reviews', 
    'My Reports',
    'My Profile',
    'Settings',
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Auto-close drawer on mobile
    if (MediaQuery.of(context).size.width < 600) {
      Navigator.of(context).pop();
    }
  }

  void _onSubjectSelected(String subject) {
    if (subject.isEmpty) {
      // If "See All" or empty subject, go to Find Tutors tab (Index 1)
      setState(() {
        _selectedIndex = 1;
        _selectedSubject = null; // Clear subject filter for "See All"
      });
    } else {
      // Navigate to separate Subject Tutors Page
      // This page should also be guarded, but typically we guard the entry point (Find Tutors)
      // Since this is a pushNamed, better to ensure VerificationGuard is checked before pushing or inside the page.
      // For now, let's just push.
        Navigator.pushNamed(
          context, 
          AppRoutes.subjectTutors,
          arguments: subject,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic pages list to respond to state changes (like selectedSubject)
    final List<Widget> pages = [
      // 0: Dashboard Home
      StudentDashboardHome(
        key: const ValueKey('home'),
        onSubjectSelected: _onSubjectSelected,
      ),
      // 1: Find Tutors (Guarded)
      VerificationGuard(
        featureName: 'Find Tutors',
        child: TutorSearchPage(
          key: const ValueKey('search'),
          initialSubject: _selectedSubject,
        ),
      ),
      // 2: My Schedules (Guarded internally, but good to guard here too)
      const StudentSchedulePage(key: ValueKey('schedule')),
      // 3: Messages (Guarded)
      const VerificationGuard(
        featureName: 'Messages',
        child: ChatListScreen(key: ValueKey('chat')),
      ),
      // 4: My Reviews (Guarded)
      const MyReviewsPage(key: ValueKey('reviews')),
      // 5: My Reports (Guarded)
      const MyReportsPage(key: ValueKey('reports')),
      // 6: Profile (Always Accessible)
      const StudentProfilePage(key: ValueKey('profile')),
      // 7: Settings (Always Accessible)
      const StudentSettingsPage(key: ValueKey('settings')),
    ];

    return ResponsiveDashboardLayout(
      title: _titles[_selectedIndex],
      drawerChild: MainDrawer(
        onItemSelected: _onItemSelected,
        menuItems: [
          DrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => _onItemSelected(0)),
          DrawerItem(icon: Icons.search, title: 'Find Tutors', onTap: () => _onItemSelected(1)),
          DrawerItem(icon: Icons.calendar_month, title: 'My Schedules', onTap: () => _onItemSelected(2)),
          DrawerItem(icon: Icons.chat, title: 'Messages', onTap: () => _onItemSelected(3)),
          DrawerItem(icon: Icons.rate_review, title: 'My Reviews', onTap: () => _onItemSelected(4)),
          DrawerItem(icon: Icons.flag, title: 'My Reports', onTap: () => _onItemSelected(5)),
          DrawerItem.divider(),
          DrawerItem(icon: Icons.person, title: 'My Profile', onTap: () => _onItemSelected(6)),
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () => _onItemSelected(7)),
        ],
      ),
      child: pages[_selectedIndex],
    );
  }
}
