import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_profile_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_settings_page.dart';
import 'package:tutor_finder_app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_dashboard_home.dart';

class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Dashboard Home
    const TutorDashboardHome(key: ValueKey('home')),
    // Messages
    const ChatListScreen(key: ValueKey('chat')),
    // Profile Page
    const TutorProfilePage(key: ValueKey('profile')),
    // Settings
    const TutorSettingsPage(key: ValueKey('settings')),
  ];

  final List<String> _titles = [
    'Tutor Dashboard',
    'Messages',
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
    return ResponsiveDashboardLayout(
      title: _titles[_selectedIndex],
      drawerChild: MainDrawer(
        onItemSelected: _onItemSelected,
        menuItems: [
          DrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => _onItemSelected(0)),
          DrawerItem(icon: Icons.chat, title: 'Messages', onTap: () => _onItemSelected(1)),
          DrawerItem(icon: Icons.person, title: 'My Profile', onTap: () => _onItemSelected(2)),
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () => _onItemSelected(3)),
        ],
      ),
      child: _pages[_selectedIndex],
    );
  }
}
