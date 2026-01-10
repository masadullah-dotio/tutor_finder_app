import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String tutorId;
  final String studentId;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final double totalPrice;
  final DateTime timestamp;
  
  // New fields for Home Tuition
  final String bookingType; // 'online' or 'home'
  final String bookingTimeSlot; // e.g. 'slot_08_10'
  final String? address; // Required for home tuition
  final double? locationLat;
  final double? locationLng;
  final String paymentStatus; // 'pending', 'paid', 'refunded'
  final String? paymentId;

  BookingModel({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    required this.timestamp,
    this.bookingType = 'home',
    this.bookingTimeSlot = '',
    this.address,
    this.locationLat,
    this.locationLng,
    this.paymentStatus = 'pending',
    this.paymentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorId': tutorId,
      'studentId': studentId,
      'subject': subject,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status,
      'totalPrice': totalPrice,
      'timestamp': Timestamp.fromDate(timestamp),
      'bookingType': bookingType,
      'bookingTimeSlot': bookingTimeSlot,
      if (address != null) 'address': address,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
      'paymentStatus': paymentStatus,
      if (paymentId != null) 'paymentId': paymentId,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      tutorId: map['tutorId'] ?? '',
      studentId: map['studentId'] ?? '',
      subject: map['subject'] ?? '',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      totalPrice: (map['totalPrice'] ?? 0.0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      bookingType: map['bookingType'] ?? 'online',
      bookingTimeSlot: map['bookingTimeSlot'] ?? '',
      address: map['address'],
      locationLat: map['locationLat'],
      locationLng: map['locationLng'],
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentId: map['paymentId'],
    );
  }
}
