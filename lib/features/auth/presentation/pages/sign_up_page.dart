import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_role.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:tutor_finder_app/features/parent/presentation/pages/parent_dashboard.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_dashboard.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_dashboard.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

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
            const _SignUpForm(),
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
                child: _SignUpForm(),
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
          size: isMobile ? 48 : 128, // Reduced from 64
          color: color,
        ),
        const SizedBox(height: 12), // Reduced from 16
        Text(
          'Tutor Finder',
          style: isMobile
              ? Theme.of(context).textTheme.headlineSmall?.copyWith( // Smaller header
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

class _SignUpForm extends StatefulWidget {
  const _SignUpForm();

  @override
  State<_SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<_SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.student;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_passwordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match';
        }

        final userModel = await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _usernameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          mobilePhone: _phoneController.text.trim(),
          role: _selectedRole,
        );

        if (mounted) {
          final role = userModel?.role;
          String routeName;

          switch (role) {
            case UserRole.student:
              routeName = AppRoutes.studentDashboard;
              break;
            case UserRole.tutor:
              routeName = AppRoutes.tutorDashboard;
              break;
            default:
              routeName = AppRoutes.studentDashboard;
          }

          Navigator.of(context).pushReplacementNamed(routeName);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Name Fields
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Username
          TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              // Allowed: a-z (lowercase), 0-9, ., _, -
              final regex = RegExp(r'^[a-z0-9._-]+$');
              if (!regex.hasMatch(value)) {
                return 'Lowercase letters, numbers, dot, underscore, hyphen only.';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 16),
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
               if (value == null || value.isEmpty) return 'Required';
               if (!value.contains('@')) return 'Invalid email';
               return null;
            },
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              // Check for legitimate phone number format
              // Allows optional +, followed by 10-15 digits.
              final regex = RegExp(r'^\+?[0-9]{10,15}$');
              if (!regex.hasMatch(value)) {
                return 'Invalid phone number (e.g., +1234567890)';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Mobile Phone',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          // Role Selection
          DropdownButtonFormField<UserRole>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'I am a',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: UserRole.values
                .where((role) => role != UserRole.admin)
                .map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.toStringValue.toUpperCase()),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRole = val);
              }
            },
          ),
          const SizedBox(height: 16),
          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            validator: (value) =>
                (value?.length ?? 0) < 6 ? 'Min 6 chars' : null,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            validator: (value) => value != _passwordController.text
                ? 'Passwords do not match'
                : null,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isLoading ? null : _signUp,
            style: FilledButton.styleFrom(),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Sign Up'),
          ),


          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
            },
            child: const Text('Already have an account? Sign In'),
          ),
        ],
      ),
    );
  }
}
