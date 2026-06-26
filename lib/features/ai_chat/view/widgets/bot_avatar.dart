import 'package:flutter/material.dart';

class BotAvatar extends StatelessWidget {
  const BotAvatar({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.62,
          height: size * 0.46,
          decoration: BoxDecoration(
            color: const Color(0xFF15161B),
            borderRadius: BorderRadius.circular(size * 0.18),
            border: Border.all(color: Colors.white, width: size * 0.025),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: size * 0.18,
                child: BotEye(size: size * 0.055),
              ),
              Positioned(
                right: size * 0.18,
                child: BotEye(size: size * 0.055),
              ),
              Positioned(
                bottom: size * 0.11,
                child: Container(
                  width: size * 0.16,
                  height: size * 0.035,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BotEye extends StatelessWidget {
  const BotEye({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
