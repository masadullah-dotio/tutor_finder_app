import 'package:flutter/material.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';

class NotificationSettingsTile extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUpdate;

  const NotificationSettingsTile({
    super.key,
    required this.user,
    required this.onUpdate,
  });

  @override
  State<NotificationSettingsTile> createState() => _NotificationSettingsTileState();
}

class _NotificationSettingsTileState extends State<NotificationSettingsTile> {
  final AuthService _authService = AuthService();

  Future<void> _updatePreference(String key, bool value) async {
    UserModel updatedUser = widget.user;
    if (key == 'push') updatedUser = updatedUser.copyWith(notifyPush: value);
    if (key == 'email') updatedUser = updatedUser.copyWith(notifyEmail: value);
    if (key == 'inApp') updatedUser = updatedUser.copyWith(notifyInApp: value);

    try {
      // In a real app we'd want a dedicated update method in repo, 
      // but modifying user works if AuthService exposes update.
      // Assuming AuthService.updateUser maps to Firestore set/update:
      await _authService.updateUser(updatedUser);
      widget.onUpdate(); // callback to refresh parent
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            'Notification Preferences',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_active),
          title: const Text('Push Notifications'),
          subtitle: const Text('Mobile alerts'),
          value: widget.user.notifyPush,
          onChanged: (val) => _updatePreference('push', val),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.email),
          title: const Text('Email Notifications'),
          subtitle: const Text('Updates sent to your email'),
          value: widget.user.notifyEmail,
          onChanged: (val) => _updatePreference('email', val),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.apps),
          title: const Text('In-App Notifications'),
          subtitle: const Text('Activity feed within the app'),
          value: widget.user.notifyInApp,
          onChanged: (val) => _updatePreference('inApp', val),
        ),
      ],
    );
  }
}
