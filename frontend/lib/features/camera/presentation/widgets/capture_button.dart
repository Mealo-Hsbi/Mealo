import 'package:flutter/material.dart';

class AnimatedCaptureButton extends StatefulWidget {
  final VoidCallback onTap;
  const AnimatedCaptureButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AnimatedCaptureButton> createState() => _AnimatedCaptureButtonState();
}

class _AnimatedCaptureButtonState extends State<AnimatedCaptureButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 80),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    // _controller.forward(); // Animation aktuell deaktiviert
  }

  void _onTapUp(TapUpDetails details) async {
    widget.onTap();
    // await Future.delayed(const Duration(milliseconds: 40));
    // if (mounted) {
    //   _controller.reverse();
    // }
  }

  void _onTapCancel() {
    // _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          color: Colors.transparent,
        ),
        child: Center(
          // du kannst hier die Animation wieder aktivieren, indem du AnimatedBuilder + Transform.scale wieder nutzt
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // innerer Kreis jetzt weiß
            ),
          ),
        ),
      ),
    );
  }
}