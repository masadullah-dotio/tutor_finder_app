import 'package:flutter/material.dart';

enum BookingTimeSlot {
  slot_08_10,
  slot_10_12,
  slot_12_14,
  slot_14_16,
  slot_16_18,
  slot_18_20,
  slot_20_22;

  String toDisplayName() {
    switch (this) {
      case BookingTimeSlot.slot_08_10:
        return '08:00 AM - 10:00 AM';
      case BookingTimeSlot.slot_10_12:
        return '10:00 AM - 12:00 PM';
      case BookingTimeSlot.slot_12_14:
        return '12:00 PM - 02:00 PM';
      case BookingTimeSlot.slot_14_16:
        return '02:00 PM - 04:00 PM';
      case BookingTimeSlot.slot_16_18:
        return '04:00 PM - 06:00 PM';
      case BookingTimeSlot.slot_18_20:
        return '06:00 PM - 08:00 PM';
      case BookingTimeSlot.slot_20_22:
        return '08:00 PM - 10:00 PM';
    }
  }

  /// Returns the start time of the slot relative to the day.
  TimeOfDay get startTime {
    switch (this) {
      case BookingTimeSlot.slot_08_10:
        return const TimeOfDay(hour: 8, minute: 0);
      case BookingTimeSlot.slot_10_12:
        return const TimeOfDay(hour: 10, minute: 0);
      case BookingTimeSlot.slot_12_14:
        return const TimeOfDay(hour: 12, minute: 0);
      case BookingTimeSlot.slot_14_16:
        return const TimeOfDay(hour: 14, minute: 0);
      case BookingTimeSlot.slot_16_18:
        return const TimeOfDay(hour: 16, minute: 0);
      case BookingTimeSlot.slot_18_20:
        return const TimeOfDay(hour: 18, minute: 0);
      case BookingTimeSlot.slot_20_22:
        return const TimeOfDay(hour: 20, minute: 0);
    }
  }

  /// All slots are currently fixed at 120 minutes (2 hours).
  Duration get duration => const Duration(hours: 2);
}
