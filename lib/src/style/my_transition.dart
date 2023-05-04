// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import '../style/confetti.dart';

CustomTransitionPage<T> buildMyTransition<T>({
  required Widget child,
  required Color color,
  Decoration? decoration,
  String? name,
  Object? arguments,
  String? restorationId,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _MyReveal(
        animation: animation,
        colors: Confetti(child: child,).colors,
        decoration: decoration ?? BoxDecoration(color: color),
        child: child,
      );
    },
    key: key,
    name: name,
    arguments: arguments,
    restorationId: restorationId,
    transitionDuration: const Duration(milliseconds: 1000),
  );
}

class _MyReveal extends StatefulWidget {
  final Widget child;
  final Animation<double> animation;
  final List<Color> colors;
  final Decoration? decoration;

  const _MyReveal({
    required this.child,
    required this.animation,
    required this.colors,
    this.decoration,
  });

  @override
  State<_MyReveal> createState() => _MyRevealState();
}

class _MyRevealState extends State<_MyReveal> {
  bool _showConfetti = true;

  @override
  void initState() {
    super.initState();
    widget.animation.addStatusListener(_statusListener);
  }

  @override
  void didUpdateWidget(covariant _MyReveal oldWidget) {
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeStatusListener(_statusListener);
      widget.animation.addStatusListener(_statusListener);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_statusListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            return Opacity(
              opacity: 1 - widget.animation.value,
              child: Container(
                decoration: widget.decoration,
              ),
            );
          },
        ),
        Confetti(
          isStopped: widget.animation.value < 1, // Zmiana tutaj
          colors: widget.colors,
          child: AnimatedOpacity(
            opacity: widget.animation.value,
            duration: const Duration(milliseconds: 1000),
            child: widget.child,
          ),
        ),
      ],
    );
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _showConfetti = false;
      });
    } else if (status == AnimationStatus.forward || status == AnimationStatus.reverse) {
      setState(() {
        _showConfetti = true;
      });
    }
  }
}


