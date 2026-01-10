import 'package:flutter/material.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_time_slot.dart';

class AnimatedTimeSlotGrid extends StatelessWidget {
  final Set<BookingTimeSlot> selectedSlots;
  final ValueChanged<BookingTimeSlot> onSlotSelected;
  final List<BookingTimeSlot> availableSlots;
  final Set<BookingTimeSlot> disabledSlots;

  const AnimatedTimeSlotGrid({
    super.key,
    required this.selectedSlots,
    required this.onSlotSelected,
    this.availableSlots = BookingTimeSlot.values,
    this.disabledSlots = const {},
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: availableSlots.length,
      itemBuilder: (context, index) {
        final slot = availableSlots[index];
        final isSelected = selectedSlots.contains(slot);
        final isDisabled = disabledSlots.contains(slot);

        return GestureDetector(
          onTap: isDisabled ? null : () => onSlotSelected(slot),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isDisabled 
                  ? (isDark ? Colors.grey[800] : Colors.grey[200])
                  : isSelected 
                      ? Theme.of(context).primaryColor 
                      : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDisabled
                    ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                    : isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).dividerColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected && !isDisabled
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    slot.toDisplayName(),
                    style: TextStyle(
                      color: isDisabled 
                          ? Colors.grey 
                          : isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      decoration: isDisabled ? TextDecoration.lineThrough : null,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (isDisabled)
                  const Positioned(
                     right: 8,
                     top: 0,
                     bottom: 0,
                     child: Icon(Icons.block, size: 16, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

