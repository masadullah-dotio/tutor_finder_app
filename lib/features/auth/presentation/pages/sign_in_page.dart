import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_role.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:tutor_finder_app/features/parent/presentation/pages/parent_dashboard.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_dashboard.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_dashboard.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.primary,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 600) {
            return const _DesktopLayout();
          } else {
            return const _MobileLayout();
          }
        },
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderBranding(isMobile: true),
            const SizedBox(height: 48),
            const _SignInForm(),
          ],
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Side - Branding
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryVariant,
                  AppColors.secondaryVariant,
                ],
              ),
            ),
            child: const Center(
              child: _HeaderBranding(isMobile: false),
            ),
          ),
        ),
        // Right Side - Form
        Expanded(
          flex: 1,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const SingleChildScrollView(
                padding: EdgeInsets.all(48.0),
                child: _SignInForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderBranding extends StatelessWidget {
  final bool isMobile;

  const _HeaderBranding({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final color = isMobile ? AppColors.primary : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.school_rounded,
          size: isMobile ? 48 : 128, // Reduced from 64 for mobile
          color: color,
        ),
        const SizedBox(height: 12), // Reduced from 16
        Text(
          'Tutor Finder',
          style: isMobile 
            ? Theme.of(context).textTheme.headlineSmall?.copyWith( // Smaller headline for mobile
                fontWeight: FontWeight.bold,
                color: color,
              )
            : Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        if (!isMobile) ...[
          const SizedBox(height: 16),
          Text(
            'Find your perfect tutor today.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ],
    );
  }
}

class _SignInForm extends StatefulWidget {
  const _SignInForm();

  @override
  State<_SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<_SignInForm> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers for Tab 1 (Email/Username)
  final _emailUsernameController = TextEditingController();
  final _password1Controller = TextEditingController();

  // Controllers for Tab 2 (Phone)
  final _phoneController = TextEditingController();
  final _password2Controller = TextEditingController();

  bool _isPasswordVisible = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        // Rebuild to update UI based on tab index if needed
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailUsernameController.dispose();
    _password1Controller.dispose();
    _phoneController.dispose();
    _password2Controller.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    final isPhone = _tabController.index == 1;

    try {
      final identifier = isPhone 
          ? _phoneController.text.trim()
          : _emailUsernameController.text.trim();
      
      final password = isPhone
          ? _password2Controller.text
          : _password1Controller.text;

      if (identifier.isEmpty || password.isEmpty) {
        throw 'Please fill all fields';
      }

      final userModel = await _authService.signIn(
        identifier: identifier,
        password: password,
        isPhone: isPhone,
      );

      if (mounted) {
        if (userModel == null) throw 'Failed to retrieve user data';

        final role = userModel.role;
        String routeName;

        switch (role) {
          case UserRole.student:
            routeName = AppRoutes.studentDashboard;
            break;
          case UserRole.tutor:
            routeName = AppRoutes.tutorDashboard;
            break;
          case UserRole.parent:
            // Placeholder route if not defined yet, or add to AppRoutes
            routeName = AppRoutes.studentDashboard; 
            break;
          case UserRole.admin:
             // Placeholder route
            routeName = AppRoutes.studentDashboard;
            break;
        }

        Navigator.of(context).pushNamedAndRemoveUntil(
          routeName,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Email / Username'),
              Tab(text: 'Phone Number'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Form Fields
        if (_tabController.index == 0) ...[
          // Email/Username Tab
          TextFormField(
            controller: _emailUsernameController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email or Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password1Controller,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
        ] else ...[
          // Phone Tab
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password2Controller,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
          ),
        ],

        const SizedBox(height: 32),
        
        // Sign In Button
        FilledButton(
          onPressed: _isLoading ? null : _signIn,
          // Removed manual style here to let Theme take control
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Sign In'),
        ),


        
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
          },
          child: const Text("Don't have an account? Sign Up"),
        ),
      ],
    );
  }
}
