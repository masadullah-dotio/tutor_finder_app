import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';

class VerificationGuard extends StatelessWidget {
  final Widget child;
  final String featureName;

  const VerificationGuard({
    super.key,
    required this.child,
    this.featureName = 'this feature',
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // We use a FutureBuilder or StreamBuilder usually, but AuthService usually caches the user.
    // Assuming authService.getCurrentUser() or similar is available synchronously or via provider state if refactored.
    // Since AuthService extends ChangeNotifier, we can access its state if we added a user field there. 
    // For now, let's fetch the current user from the provider if it exposes it, or use the firebase user directly for speed
    // coupled with the cached model.
    
    // Better approach: Use FutureBuilder to check the latest status if not readily available in a variable.
    // However, for a Guard, we want it instant. 
    // Let's assume AuthService has a 'currentUserModel' getter or similar if we implemented it, 
    // OR we rely on the fact that we should have fetched it on app start.
    
    return FutureBuilder<UserModel?>(
      future: authService.getCurrentUser(), // This might be cached now given our previous optimization
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        final bool emailVerified = user.isEmailVerified;
        final bool phoneVerified = user.isMobilePhoneVerified;

        if (emailVerified && phoneVerified) {
          return child;
        }

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_person_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  'Verification Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  'To access $featureName, you must verify your account.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                if (!emailVerified)
                  _VerificationStep(
                    title: 'Email Verification',
                    isVerified: false,
                    onTap: () {
                     // Navigate to settings or trigger functionality
                     Navigator.pushNamed(context, AppRoutes.studentSettings);
                    },
                    buttonText: 'Verify Email',
                  ),
                if (!emailVerified && !phoneVerified) const SizedBox(height: 16),
                if (!phoneVerified)
                  _VerificationStep(
                    title: 'Phone Verification',
                    isVerified: false,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.studentSettings);
                    },
                     buttonText: 'Verify Phone',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VerificationStep extends StatelessWidget {
  final String title;
  final bool isVerified;
  final VoidCallback onTap;
  final String buttonText;

  const _VerificationStep({
    required this.title,
    required this.isVerified,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.error_outline,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (!isVerified)
            TextButton(
              onPressed: onTap,
              child: Text(buttonText),
            ),
        ],
      ),
    );
  }
}
