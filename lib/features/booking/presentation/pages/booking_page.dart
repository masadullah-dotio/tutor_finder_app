import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:tutor_finder_app/core/theme/app_colors.dart';
import 'package:tutor_finder_app/features/auth/data/models/user_model.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_model.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_type.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_time_slot.dart';
import 'package:tutor_finder_app/features/booking/data/services/booking_service.dart';
import 'package:tutor_finder_app/core/routes/app_routes.dart';
import 'package:tutor_finder_app/features/payment/services/payment_service.dart';
import 'package:tutor_finder_app/features/booking/presentation/widgets/animated_booking_mode_selector.dart';
import 'package:tutor_finder_app/features/booking/presentation/widgets/animated_time_slot_grid.dart';

class BookingPage extends StatefulWidget {
  final UserModel tutor;

  const BookingPage({super.key, required this.tutor});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final BookingService _bookingService = BookingService();
  final _addressController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  BookingType _bookingType = BookingType.online;
  BookingTimeSlot? _selectedTimeSlot;
  String? _selectedSubject;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutor.subjects != null && widget.tutor.subjects!.isNotEmpty) {
      _selectedSubject = widget.tutor.subjects!.first;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).scaffoldBackgroundColor,
              onSurface: Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }
    
    // Validate Address for Home Tuition
    if (_bookingType == BookingType.home && _addressController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your home address')),
      );
      return;
    }

    if (_selectedSubject == null && (widget.tutor.subjects?.isNotEmpty ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate Total Price
      double totalPrice = widget.tutor.hourlyRate ?? 0.0;
      // Multiply by 2 hours (fixed duration)
      totalPrice *= 2; 
      
      // Add differential if applicable
      if (_bookingType == BookingType.home && widget.tutor.homeRateDifferential != null) {
        totalPrice += widget.tutor.homeRateDifferential!;
      }

      // 1. Process Payment (Skipping for now if 0, else integrate Stripe)
      if (totalPrice > 0) {
        final paymentService = PaymentService();
        await paymentService.initPaymentSheet(
          amount: totalPrice,
          currency: 'usd', 
        );
        await paymentService.presentPaymentSheet();
      }

      // 2. Create Booking
      final currentUser = FirebaseAuth.instance.currentUser!;
      final bookingId = const Uuid().v4();
      
      final slotTime = _selectedTimeSlot!.startTime;
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        slotTime.hour,
        slotTime.minute,
      );
      final endTime = startTime.add(_selectedTimeSlot!.duration);

      final booking = BookingModel(
        id: bookingId,
        tutorId: widget.tutor.uid,
        studentId: currentUser.uid,
        subject: _selectedSubject ?? 'General',
        startTime: startTime,
        endTime: endTime,
        status: 'pending',
        totalPrice: totalPrice,
        timestamp: DateTime.now(),
        bookingType: _bookingType.name, // 'online' or 'home'
        bookingTimeSlot: _selectedTimeSlot!.name,
        address: _bookingType == BookingType.home ? _addressController.text.trim() : null,
      );

      final result = await _bookingService.createBooking(booking);

      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        ),
        (_) => Navigator.pushReplacementNamed(context, AppRoutes.bookingSuccess),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutor Info (Card with Hero if possible, but keep simple for now)
            Row(
              children: [
                Hero(
                  tag: 'tutor_avatar_${widget.tutor.uid}',
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      widget.tutor.firstName[0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.tutor.firstName} ${widget.tutor.lastName}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (widget.tutor.hourlyRate != null)
                      Text(
                        '\$${widget.tutor.hourlyRate}/hr',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // Subject Selection
            if (widget.tutor.subjects != null && widget.tutor.subjects!.isNotEmpty) ...[
               const Text('Select Subject', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               const SizedBox(height: 12),
               Wrap(
                 spacing: 8,
                 children: widget.tutor.subjects!.map((subject) {
                   final isSelected = _selectedSubject == subject;
                   return ChoiceChip(
                     label: Text(subject),
                     selected: isSelected,
                     onSelected: (selected) {
                       setState(() {
                         _selectedSubject = selected ? subject : null;
                       });
                     },
                     selectedColor: AppColors.primary,
                     labelStyle: TextStyle(
                       color: isSelected ? Colors.white : Colors.black87,
                     ),
                   );
                 }).toList(),
               ),
               const SizedBox(height: 24),
            ],

            // Booking Mode (Home/Online)
            const Text('Session Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AnimatedBookingModeSelector(
              selectedMode: _bookingType,
              onModeChanged: (mode) {
                setState(() {
                  _bookingType = mode;
                });
              },
            ),
            
            // Address Field (Animated Appearance)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: SizedBox(
                height: _bookingType == BookingType.home ? null : 0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Home Address',
                      hintText: 'Enter full address for tutor',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Date Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    DateFormat('MMM d, y').format(_selectedDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 14, // Next 2 weeks
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = date.year == _selectedDate.year && 
                      date.month == _selectedDate.month && 
                      date.day == _selectedDate.day;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                         _selectedDate = date;
                         _selectedTimeSlot = null;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? [
                          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                        ] : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Time Slots
            const Text('Available Slots (2 Hours)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AnimatedTimeSlotGrid(
              selectedSlot: _selectedTimeSlot,
              onSlotSelected: (slot) {
                setState(() {
                  _selectedTimeSlot = slot;
                });
              },
            ),

            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
