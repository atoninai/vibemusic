import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/dynamic_island_in_app.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final song = provider.currentSong;
        if (song == null) {
          return const Scaffold(
            backgroundColor: AppTheme.backgroundDarkAlt,
            body: Center(child: Text('No song playing', style: TextStyle(color: Colors.white54))),
          );
        }

        final isFavorite = provider.isFavorite(song.id);
        final position = provider.position;
        final duration = provider.totalDuration;
        final progress = duration.inMilliseconds > 0
            ? position.inMilliseconds / duration.inMilliseconds
            : 0.0;

        return Scaffold(
          backgroundColor: AppTheme.backgroundDarkAlt,
          body: Stack(
            children: [
              // Ambient glow effects
              Positioned(
                top: -50,
                left: -100,
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.2,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withAlpha(64),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                right: -50,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.indigo.withAlpha(25),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Dynamic Island
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: DynamicIslandInApp(
                        songTitle: song.title,
                        isPlaying: provider.isPlaying,
                      ),
                    ),

                    // Top Toolbar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: Colors.white.withAlpha(102),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: Colors.white60, size: 28),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Album Art
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow behind
                                Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withAlpha(100),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                // Album Art
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withAlpha(25)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(128),
                                          blurRadius: 50,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: QueryArtworkWidget(
                                      id: song.id,
                                      type: ArtworkType.AUDIO,
                                      artworkBorder: BorderRadius.circular(20),
                                      artworkQuality: FilterQuality.high,
                                      size: 600,
                                      nullArtworkWidget: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.primary,
                                              AppTheme.primary.withAlpha(128),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.music_note, color: Colors.white54, size: 80),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Track Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.artist,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withAlpha(128),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: AppTheme.primary,
                              size: 28,
                            ),
                            onPressed: () => provider.toggleFavorite(song.id),
                          ),
                        ],
                      ),
                    ),

                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
                      child: Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppTheme.primary,
                              inactiveTrackColor: Colors.white.withAlpha(25),
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              trackHeight: 4,
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPos = Duration(
                                  milliseconds: (value * duration.inMilliseconds).toInt(),
                                );
                                provider.seek(newPos);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withAlpha(77),
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withAlpha(77),
                                    fontFamily: 'monospace',
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Playback Controls
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 20, 32, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Shuffle
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: provider.shuffleMode
                                  ? AppTheme.primary
                                  : Colors.white.withAlpha(102),
                              size: 24,
                            ),
                            onPressed: provider.toggleShuffle,
                          ),
                          // Main controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                                onPressed: provider.playPrevious,
                              ),
                              const SizedBox(width: 16),
                              // Play/Pause
                              GestureDetector(
                                onTap: provider.togglePlayPause,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primary.withAlpha(100),
                                        blurRadius: 30,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    provider.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                                onPressed: provider.playNext,
                              ),
                            ],
                          ),
                          // Repeat
                          IconButton(
                            icon: Icon(
                              provider.loopMode == LoopMode.one
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              color: provider.loopMode != LoopMode.off
                                  ? AppTheme.primary
                                  : Colors.white.withAlpha(102),
                              size: 24,
                            ),
                            onPressed: provider.toggleLoopMode,
                          ),
                        ],
                      ),
                    ),

                    // Bottom actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.lyrics, color: Colors.white.withAlpha(128), size: 22),
                            onPressed: () {},
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.headphones, color: AppTheme.primary, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Speaker',
                                  style: TextStyle(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.queue_music, color: Colors.white.withAlpha(128), size: 22),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
