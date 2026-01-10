import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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

import 'package:tutor_finder_app/features/booking/presentation/widgets/animated_time_slot_grid.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tutor_finder_app/features/payment/data/models/payment_model.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';


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
  BookingType _bookingType = BookingType.home; // Default to Home since Online is disabled
  List<String> _selectedSubjects = [];
  
  Set<BookingTimeSlot> _selectedSlots = {};
  Set<BookingTimeSlot> _bookedSlots = {};
  
  bool _isLoading = false;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    if (widget.tutor.subjects != null && widget.tutor.subjects!.isNotEmpty) {
      _selectedSubjects.add(widget.tutor.subjects!.first);
    }
    _updateBookedSlots();
    // Auto-fill address since default is Home Tuition
    _getCurrentLocationAndAddress();
  }
  
  // Fetch actual booked slots (no dummy data)
  void _updateBookedSlots() {
    setState(() {
      _bookedSlots.clear();
      // TODO: Fetch actual booked slots from BookingService for this tutor and date
      // For now, all slots are available
    });
  }

  Future<void> _getCurrentLocationAndAddress() async {
    setState(() => _isLoadingAddress = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      
      // Use OpenStreetMap Nominatim for reverse geocoding (free, no API key needed)
      try {
        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1'
          ),
          headers: {
            'User-Agent': 'TutorFinderApp/1.0', // Required by Nominatim
          },
        );
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final displayName = data['display_name'] as String?;
          
          if (displayName != null && displayName.isNotEmpty && mounted) {
            setState(() {
              _addressController.text = displayName;
            });
          }
        } else {
          throw Exception('Nominatim returned ${response.statusCode}');
        }
      } catch (geocodeError) {
        debugPrint('Geocoding failed: $geocodeError');
        // Fallback to local geocoding package
        try {
          final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
          if (placemarks.isNotEmpty && mounted) {
            final place = placemarks.first;
            final parts = [
              place.street, place.subLocality, place.locality,
              place.administrativeArea, place.postalCode, place.country
            ].where((s) => s != null && s.isNotEmpty).toList();
            setState(() {
              _addressController.text = parts.join(', ');
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _addressController.text = 'Near ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
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
        _selectedSlots.clear(); // Reset selection
        _updateBookedSlots(); // Update availability
      });
    }
  }

  void _showOnlineComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.rocket_launch_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text(
                'Coming Soon!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Online sessions effectively with a whiteboard and screen sharing are currently under development. Stay tuned for the next big update!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Okay, Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one time slot')),
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

    if (_selectedSubjects.isEmpty && (widget.tutor.subjects?.isNotEmpty ?? false)) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one subject')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate Total Price
      double hourlyRate = widget.tutor.hourlyRate ?? 0.0;
      double slotPrice = hourlyRate * 2; // 2 hours per slot
      double totalPrice = slotPrice * _selectedSlots.length; 
      
      // Add differential if applicable
      if (_bookingType == BookingType.home && widget.tutor.homeRateDifferential != null) {
        totalPrice += widget.tutor.homeRateDifferential!;
      }

      String? paymentId;
      String paymentStatus = 'pending';
      String transactionId = '';

      // 1. Process Payment
      if (totalPrice > 0) {
        final paymentService = PaymentService();
        
        // Web: Use Stripe Checkout redirect
        if (kIsWeb) {
          try {
            // For web, we need to create a pending booking BEFORE redirecting
            // so we can confirm it when user returns from Stripe
            final currentUser = FirebaseAuth.instance.currentUser!;
            final bookingId = const Uuid().v4();
            
            final slotNames = _selectedSlots.map((s) => s.name).join(',');
            final sortedSlots = _selectedSlots.toList()..sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));
            final firstSlot = sortedSlots.first;
            final lastSlot = sortedSlots.last;

            final startTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              firstSlot.startTime.hour,
              firstSlot.startTime.minute,
            );
            
            final endTime = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              lastSlot.startTime.hour,
              lastSlot.startTime.minute,
            ).add(lastSlot.duration);

            // Create pending booking
            final pendingBooking = BookingModel(
              id: bookingId,
              tutorId: widget.tutor.uid,
              studentId: currentUser.uid,
              subject: _selectedSubjects.join(', '),
              startTime: startTime,
              endTime: endTime,
              status: 'pending_payment', // Will be confirmed after payment
              totalPrice: totalPrice,
              timestamp: DateTime.now(),
              bookingType: _bookingType.name,
              bookingTimeSlot: slotNames,
              address: _bookingType == BookingType.home ? _addressController.text.trim() : null,
              paymentStatus: 'pending',
            );

            await _bookingService.createBooking(pendingBooking);
            
            // Now redirect to Stripe Checkout with booking ID
            await paymentService.launchStripeCheckout(
              amount: totalPrice,
              currency: 'usd',
              bookingId: bookingId,
            );
            
            // Note: User will be redirected and won't see this message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Redirecting to payment...')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment error: ${e.toString()}')),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
        
        // Mobile: Use native Payment Sheet
        final clientSecret = await paymentService.initPaymentSheet(
          amount: totalPrice,
          currency: 'usd', 
        );
        
        await paymentService.presentPaymentSheet();

        // If we reached here, payment was successful
        transactionId = clientSecret.split('_secret_')[0];
        paymentStatus = 'paid';
        
        // Create Payment Record
        paymentId = const Uuid().v4();
        final currentUser = FirebaseAuth.instance.currentUser!;
        final bookingId = const Uuid().v4(); // Generate booking ID early for link

        final payment = PaymentModel(
          id: paymentId,
          bookingId: bookingId,
          studentId: currentUser.uid,
          tutorId: widget.tutor.uid,
          amount: totalPrice,
          currency: 'usd',
          status: 'completed',
          paymentMethod: 'stripe',
          transactionId: transactionId,
          timestamp: DateTime.now(),
        );

        await paymentService.createPaymentRecord(payment);

        // Create Booking(s) - One record per slot, or one combined? 
        // For simplicity in this demo, we'll create one Booking record that lists all slots.
        // Ideally, create separate bookings or a 'BookingSession' sub-collection.
        
        final slotNames = _selectedSlots.map((s) => s.name).join(',');
        
        // Use first slot for start time reference, but logic might need adjustment for non-contiguous slots.
        // Assuming user selects contiguous slots or we just store range.
        
        final sortedSlots = _selectedSlots.toList()..sort((a, b) => a.startTime.hour.compareTo(b.startTime.hour));
        final firstSlot = sortedSlots.first;
        final lastSlot = sortedSlots.last;

        final startTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          firstSlot.startTime.hour,
          firstSlot.startTime.minute,
        );
        
        // End time is end of the LAST slot
        final endTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          lastSlot.startTime.hour,
          lastSlot.startTime.minute,
        ).add(lastSlot.duration);

        final booking = BookingModel(
          id: bookingId,
          tutorId: widget.tutor.uid,
          studentId: currentUser.uid,
          subject: _selectedSubjects.join(', '),
          startTime: startTime,
          endTime: endTime,
          status: 'confirmed', // Confirmed because paid
          totalPrice: totalPrice,
          timestamp: DateTime.now(),
          bookingType: _bookingType.name, // 'online' or 'home'
          bookingTimeSlot: slotNames, // Comma separated list of slots
          address: _bookingType == BookingType.home ? _addressController.text.trim() : null,
          paymentStatus: paymentStatus,
          paymentId: paymentId,
        );

        final result = await _bookingService.createBooking(booking);

        result.fold(
          (error) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          ),
          (_) => Navigator.pushReplacementNamed(context, AppRoutes.bookingSuccess),
        );
      } else {
         // Handle free bookings if any
         // ... existing free booking logic or error ...
      }

    } catch (e) {
      if (e is StripeException) {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment cancelled or failed: ${e.error.localizedMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
                      widget.tutor.firstName != null && widget.tutor.firstName!.isNotEmpty 
                          ? widget.tutor.firstName![0].toUpperCase() 
                          : 'T',
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

            // Subject Selection (Checkboxes)
            if (widget.tutor.subjects != null && widget.tutor.subjects!.isNotEmpty) ...[
               const Text('Select Subjects', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               const SizedBox(height: 12),
               Column(
                 children: widget.tutor.subjects!.map((subject) {
                   final isSelected = _selectedSubjects.contains(subject);
                   return CheckboxListTile(
                     title: Text(subject),
                     value: isSelected,
                     onChanged: (bool? value) {
                       setState(() {
                         if (value == true) {
                           _selectedSubjects.add(subject);
                         } else {
                           _selectedSubjects.remove(subject);
                         }
                       });
                     },
                     activeColor: AppColors.primary,
                     contentPadding: EdgeInsets.zero,
                     dense: true,
                     controlAffinity: ListTileControlAffinity.leading,
                   );
                 }).toList(),
               ),
               const SizedBox(height: 24),
            ],

            // Booking Mode (Home/Online)
            const Text('Session Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: [
                RadioListTile<BookingType>(
                  title: const Text('Online Session'),
                  value: BookingType.online,
                  groupValue: _bookingType,
                  onChanged: (BookingType? value) {
                    _showOnlineComingSoonDialog();
                    // Do not update state to online
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                RadioListTile<BookingType>(
                  title: const Text('Home Tuition'),
                  value: BookingType.home,
                  groupValue: _bookingType,
                  onChanged: (BookingType? value) {
                    if (value != null) {
                      setState(() {
                        _bookingType = value;
                        if (value == BookingType.home && _addressController.text.isEmpty) {
                          _getCurrentLocationAndAddress();
                        }
                      });
                    }
                  },
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
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
                      fillColor: Theme.of(context).cardColor,
                      suffixIcon: _isLoadingAddress 
                        ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            icon: const Icon(Icons.my_location),
                            onPressed: _getCurrentLocationAndAddress,
                          ),
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
                itemCount: 7, // Mon to Sun
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  // Calculate Monday of current week
                  final now = DateTime.now();
                  final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
                  final monday = now.subtract(Duration(days: currentWeekday - 1));
                  final date = DateTime(monday.year, monday.month, monday.day).add(Duration(days: index));
                  final isSelected = date.year == _selectedDate.year && 
                      date.month == _selectedDate.month && 
                      date.day == _selectedDate.day;
                  
                  return GestureDetector(
                    onTap: () {
                     setState(() {
                         _selectedDate = date;
                         _selectedSlots.clear();
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Theme.of(context).cardColor,
                        border: Border.all(color: isSelected ? AppColors.primary : Theme.of(context).dividerColor),
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
              selectedSlots: _selectedSlots,
              disabledSlots: _bookedSlots,
              onSlotSelected: (slot) {
                setState(() {
                   if (_selectedSlots.contains(slot)) {
                     _selectedSlots.remove(slot);
                   } else {
                     _selectedSlots.add(slot);
                   }
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
