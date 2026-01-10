import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/features/booking/data/repositories/booking_repository.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/booking/presentation/widgets/booking_card.dart';

class StudentSchedulePage extends StatefulWidget {
  const StudentSchedulePage({super.key});

  @override
  State<StudentSchedulePage> createState() => _StudentSchedulePageState();
}

class _StudentSchedulePageState extends State<StudentSchedulePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    // Assuming we have access to current user ID reliably.
    // If authService.getCurrentUser has been called, we can get ID.
    // Or we use FirebaseAuth directly for ID if needed.
    // Ideally AuthService exposes 'user' or 'userId'.
    // Let's use a FutureBuilder to get the user ID first if needed or assume it's available.
    // For now, let's assume valid session if we are in dashboard.

    return VerificationGuard(
      featureName: 'Schedules',
      child: FutureBuilder(
        future: authService.getCurrentUser(), // Ensure we have the user
        builder: (context, userSnapshot) {
           if (userSnapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
           }
           if (!userSnapshot.hasData) {
             return const Center(child: Text('User not found'));
           }

           final userId = userSnapshot.data!.uid;

           return Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
              Expanded(
                child: StreamBuilder<List<BookingModel>>(
                  stream: Provider.of<BookingRepository>(context, listen: false).getBookingsForStudent(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final bookings = snapshot.data ?? [];
                    final now = DateTime.now();

                    // Filter Bookings locally for now
                    // Pending: status is 'pending' or 'pending_payment'
                    final pendingBookings = bookings.where((b) => 
                      b.status == 'pending' || b.status == 'pending_payment'
                    ).toList();

                    // Upcoming: Confirmed AND StartTime is after Now
                    final upcomingBookings = bookings.where((b) => 
                      b.status == 'confirmed' && b.startTime.isAfter(now)
                    ).toList();

                    // Past: (Confirmed AND StartTime before Now) OR Completed OR Cancelled
                    // Usually 'Past' implies completed sessions.
                    // Let's include Cancelled here too or maybe just separate?
                    // User asked for "passed", so likely time-based.
                    final pastBookings = bookings.where((b) => 
                      (b.status == 'confirmed' && b.startTime.isBefore(now)) || 
                      b.status == 'completed' || 
                      b.status == 'cancelled'
                    ).toList();
                    
                    // Sort by date 
                    pendingBookings.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Newest first
                    upcomingBookings.sort((a, b) => a.startTime.compareTo(b.startTime)); // Soonest first
                    pastBookings.sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent past first

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingList(pendingBookings, 'No pending bookings'),
                        _buildBookingList(upcomingBookings, 'No upcoming sessions'),
                        _buildBookingList(pastBookings, 'No past sessions'),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return BookingCard(booking: bookings[index]);
      },
    );
  }
}
