import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.size = 20.0,
    this.interactive = false,
    this.onRatingChanged,
  });

  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData iconData;
        if (rating >= starValue) {
          iconData = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          iconData = Icons.star_half_rounded;
        } else {
          iconData = Icons.star_outline_rounded;
        }

        final star = Icon(iconData, color: context.palette.warning, size: size);

        if (interactive) {
          return GestureDetector(
            onTap: () {
              if (onRatingChanged != null) {
                onRatingChanged!(starValue);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: star,
            ),
          );
        }

        return star;
      }),
    );
  }
}
