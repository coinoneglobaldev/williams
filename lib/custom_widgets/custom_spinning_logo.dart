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
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: widget.oneSize,
              width:  widget.oneSize,
              child: Image.asset(
                'assets/images/one.png',
                fit: BoxFit.contain,
                color: widget.color,
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2.0 * 3.1416,
                  child: SizedBox(
                    height: widget.roundSize,
                    width: widget.roundSize,
                    child: Image.asset(
                      'assets/images/round.png',
                      fit: BoxFit.contain,
                      color: widget.color,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
