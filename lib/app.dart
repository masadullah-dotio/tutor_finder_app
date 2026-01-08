import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/theme/app_theme.dart';
import 'package:tutor_finder_app/core/theme/app_theme.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/core/theme/theme_provider.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/intro/presentation/pages/splash_screen.dart';
import 'package:tutor_finder_app/features/intro/presentation/pages/onboarding_screen.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:tutor_finder_app/features/auth/presentation/pages/sign_in_page.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_dashboard.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_dashboard.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_details_page.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:tutor_finder_app/features/chat/presentation/pages/chat_screen.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_search_page.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/location_permission_page.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_profile_page.dart';
import 'package:tutor_finder_app/features/student/presentation/pages/student_settings_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_profile_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/tutor_settings_page.dart';
import 'package:tutor_finder_app/features/booking/presentation/pages/booking_page.dart';
import 'package:tutor_finder_app/features/booking/presentation/pages/booking_success_page.dart';
import 'package:tutor_finder_app/features/review/presentation/pages/write_review_page.dart';
import 'package:tutor_finder_app/features/tutor/presentation/pages/subject_tutors_page.dart';
import 'package:tutor_finder_app/features/notifications/presentation/pages/notifications_page.dart';

class TutorFinderApp extends StatelessWidget {
  const TutorFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tutor Finder',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case AppRoutes.splash:
                  return MaterialPageRoute(builder: (_) => const SplashScreen());
                case AppRoutes.onboarding:
                  return MaterialPageRoute(builder: (_) => const OnboardingScreen());
                case AppRoutes.signUp:
                  return MaterialPageRoute(builder: (_) => const SignUpPage());
                case AppRoutes.signIn:
                  return MaterialPageRoute(builder: (_) => const SignInPage());
                case AppRoutes.studentDashboard:
                  return MaterialPageRoute(builder: (_) => const StudentDashboard());
                case AppRoutes.tutorDashboard:
                  return MaterialPageRoute(builder: (_) => const TutorDashboard());
                case AppRoutes.tutorDetails:
                  final args = settings.arguments;
                  UserModel tutor;
                  double? distanceKm;

                  if (args is UserModel) {
                    tutor = args;
                  } else if (args is Map<String, dynamic>) {
                    tutor = args['tutor'] as UserModel;
                    distanceKm = args['distanceKm'] as double?;
                  } else {
                    return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Invalid arguments'))));
                  }

                  return MaterialPageRoute(
                    builder: (_) => TutorDetailsPage(
                      tutor: tutor,
                      distanceKm: distanceKm,
                    ),
                  );
                case AppRoutes.chatList:
                  return MaterialPageRoute(builder: (_) => const ChatListScreen());
                case AppRoutes.chatScreen:
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      roomId: args['roomId'],
                      otherUser: args['otherUser'],
                    ),
                  );
                case AppRoutes.tutorSearch:
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (_) => TutorSearchPage(
                      initialSubject: args?['initialSubject'],
                    ),
                  );
                case AppRoutes.locationPermission:
                  return MaterialPageRoute(builder: (context) => LocationPermissionPage(onPermissionGranted: () { Navigator.pop(context); }));
                case AppRoutes.studentProfile:
                  return MaterialPageRoute(builder: (_) => const StudentProfilePage());
                case AppRoutes.studentSettings:
                  return MaterialPageRoute(builder: (_) => const StudentSettingsPage());
                case AppRoutes.tutorProfile:
                  return MaterialPageRoute(builder: (_) => const TutorProfilePage());
                case AppRoutes.tutorSettings:
                  return MaterialPageRoute(builder: (_) => const TutorSettingsPage());
                case AppRoutes.subjectTutors:
                  final subject = settings.arguments as String;
                  return MaterialPageRoute(builder: (_) => SubjectTutorsPage(subject: subject));
                case AppRoutes.bookingPage:
                   final tutor = settings.arguments as UserModel;
                   return MaterialPageRoute(
                     builder: (_) => BookingPage(tutor: tutor),
                   );
                case AppRoutes.bookingSuccess:
                  return MaterialPageRoute(builder: (_) => const BookingSuccessPage());
                case AppRoutes.writeReview:
                   final tutor = settings.arguments as UserModel;
                   return MaterialPageRoute(
                     builder: (_) => WriteReviewPage(tutor: tutor),
                   );
                case AppRoutes.notifications:
                  return MaterialPageRoute(builder: (_) => const NotificationsPage());
                default:
                  return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))));
              }
            },
            builder: (context, child) {
              return SafeArea(
                 child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
