import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final Color color;
  final double size;
  final bool allowHalfRating;
  final ValueChanged<double>? onRatingChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.color = Colors.amber,
    this.size = 24.0,
    this.allowHalfRating = false,
    this.onRatingChanged,
  });

  Widget _buildStar(BuildContext context, int index) {
    IconData icon;
    if (index >= rating) {
      icon = Icons.star_border_rounded;
    } else if (index > rating - 1 && index < rating) {
      icon = Icons.star_half_rounded;
    } else {
      icon = Icons.star_rounded;
    }

    final widget = Icon(
      icon,
      color: color,
      size: size,
    );

    if (onRatingChanged == null) return widget;

    return GestureDetector(
      onTap: () {
        if (onRatingChanged != null) onRatingChanged!(index + 1.0);
      },
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        starCount,
        (index) => _buildStar(context, index),
      ),
    );
  }
}
