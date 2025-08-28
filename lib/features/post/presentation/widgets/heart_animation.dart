// Dart SDK
import 'dart:math';

// Flutter
import 'package:flutter/material.dart';

class HeartAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;

  const HeartAnimationWidget({
    super.key,
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 2200),
    this.onEnd,
  });

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> rotation;
  late Animation<double> moveUp;

  LinearGradient? currentGradient;

  final List<List<Color>> gradients = [
    [Colors.pinkAccent, Colors.redAccent],
    [Colors.blueAccent, Colors.cyan],
    [Colors.purpleAccent, Colors.deepPurple],
    [Colors.orangeAccent, Colors.deepOrange],
    [Colors.greenAccent, Colors.teal],
  ];

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Scale: pop in -> settle down
    scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    // Rotation: swing right-left-center
    rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Move up slowly
    moveUp = Tween<double>(begin: 0, end: -40).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HeartAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating != oldWidget.isAnimating && widget.isAnimating) {
      doAnimation();
    }
  }

  Future doAnimation() async {
    // Pick random gradient
    setState(() {
      final random = Random();
      final colors = gradients[random.nextInt(gradients.length)];
      currentGradient = LinearGradient(colors: colors);
    });

    controller.forward(from: 0).whenComplete(() {
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, moveUp.value),
          child: Transform.scale(
            scale: scale.value,
            child: Transform.rotate(
              angle: rotation.value,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return (currentGradient ?? LinearGradient(colors: [Colors.grey, Colors.black])).createShader(bounds);
                },
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
