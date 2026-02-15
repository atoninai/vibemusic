import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final results = provider.searchSongs(_query);

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x08FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x14FFFFFF)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search songs, artists, albums...',
                      hintStyle: TextStyle(color: Colors.white.withAlpha(77)),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white.withAlpha(128)),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white54, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() => _query = value);
                    },
                  ),
                ),
              ),
            ),

            // Results count
            if (_query.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    '${results.length} results',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ),
              ),

            // Results or empty state
            _query.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, color: Colors.white.withAlpha(51), size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Search your music library',
                            style: TextStyle(color: Colors.white.withAlpha(77), fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = results[index];
                          final isPlaying = provider.currentSong?.id == song.id;
                          return SongTile(
                            song: song,
                            isPlaying: isPlaying,
                            onTap: () => provider.playSong(song, playlist: results, index: index),
                          );
                        },
                        childCount: results.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }
}
