import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool isPlaying;
  final Widget? trailing;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 52,
          height: 52,
          child: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            artworkBorder: BorderRadius.circular(10),
            nullArtworkWidget: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withAlpha(100),
                    AppTheme.primary.withAlpha(50),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.music_note, color: AppTheme.primary, size: 24),
            ),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isPlaying ? AppTheme.primary : Colors.white,
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} • ${song.durationFormatted}',
        style: TextStyle(
          color: isPlaying ? AppTheme.primary.withAlpha(180) : AppTheme.textSecondary,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: trailing ??
          (isPlaying
              ? const Icon(Icons.equalizer, color: AppTheme.primary, size: 20)
              : null),
    );
  }
}
