import 'package:flutter/material.dart';

class CustomLogoSpinner extends StatefulWidget {
  final double oneSize;
  final double roundSize;
  final Color color;

  const CustomLogoSpinner({
    super.key,
    this.oneSize = 10,
    this.roundSize = 50,
    this.color = Colors.white,
  });

  @override
  State<CustomLogoSpinner> createState() => _CustomLogoSpinnerState();
}

class _CustomLogoSpinnerState extends State<CustomLogoSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: widget.roundSize,
        width: widget.roundSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating round image
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 3.0 * 3.1416,
                  child: Image.asset(
                    'assets/images/round.png',
                    height: widget.roundSize,
                    width: widget.roundSize,
                    fit: BoxFit.contain,
                    color: widget.color,
                  ),
                );
              },
            ),
            // Static one image in the center
            Image.asset(
              'assets/images/one.png',
              height: widget.oneSize,
              width: widget.oneSize,
              fit: BoxFit.contain,
              color: widget.color,
            ),
          ],
        ),
      ),
    );
  }
}
