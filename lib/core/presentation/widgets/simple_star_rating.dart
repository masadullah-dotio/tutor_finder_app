import 'package:flutter/material.dart';

class SimpleStarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color color;

  const SimpleStarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20.0,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index < rating) {
          return Icon(Icons.star, color: color, size: size);
        } else {
          return Icon(Icons.star_border, color: color, size: size);
        }
      }),
    );
  }
}
