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
import 'package:tutor_finder_app/features/payment/presentation/pages/payment_success_page.dart';
import 'package:tutor_finder_app/features/payment/presentation/pages/payment_cancelled_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_tutors_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_students_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/verify_tutor_usecase.dart';
import 'package:tutor_finder_app/features/admin/presentation/pages/admin_dashboard.dart';

import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_bookings_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_reviews_usecase.dart';
import 'package:tutor_finder_app/features/admin/domain/usecases/get_all_reports_usecase.dart';
import 'package:tutor_finder_app/features/booking/data/repositories/booking_repository.dart';
import 'package:tutor_finder_app/features/review/data/repositories/review_repository.dart';
import 'package:tutor_finder_app/features/report/data/repositories/report_repository.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

class TutorFinderApp extends StatefulWidget {
  const TutorFinderApp({super.key});

  @override
  State<TutorFinderApp> createState() => _TutorFinderAppState();
}

class _TutorFinderAppState extends State<TutorFinderApp> {
  @override
  void initState() {
    super.initState();
    // Remove the splash screen once the widget tree is initialized
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => AdminRepositoryImpl(FirebaseFirestore.instance)),
        Provider(create: (_) => BookingRepository()),
        Provider(create: (_) => ReviewRepository()),
        Provider(create: (_) => ReportRepository()),
        ProxyProvider<AdminRepositoryImpl, GetAllTutorsUseCase>(
          update: (_, repo, __) => GetAllTutorsUseCase(repo),
        ),
        ProxyProvider<AdminRepositoryImpl, GetAllStudentsUseCase>(
          update: (_, repo, __) => GetAllStudentsUseCase(repo),
        ),
        ProxyProvider<AdminRepositoryImpl, VerifyTutorUseCase>(
          update: (_, repo, __) => VerifyTutorUseCase(repo),
        ),
        ProxyProvider<AdminRepositoryImpl, GetAllBookingsUseCase>(
          update: (_, repo, __) => GetAllBookingsUseCase(repo),
        ),
        ProxyProvider<AdminRepositoryImpl, GetAllReviewsUseCase>(
          update: (_, repo, __) => GetAllReviewsUseCase(repo),
        ),
        ProxyProvider<AdminRepositoryImpl, GetAllReportsUseCase>(
          update: (_, repo, __) => GetAllReportsUseCase(repo),
        ),
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
                case AppRoutes.adminDashboard:
                  return MaterialPageRoute(builder: (_) => const AdminDashboard());
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
                case AppRoutes.paymentSuccess:
                  // Extract query parameters from URL for web
                  final uri = Uri.parse(settings.name ?? '');
                  final sessionId = uri.queryParameters['session_id'] ?? 
                      (settings.arguments as Map<String, dynamic>?)?['session_id'];
                  final bookingId = uri.queryParameters['booking_id'] ?? 
                      (settings.arguments as Map<String, dynamic>?)?['booking_id'];
                  return MaterialPageRoute(
                    builder: (_) => PaymentSuccessPage(
                      sessionId: sessionId,
                      bookingId: bookingId,
                    ),
                  );
                case AppRoutes.paymentCancelled:
                  final cancelUri = Uri.parse(settings.name ?? '');
                  final cancelBookingId = cancelUri.queryParameters['booking_id'] ?? 
                      (settings.arguments as Map<String, dynamic>?)?['booking_id'];
                  return MaterialPageRoute(
                    builder: (_) => PaymentCancelledPage(
                      bookingId: cancelBookingId,
                    ),
                  );
                default:
                  // Handle web URL paths with query parameters
                  final routeName = settings.name;
                  if (routeName != null && routeName.startsWith('/payment-success')) {
                    final successUri = Uri.parse(routeName);
                    return MaterialPageRoute(
                      builder: (_) => PaymentSuccessPage(
                        sessionId: successUri.queryParameters['session_id'],
                        bookingId: successUri.queryParameters['booking_id'],
                      ),
                    );
                  }
                  if (routeName != null && routeName.startsWith('/payment-cancelled')) {
                    final cancelledUri = Uri.parse(routeName);
                    return MaterialPageRoute(
                      builder: (_) => PaymentCancelledPage(
                        bookingId: cancelledUri.queryParameters['booking_id'],
                      ),
                    );
                  }
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
