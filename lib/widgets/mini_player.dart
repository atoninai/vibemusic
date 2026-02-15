import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../screens/now_playing_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (song == null) return const SizedBox.shrink();

        final progress = provider.totalDuration.inMilliseconds > 0
            ? provider.position.inMilliseconds / provider.totalDuration.inMilliseconds
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x33FFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(128),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          // Album art
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(10),
                                nullArtworkWidget: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primary.withAlpha(150),
                                        AppTheme.primary.withAlpha(80),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Song info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.artist,
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Controls
                          IconButton(
                            icon: const Icon(Icons.skip_previous, color: Colors.white, size: 24),
                            onPressed: provider.playPrevious,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAlpha(102),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                provider.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: provider.togglePlayPause,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.skip_next, color: Colors.white, size: 24),
                            onPressed: provider.playNext,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36),
                          ),
                        ],
                      ),
                      // Progress bar at bottom
                      Positioned(
                        bottom: -12,
                        left: -12,
                        right: -12,
                        child: SizedBox(
                          height: 2,
                          child: Stack(
                            children: [
                              Container(
                                color: Colors.white.withAlpha(25),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
