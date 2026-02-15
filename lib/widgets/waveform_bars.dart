import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WaveformBars extends StatefulWidget {
  final int barCount;
  final double height;
  final double barWidth;
  final bool isPlaying;
  final Color? color;

  const WaveformBars({
    super.key,
    this.barCount = 4,
    this.height = 16,
    this.barWidth = 3,
    this.isPlaying = true,
    this.color,
  });

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + _random.nextInt(400)),
      );
    });

    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isPlaying) _startAnimations();
  }

  void _startAnimations() {
    for (var c in _controllers) {
      c.repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (var c in _controllers) {
      c.stop();
    }
  }

  @override
  void didUpdateWidget(WaveformBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _startAnimations();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(widget.barCount, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (context, child) {
            return Container(
              width: widget.barWidth,
              height: widget.height * _animations[i].value,
              margin: EdgeInsets.symmetric(horizontal: widget.barWidth > 2 ? 1.5 : 0.5),
              decoration: BoxDecoration(
                color: color.withAlpha((255 * (0.4 + 0.6 * _animations[i].value)).toInt()),
                borderRadius: BorderRadius.circular(widget.barWidth),
              ),
            );
          },
        );
      }),
    );
  }
}
