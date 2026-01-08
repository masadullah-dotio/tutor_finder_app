import 'package:flutter/material.dart';
import 'package:tutor_finder_app/features/booking/data/models/booking_type.dart';

class AnimatedBookingModeSelector extends StatelessWidget {
  final BookingType selectedMode;
  final ValueChanged<BookingType> onModeChanged;

  const AnimatedBookingModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // 2 items: Online, Home
          final itemWidth = width / 2;

          return Stack(
            children: [
              // Animated Background Indicator
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: selectedMode == BookingType.online
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Container(
                  width: itemWidth,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons
              Row(
                children: [
                  _buildOption(
                    context,
                    BookingType.online,
                    Icons.videocam_rounded,
                  ),
                  _buildOption(
                    context,
                    BookingType.home,
                    Icons.home_rounded,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOption(BuildContext context, BookingType type, IconData icon) {
    final isSelected = selectedMode == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(type),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                type.toDisplayName(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
