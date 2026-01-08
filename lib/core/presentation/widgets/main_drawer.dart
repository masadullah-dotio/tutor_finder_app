import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:tutor_finder_app/core/utils/image_helper.dart';

class DrawerItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class MainDrawer extends StatelessWidget {
  final List<DrawerItem>? menuItems;
  final Function(int)? onItemSelected;
  
  const MainDrawer({super.key, this.menuItems, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default items if none provided
    final items = menuItems ?? [
      DrawerItem(icon: Icons.dashboard, title: 'Dashboard', onTap: () => onItemSelected?.call(0)),
      DrawerItem(icon: Icons.person, title: 'Profile', onTap: () => onItemSelected?.call(1)),
      DrawerItem(icon: Icons.settings, title: 'Settings', onTap: () => onItemSelected?.call(2)),
    ];

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header
          FutureBuilder<UserModel?>(
            future: AuthService().getCurrentUser(), // Fetch full user model
            builder: (context, snapshot) {
              final userModel = snapshot.data;
              final displayName = userModel != null 
                  ? '${userModel.firstName} ${userModel.lastName}' 
                  : (user?.displayName ?? 'User');
              
              return InkWell(
                onTap: () {
                  // Find and trigger the Profile menu item if it exists
                  final profileItem = items.firstWhere(
                    (item) => item.title == 'My Profile' || item.title == 'Profile', 
                    orElse: () => DrawerItem(icon: Icons.error, title: '', onTap: () {}),
                  );
                  
                  if (profileItem.title.isNotEmpty) {
                    profileItem.onTap();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 16), // Adjust top padding for status bar
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: ImageHelper.getUserImageProvider(userModel?.profileImageUrl),
                        child: userModel?.profileImageUrl == null
                            ? Text(
                                userModel?.firstName != null && userModel!.firstName.isNotEmpty
                                    ? userModel.firstName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      
                      // Name & Verification
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 18, // Slightly larger for name
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                           if ((user?.emailVerified ?? false) && (userModel?.isMobilePhoneVerified ?? false))
                            const Tooltip(
                              message: 'Verified User',
                              child: Icon(Icons.verified, size: 18, color: Colors.blue),
                            )
                          else
                            Tooltip(
                              message: 'Not Verified\n'
                                       'Email: ${(user?.emailVerified ?? false) ? "Verified" : "Pending"}\n'
                                       'Phone: ${(userModel?.isMobilePhoneVerified ?? false) ? "Verified" : "Pending"}',
                              child: const Icon(Icons.verified_outlined, size: 18, color: Colors.grey),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Username
                      if (userModel?.username != null)
                        Row(
                          children: [
                            Icon(
                              Icons.alternate_email, 
                              size: 14, 
                              color: Theme.of(context).primaryColor
                            ),
                            const SizedBox(width: 2),
                            Text(
                              userModel!.username,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 4),
                      
                      // Email
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
          
          // Body
          // Dynamic Body
          ...items.map((item) => ListTile(
            leading: Icon(item.icon),
            title: Text(item.title),
            onTap: item.onTap,
          )),
          
          const Spacer(),
          const Divider(),
          
          // Footer / Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Sign Out', 
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SignUpPage()),
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
