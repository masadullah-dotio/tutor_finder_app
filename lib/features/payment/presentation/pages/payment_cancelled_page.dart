import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';

class PaymentCancelledPage extends StatefulWidget {
  final String? bookingId;

  const PaymentCancelledPage({
    super.key,
    this.bookingId,
  });

  @override
  State<PaymentCancelledPage> createState() => _PaymentCancelledPageState();
}

class _PaymentCancelledPageState extends State<PaymentCancelledPage> {
  @override
  void initState() {
    super.initState();
    _cleanupPendingBooking();
  }

  Future<void> _cleanupPendingBooking() async {
    // Delete the pending booking if it exists
    if (widget.bookingId != null && widget.bookingId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(widget.bookingId)
            .delete();
      } catch (e) {
        debugPrint('Error cleaning up pending booking: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.orange,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Cancelled',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your payment was cancelled. No charges were made. You can try booking again whenever you\'re ready.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.studentDashboard,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
