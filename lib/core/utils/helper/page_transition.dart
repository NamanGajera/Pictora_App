// Flutter
import 'package:flutter/material.dart';

// Third-party
import 'package:go_router/go_router.dart';

class SlideTransitionPage extends CustomTransitionPage<void> {
  SlideTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.key,
  }) : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from right
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class SlideUpTransitionPage extends CustomTransitionPage<void> {
  SlideUpTransitionPage({
    required super.child,
    super.name,
    super.arguments,
    super.key,
  }) : super(
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Start from bottom
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
