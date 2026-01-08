import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/presentation/widgets/main_drawer.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';

class ResponsiveDashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final Widget? drawerChild; // Allow passing a configured drawer

  const ResponsiveDashboardLayout({
    super.key,
    required this.child,
    required this.title,
    this.drawerChild,
  });

  @override
  State<ResponsiveDashboardLayout> createState() => _ResponsiveDashboardLayoutState();
}

class _ResponsiveDashboardLayoutState extends State<ResponsiveDashboardLayout> {
  bool _isSidebarOpen = true; // Default open on desktop

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
  }


  @override
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 600;

    // Desktop Layout (Row with Full Sidebar)
    if (isDesktop) {
      return Row(
        children: [
          // Sidebar Column
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarOpen ? size.width * 0.25 : 0,
            child: ClipRect(
              child: OverflowBox(
                maxWidth: size.width * 0.25,
                minWidth: size.width * 0.25,
                alignment: Alignment.topLeft,
                child: widget.drawerChild ?? const MainDrawer(),
              ),
            ),
          ),

          // Main Content + AppBar
          Expanded(
            child: Scaffold(
              appBar: _buildAppBar(isDesktop),
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                child: widget.child,
              ),
            ),
          ),
        ],
      );
    }

    // Mobile Layout (Standard Scaffold with Drawer)
    return Scaffold(
      drawer: widget.drawerChild ?? const MainDrawer(),
      appBar: _buildAppBar(isDesktop),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }

  AppBar _buildAppBar(bool isDesktop) {
    return AppBar(
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: isDesktop 
                ? _toggleSidebar 
                : () => Scaffold.of(context).openDrawer(),
          );
        }
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          widget.title,
          key: ValueKey<String>(widget.title), // Key allows animation when title changes
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
                child: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey<bool>(themeProvider.isDarkMode),
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                themeProvider.toggleTheme(!themeProvider.isDarkMode);
              },
            );
          },
        ),
      ],
    );
  }
}
