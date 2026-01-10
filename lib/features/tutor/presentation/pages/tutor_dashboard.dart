import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_profile_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_settings_page.dart';
import 'package:tutor_finder_app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_dashboard_home.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_my_reviews_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_bookings_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_calendar_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_reports_page.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Tutor Dashboard',
    'Messages',
    'My Bookings',
    'Calendar',
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

  @override
  Widget build(BuildContext context) {
    // Dynamic pages list
    final List<Widget> pages = [
      const TutorDashboardHome(key: ValueKey('home')),
      // Messages (Guarded)
      const VerificationGuard(
        featureName: 'Messages',
        child: ChatListScreen(key: ValueKey('chat')),
      ),
      // Bookings (Guarded internally)
      const TutorBookingsPage(key: ValueKey('bookings')),
      // Calendar (Guarded) - Need to guard here as CalendarPage might not stick to it
      const VerificationGuard(
        featureName: 'Calendar',
        child: TutorCalendarPage(key: ValueKey('calendar')),
      ),
      // Reviews (Guarded internally)
      const TutorMyReviewsPage(key: ValueKey('reviews')),
      // Reports (Guarded internally)
      const TutorReportsPage(key: ValueKey('reports')),
      // Profile (Accessible)
      const TutorProfilePage(key: ValueKey('profile')),
      // Settings (Accessible)
      const TutorSettingsPage(key: ValueKey('settings')),
    ];

    return ResponsiveDashboardLayout(
      title: _titles[_selectedIndex],
      drawerChild: MainDrawer(
        onItemSelected: _onItemSelected,
        menuItems: [
          DrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => _onItemSelected(0)),
          DrawerItem(icon: Icons.chat, title: 'Messages', onTap: () => _onItemSelected(1)),
          DrawerItem(icon: Icons.book_online, title: 'My Bookings', onTap: () => _onItemSelected(2)),
          DrawerItem(icon: Icons.calendar_month, title: 'Calendar', onTap: () => _onItemSelected(3)),
          DrawerItem(icon: Icons.star, title: 'My Reviews', onTap: () => _onItemSelected(4)),
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
