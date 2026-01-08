import 'package:flutter/material.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/core/presentation/widgets/responsive_dashboard_layout.dart';
import 'package:tutor_finder_app/features/parent/presentation/pages/parent_settings_page.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    // Dashboard Home
    const Center(key: ValueKey('home'), child: Text('Welcome Parent!')),
    // Settings
    const ParentSettingsPage(key: ValueKey('settings')),
  ];

  final List<String> _titles = [
    'Parent Dashboard',
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
          DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () => _onItemSelected(1)),
        ],
      ),
      child: _pages[_selectedIndex],
    );
  }
}
