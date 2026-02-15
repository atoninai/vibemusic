import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../services/music_scanner.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  SortType _sortType = SortType.title;

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final songs = provider.allSongs;

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Library',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${songs.length} songs',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Sort dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0x08FFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SortType>(
                          value: _sortType,
                          dropdownColor: const Color(0xFF1A1A2E),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          icon: const Icon(Icons.sort, color: AppTheme.primary, size: 18),
                          isDense: true,
                          items: const [
                            DropdownMenuItem(value: SortType.title, child: Text('Title')),
                            DropdownMenuItem(value: SortType.artist, child: Text('Artist')),
                            DropdownMenuItem(value: SortType.album, child: Text('Album')),
                            DropdownMenuItem(value: SortType.dateAdded, child: Text('Date Added')),
                            DropdownMenuItem(value: SortType.duration, child: Text('Duration')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortType = value);
                              provider.sortSongs(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Song List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    final isPlaying = provider.currentSong?.id == song.id;
                    return SongTile(
                      song: song,
                      isPlaying: isPlaying,
                      onTap: () => provider.playSong(song, playlist: songs, index: index),
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
