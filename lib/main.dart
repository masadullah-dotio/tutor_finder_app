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
  // 1. Initialize Bindings
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Splash Screen (Skip preserve on Web to prevent stuck issues)
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  // 3. Critical Initialization
  try {
    debugPrint("Starting critical initialization...");
    await Future.wait([
      // Use logical default if .env fails
      dotenv.load(fileName: ".env").catchError((e) {
         debugPrint("DotEnv not found, using empty environment");
         return null;
      }),
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    ]);
    debugPrint("Critical initialization complete.");
  } catch (e) {
    debugPrint("CRITICAL INIT ERROR: $e");
    // Continue to show app anyway
  }

  // 4. Web Strategy
  usePathUrlStrategy();

  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch(e) {
      debugPrint("Auth Persistence Error: $e");
    }
  }

  // 5. Stripe (Non-blocking)
  // We set the key immediately, but let the heavy lifting happen in background.
  // This prevents the app from waiting on Stripe before showing UI.
  try {
    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? ''; 
    Stripe.instance.applySettings().catchError((e) {
      debugPrint("Stripe Init Error: $e");
    });
  } catch (e) {
    debugPrint("Stripe Setup Error: $e");
  }
  
  // 6. Notifications (Fire and forget, but safe)
  try {
    NotificationService().initialize().catchError((e) {
      debugPrint("Notification Init Error: $e");
    });
  } catch (e) {
    debugPrint("Notification Setup Error: $e");
  }

  // 7. Run App
  debugPrint("Calling runApp...");
  runApp(const TutorFinderApp());
  
  // Force clean up splash just in case runApp hangs
  if (kIsWeb) {
    Future.delayed(const Duration(milliseconds: 500), () {
        FlutterNativeSplash.remove(); 
    });
  }
}
