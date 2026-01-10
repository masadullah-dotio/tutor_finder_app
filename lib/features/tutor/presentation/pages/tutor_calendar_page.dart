import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/presentation/widgets/custom_calendar.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/booking/data/repositories/booking_repository.dart';
import 'package:intl/intl.dart';

class TutorCalendarPage extends StatefulWidget {
  const TutorCalendarPage({super.key});

  @override
  State<TutorCalendarPage> createState() => _TutorCalendarPageState();
}

class _TutorCalendarPageState extends State<TutorCalendarPage> {
  final BookingRepository _bookingRepository = BookingRepository();
  final AuthService _authService = AuthService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  
  DateTime _selectedDay = DateTime.now();
  
  Map<DateTime, List<BookingModel>> _events = {};
  List<BookingModel> _selectedDayBookings = [];

  List<BookingModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _selectedDayBookings = _getEventsForDay(selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text('Please sign in to view calendar.'));
    }

    return StreamBuilder<List<BookingModel>>(
      stream: _bookingRepository.getBookingsForTutor(_currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        Set<DateTime> markedDates = {};
        
        if (snapshot.hasData) {
          // Group bookings by date
          _events = {};
          for (var booking in snapshot.data!) {
            if (booking.status == 'cancelled') continue;
            final day = DateTime(booking.startTime.year, booking.startTime.month, booking.startTime.day);
            _events[day] = (_events[day] ?? [])..add(booking);
            markedDates.add(day);
          }
          _selectedDayBookings = _getEventsForDay(_selectedDay);
        }

        return Column(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomCalendar(
                  initialDate: _selectedDay,
                  markedDates: markedDates,
                  onDaySelected: _onDaySelected,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.event, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Sessions on ${DateFormat.yMMMd().format(_selectedDay)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _selectedDayBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          const Text(
                            'No sessions scheduled',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _selectedDayBookings.length,
                      itemBuilder: (context, index) {
                        final booking = _selectedDayBookings[index];
                        return _buildSessionCard(booking);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSessionCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        title: FutureBuilder(
          future: _authService.getUserById(booking.studentId),
          builder: (context, snapshot) {
            final name = snapshot.data != null 
                ? '${snapshot.data!.firstName ?? ''} ${snapshot.data!.lastName ?? ''}'.trim()
                : 'Student';
            return Text(name, style: const TextStyle(fontWeight: FontWeight.bold));
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.subject),
            Text(
              '${DateFormat.jm().format(booking.startTime)} - ${DateFormat.jm().format(booking.endTime)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '\$${booking.totalPrice.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}
