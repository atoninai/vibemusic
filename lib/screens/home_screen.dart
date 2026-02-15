
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }

        return CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(77),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.music_note, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Vibeland',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GlassCard(
                          padding: const EdgeInsets.all(8),
                          borderRadius: 50,
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primary.withAlpha(51),
                            border: Border.all(color: AppTheme.primary.withAlpha(77)),
                          ),
                          child: const Icon(Icons.person, color: AppTheme.primary, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Recently Played Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recently Played',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See all',
                        style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recently Played Carousel
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: provider.recentlyPlayed.isEmpty
                    ? _buildEmptyRecent()
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: provider.recentlyPlayed.length.clamp(0, 10),
                        itemBuilder: (context, index) {
                          final song = provider.recentlyPlayed[index];
                          return _RecentlyPlayedCard(
                            song: song,
                            onTap: () => provider.playSong(song),
                          );
                        },
                      ),
              ),
            ),

            // Your Favorites Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Favorites',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Icon(Icons.favorite, color: AppTheme.textSecondary, size: 22),
                  ],
                ),
              ),
            ),

            // Favorites Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: provider.favorites.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyFavorites())
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = provider.favorites[index];
                          return _FavoriteCard(
                            song: song,
                            onTap: () => provider.playSong(song),
                          );
                        },
                        childCount: provider.favorites.length.clamp(0, 4),
                      ),
                    ),
            ),

            // Local Folders Section
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 12),
                child: Text(
                  'Local Folders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),

            // Folder List
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final folder = provider.folders.keys.toList()[index];
                    final songs = provider.folders[folder]!;
                    final folderName = folder.split('/').last;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FolderTile(
                        name: folderName,
                        path: folder,
                        trackCount: songs.length,
                        onTap: () {
                          // Could navigate to folder detail
                        },
                      ),
                    );
                  },
                  childCount: provider.folders.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyRecent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, color: AppTheme.textTertiary, size: 40),
            const SizedBox(height: 8),
            Text(
              'Play some music to see your history',
              style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Tap the heart icon on any song to add favorites',
          style: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
        ),
      ),
    );
  }
}

class _RecentlyPlayedCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _RecentlyPlayedCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album art
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 180,
                height: 160,
                child: Stack(
                  children: [
                    QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 180,
                      artworkHeight: 160,
                      artworkFit: BoxFit.cover,
                      artworkBorder: BorderRadius.circular(16),
                      nullArtworkWidget: Container(
                        width: 180,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primary.withAlpha(200),
                              AppTheme.primary.withAlpha(80),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.music_note, size: 48, color: Colors.white70),
                      ),
                    ),
                    // Hover overlay with play
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              song.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _FavoriteCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      borderRadius: 16,
      child: Row(
        children: [
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
                    color: AppTheme.primary.withAlpha(80),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note, color: AppTheme.primary, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolderTile extends StatelessWidget {
  final String name;
  final String path;
  final int trackCount;
  final VoidCallback onTap;

  const _FolderTile({
    required this.name,
    required this.path,
    required this.trackCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData folderIcon = Icons.folder;
    if (path.toLowerCase().contains('download')) {
      folderIcon = Icons.download_for_offline;
    } else if (path.toLowerCase().contains('sd') || path.toLowerCase().contains('external')) {
      folderIcon = Icons.sd_card;
    }

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(folderIcon, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  path,
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '$trackCount tracks',
            style: const TextStyle(color: AppTheme.textTertiary, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppTheme.textTertiary, size: 22),
        ],
      ),
    );
  }
}
