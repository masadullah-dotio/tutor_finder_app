import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/payment/data/models/payment_model.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? sessionId;
  final String? bookingId;

  const PaymentSuccessPage({
    super.key,
    this.sessionId,
    this.bookingId,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _isProcessing = true;
  bool _isSuccess = false;
  String _message = 'Processing your payment...';

  @override
  void initState() {
    super.initState();
    _confirmBooking();
  }

  Future<void> _confirmBooking() async {
    try {
      final bookingId = widget.bookingId;
      
      if (bookingId == null || bookingId.isEmpty) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = 'Invalid booking reference. Please contact support.';
        });
        return;
      }

      final firestore = FirebaseFirestore.instance;
      
      // Get the pending booking
      final bookingDoc = await firestore.collection('bookings').doc(bookingId).get();
      
      if (!bookingDoc.exists) {
        setState(() {
          _isProcessing = false;
          _isSuccess = false;
          _message = 'Booking not found. Please contact support.';
        });
        return;
      }

      final bookingData = bookingDoc.data()!;
      
      // Update booking status to confirmed
      await firestore.collection('bookings').doc(bookingId).update({
        'status': 'confirmed',
        'paymentStatus': 'paid',
      });

      // Create payment record
      final payment = PaymentModel(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
        bookingId: bookingId,
        studentId: bookingData['studentId'] ?? '',
        tutorId: bookingData['tutorId'] ?? '',
        amount: (bookingData['totalPrice'] ?? 0.0).toDouble(),
        currency: 'usd',
        status: 'completed',
        paymentMethod: 'stripe',
        transactionId: widget.sessionId ?? '',
        timestamp: DateTime.now(),
      );

      await firestore.collection('payments').doc(payment.id).set(payment.toMap());

      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _message = 'Payment successful! Your session has been booked.';
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isSuccess = false;
        _message = 'An error occurred: ${e.toString()}';
      });
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
              if (_isProcessing)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: _isSuccess ? Colors.green : Colors.red,
                  size: 100,
                ),
              const SizedBox(height: 24),
              Text(
                _isSuccess ? 'Payment Successful!' : 'Payment Issue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              if (!_isProcessing)
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
                    child: const Text('Go to Dashboard'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
