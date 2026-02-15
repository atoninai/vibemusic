import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';

enum SortType { title, artist, album, dateAdded, duration }

class MusicScanner {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  /// Query all songs from device storage
  Future<List<Song>> scanAllSongs() async {
    final songModels = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    return songModels
        .where((s) => (s.duration ?? 0) > 10000) // Skip very short audio (<10s)
        .map((s) => Song.fromSongModel(s))
        .toList();
  }

  /// Sort songs by given type
  List<Song> sortSongs(List<Song> songs, SortType sortType, {bool ascending = true}) {
    final sorted = List<Song>.from(songs);
    switch (sortType) {
      case SortType.title:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case SortType.artist:
        sorted.sort((a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()));
      case SortType.album:
        sorted.sort((a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()));
      case SortType.dateAdded:
        sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      case SortType.duration:
        sorted.sort((a, b) => a.duration.compareTo(b.duration));
    }
    if (!ascending) return sorted.reversed.toList();
    return sorted;
  }

  /// Group songs by folder
  Map<String, List<Song>> groupByFolder(List<Song> songs) {
    final map = <String, List<Song>>{};
    for (final song in songs) {
      final folder = song.folder.isEmpty ? 'Unknown' : song.folder;
      map.putIfAbsent(folder, () => []).add(song);
    }
    return map;
  }

  /// Query albums
  Future<List<AlbumModel>> queryAlbums() async {
    return await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }

  /// Query artists
  Future<List<ArtistModel>> queryArtists() async {
    return await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
    );
  }
}
