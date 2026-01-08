import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tutor_finder_app/app.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/firebase_options.dart';
import 'package:tutor_finder_app/core/services/notification_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  // Initialize Notifications
  await NotificationService().initialize();

  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_placeholder'; // Replace with your actual publishable key
  await Stripe.instance.applySettings();
  
  runApp(const TutorFinderApp());
}
