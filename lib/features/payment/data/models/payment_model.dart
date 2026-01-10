import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String bookingId;
  final String studentId;
  final String tutorId;
  final double amount;
  final String currency;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String paymentMethod; // 'stripe'
  final String transactionId; // Stripe Payment Intent ID
  final DateTime timestamp;

  PaymentModel({
    required this.id,
    required this.bookingId,
    required this.studentId,
    required this.tutorId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    required this.transactionId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'studentId': studentId,
      'tutorId': tutorId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      bookingId: map['bookingId'] ?? '',
      studentId: map['studentId'] ?? '',
      tutorId: map['tutorId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'usd',
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'stripe',
      transactionId: map['transactionId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
