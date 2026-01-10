import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutor_finder_app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/firebase_options.dart';
import 'package:tutor_finder_app/core/services/notification_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Parallelize critical initialization tasks
  try {
    await Future.wait([
      dotenv.load(fileName: ".env"),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);
  } catch (e) {
    debugPrint("Initialization Failed: $e");
    // Continue anyway to show the app (which might show error UI)
    // On Web, sometimes .env is cached or 404s in some hosting setups.
  }

  usePathUrlStrategy();

  if (kIsWeb) {
    // Non-blocking persistence setting
    FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Initialize Stripe (Non-blocking if possible, but fast enough to await usually)
  // We await it to ensure keys are set before any UI builds that might need them.
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? ''; 
  await Stripe.instance.applySettings();
  
  // Defer Notification Initialization to run after the app starts
  // This avoids blocking startup with permission dialogs
  // We don't await this.
  NotificationService().initialize();

  runApp(const TutorFinderApp());
}
