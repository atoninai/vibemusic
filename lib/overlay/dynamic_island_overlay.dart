import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../theme/app_theme.dart';
import '../widgets/waveform_bars.dart';

class DynamicIslandOverlay extends StatefulWidget {
  const DynamicIslandOverlay({super.key});

  @override
  State<DynamicIslandOverlay> createState() => _DynamicIslandOverlayState();
}

class _DynamicIslandOverlayState extends State<DynamicIslandOverlay>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  String _title = 'No Song';
  String _artist = 'Unknown';
  bool _isPlaying = false;
  double _progress = 0.0;
  int _positionMs = 0;
  int _durationMs = 0;

  late AnimationController _expandController;

  @override
  void initState() {
    super.initState();

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    );

    // Listen for data from main app
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data is String) {
        try {
          final map = jsonDecode(data) as Map<String, dynamic>;
          setState(() {
            _title = map['title'] ?? 'No Song';
            _artist = map['artist'] ?? 'Unknown';
            _isPlaying = map['isPlaying'] ?? false;
            _positionMs = map['position'] ?? 0;
            _durationMs = map['duration'] ?? 0;
            _progress = _durationMs > 0 ? _positionMs / _durationMs : 0.0;
          });
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _expandController.forward();
      // Resize overlay for expanded state
      FlutterOverlayWindow.resizeOverlay(
        WindowSize.matchParent,
        280,
        false,
      );
    } else {
      _expandController.reverse();
      // Resize overlay for minimized state
      FlutterOverlayWindow.resizeOverlay(
        WindowSize.matchParent,
        120,
        false,
      );
    }
  }

  void _sendCommand(String command) {
    FlutterOverlayWindow.shareData(jsonEncode({'command': command}));
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _toggleExpand,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            width: _isExpanded ? MediaQuery.of(context).size.width * 0.94 : 140,
            padding: EdgeInsets.all(_isExpanded ? 20 : 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(_isExpanded ? 36 : 50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(128),
                  blurRadius: _isExpanded ? 40 : 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: _isExpanded ? _buildExpanded() : _buildMinimized(),
          ),
        ),
      ),
    );
  }

  /// Minimized pill — matching dynamicisland_dot_outsideapp.html
  Widget _buildMinimized() {
    return SizedBox(
      height: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: purple circle with graphic_eq
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq, color: Colors.white, size: 12),
          ),
          // Right: tiny waveform bars + pulsing dot
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WaveformBars(
                barCount: 3,
                height: 10,
                barWidth: 2,
                isPlaying: _isPlaying,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _isPlaying ? AppTheme.primary : AppTheme.primary.withAlpha(100),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Expanded state — matching dynamic_island_expanded_outsideapp.html
  Widget _buildExpanded() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Top: album art + info + waveform
        Row(
          children: [
            // Album art placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primary.withAlpha(128),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.music_note, color: Colors.white70, size: 28),
                  ),
                  // Playing indicator overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(51),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: WaveformBars(
                        barCount: 3,
                        height: 12,
                        barWidth: 3,
                        isPlaying: _isPlaying,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.graphic_eq, color: AppTheme.primary, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'PLAYING NOW',
                        style: TextStyle(
                          color: AppTheme.primary.withAlpha(200),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _artist,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Waveform visualizer
            WaveformBars(
              barCount: 6,
              height: 32,
              barWidth: 3,
              isPlaying: _isPlaying,
              color: AppTheme.primary,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: LinearProgressIndicator(
              value: _progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[850],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),

        // Time indicators
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_positionMs),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '-${_formatDuration(_durationMs - _positionMs)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.skip_previous, color: Colors.grey, size: 30),
              onPressed: () => _sendCommand('previous'),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () => _sendCommand('togglePlayPause'),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.grey, size: 30),
              onPressed: () => _sendCommand('next'),
            ),
          ],
        ),
      ],
    );
  }
}
