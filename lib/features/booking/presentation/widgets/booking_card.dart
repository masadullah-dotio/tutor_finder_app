import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/core/utils/time_helper.dart';
import 'package:tutor_finder_app/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;
  final String? otherPartyId; // ID of the other user (Tutor for Student, Student for Tutor)

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.otherPartyId,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'pending_payment':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed': 
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);
    final isUpcoming = booking.startTime.isAfter(DateTime.now());
    final authService = Provider.of<AuthService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '\$${booking.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Name Display
              if (otherPartyId != null)
                FutureBuilder(
                  future: authService.getUserById(otherPartyId!),
                  builder: (context, snapshot) {
                     if (snapshot.hasData && snapshot.data != null) {
                       final user = snapshot.data!;
                       return Padding(
                         padding: const EdgeInsets.only(bottom: 4.0),
                         child: Text(
                           '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                         ),
                       );
                     }
                     return const SizedBox.shrink(); 
                  },
                ),
              Text(
                booking.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500, // Slightly less bold if name is present? kept bold but name is separated
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM d, y').format(booking.startTime),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                   Icon(
                    booking.bookingType == 'online' ? Icons.laptop_chromebook : Icons.home,
                    size: 16, 
                    color: Colors.grey
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.bookingType == 'online' ? 'Online Session' : (booking.address ?? 'Home Tuition'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   Text(
                    isUpcoming 
                      ? TimeHelper.timeUntil(booking.startTime) 
                      : TimeHelper.timeAgo(booking.startTime), // or endTime?
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontStyle: FontStyle.italic
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
