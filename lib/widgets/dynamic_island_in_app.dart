import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'waveform_bars.dart';

class DynamicIslandInApp extends StatelessWidget {
  final String? songTitle;
  final bool isPlaying;

  const DynamicIslandInApp({
    super.key,
    this.songTitle,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 36,
        constraints: const BoxConstraints(minWidth: 126, maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: animated equalizer bars
            WaveformBars(
              barCount: 3,
              height: 12,
              barWidth: 3,
              isPlaying: isPlaying,
              color: AppTheme.primary,
            ),
            if (songTitle != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  songTitle!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Right: spinning graphic_eq
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: isPlaying ? 1 : 0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28,
                  child: Icon(
                    Icons.graphic_eq,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
