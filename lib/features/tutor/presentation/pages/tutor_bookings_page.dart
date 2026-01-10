import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/booking/data/repositories/booking_repository.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/presentation/widgets/verification_guard.dart';
import 'package:tutor_finder_app/features/booking/presentation/widgets/booking_card.dart';

class TutorBookingsPage extends StatefulWidget {
  const TutorBookingsPage({super.key});

  @override
  State<TutorBookingsPage> createState() => _TutorBookingsPageState();
}

class _TutorBookingsPageState extends State<TutorBookingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text('Please sign in to view bookings.'));
    }

    // Access Repositories via Provider
    final bookingRepository = Provider.of<BookingRepository>(context, listen: false);

    return VerificationGuard(
      featureName: 'My Bookings',
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<BookingModel>>(
              stream: bookingRepository.getBookingsForTutor(_currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allBookings = snapshot.data ?? [];
                final now = DateTime.now();
                
                final upcomingBookings = allBookings
                    .where((b) => b.startTime.isAfter(now) && b.status != 'cancelled')
                    .toList()
                  ..sort((a, b) => a.startTime.compareTo(b.startTime));
                
                final pastBookings = allBookings
                    .where((b) => b.startTime.isBefore(now) || b.status == 'cancelled')
                    .toList()
                  ..sort((a, b) => b.startTime.compareTo(a.startTime));

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(upcomingBookings, 'No upcoming bookings'),
                    _buildBookingList(pastBookings, 'No past bookings'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        // Pass studentId as otherPartyId so the card displays the Student's name
        return BookingCard(
          booking: booking,
          otherPartyId: booking.studentId, 
          onTap: () {
            // Handle tap if needed, e.g., go to details
          },
        );
      },
    );
  }
}
