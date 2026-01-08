import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/auth/presentation/widgets/phone_verification_dialog.dart';
import 'package:tutor_finder_app/features/settings/presentation/widgets/notification_settings_tile.dart';
import 'package:tutor_finder_app/core/presentation/widgets/fade_in_slide.dart';

class StudentSettingsPage extends StatefulWidget {
  const StudentSettingsPage({super.key});

  @override
  State<StudentSettingsPage> createState() => _StudentSettingsPageState();
}

class _StudentSettingsPageState extends State<StudentSettingsPage> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  void _refreshUser() {
    setState(() {
      _userFuture = AuthService().getCurrentUser();
    });
  }

  Future<void> _handleDeactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
            'Are you sure you want to deactivate your account? You will be signed out.\n\nTo reactivate, simply log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AuthService().deactivateAccount();
        await AuthService().signOut();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deactivated successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to PERMANENTLY delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await AuthService().deleteAccount();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
           return Center(child: Text('Error: ${snapshot.error}'));
        }

        final user = snapshot.data;
        if (user == null) {
           return const Center(child: Text('User not found'));
        }

        final isEmailVerified = user.isEmailVerified;
        final isPhoneVerified = user.isMobilePhoneVerified;

        final children = [
            const Text(
              'Student Account Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return SwitchListTile(
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                  title: const Text('Dark Mode'),
                  value: themeProvider.isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                );
              },
            ),
            
            const Divider(height: 32),
            
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Sign Out'),
              onTap: _handleSignOut,
            ),

            const Divider(height: 32),

            NotificationSettingsTile(
              user: user,
              onUpdate: _refreshUser,
            ),
            
            const Divider(height: 32),
            
            const Text(
              'Verification',
               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: Icon(
                isEmailVerified ? Icons.email : Icons.email_outlined,
                color: isEmailVerified ? AppColors.success : AppColors.warning,
              ),
              title: const Text('Email Verification'),
              subtitle: Text(isEmailVerified ? 'Verified' : 'Not Verified'),
              trailing: isEmailVerified 
                ? const Icon(Icons.check_circle, color: AppColors.success)
                : OutlinedButton(
                    onPressed: () async {
                      try {
                         await AuthService().sendEmailVerification();
                         if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Verification email sent! Check your inbox.')),
                           );
                         }
                      } catch(e) {
                        if (mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Error: $e')),
                           );
                         }
                      }
                    }, 
                    child: const Text('Verify'),
                  ),
            ),

            ListTile(
              leading: Icon(
                isPhoneVerified ? Icons.phone_android : Icons.phone_android_outlined,
                color: isPhoneVerified ? AppColors.success : AppColors.warning,
              ),
              title: const Text('Phone Verification'),
              subtitle: Text(isPhoneVerified ? 'Verified' : 'Not Verified'),
              trailing: isPhoneVerified 
                      ? const Icon(Icons.check_circle, color: AppColors.success)
                      : OutlinedButton(
                          onPressed: () async {
                             final result = await showDialog<bool>(
                               context: context,
                               builder: (context) => PhoneVerificationDialog(
                                 initialPhoneNumber: user.mobilePhone,
                               ),
                             );
                             
                             if (result == true) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Phone verified successfully!')),
                                  );
                                }
                                _refreshUser();
                             }
                          }, 
                          child: const Text('Verify'),
                        ),
            ),

            const Divider(height: 32),

            const Text(
              'Danger Zone',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.no_accounts, color: AppColors.warning),
              title: const Text('Deactivate Account'),
              subtitle: const Text('Temporarily disable your account'),
              onTap: _handleDeactivate,
            ),
             ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.error),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently remove your data'),
              onTap: _handleDelete,
            ),
        ];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: children.length,
          itemBuilder: (context, index) {
            return FadeInSlide(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: 30 * index),
              child: children[index],
            );
          },
        );
      },
    );
  }
}
