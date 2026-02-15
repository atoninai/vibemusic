import 'package:on_audio_query/on_audio_query.dart' as oaq;

class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration; // in milliseconds
  final String? uri;
  final int? albumId;
  final int dateAdded;
  final String folder;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.uri,
    this.albumId,
    required this.dateAdded,
    required this.folder,
  });

  factory Song.fromSongModel(oaq.SongModel model) {
    final data = model.data;
    String folder = '';
    if (data.isNotEmpty) {
      final lastSlash = data.lastIndexOf('/');
      if (lastSlash > 0) {
        folder = data.substring(0, lastSlash);
      }
    }

    return Song(
      id: model.id,
      title: model.title.isNotEmpty ? model.title : 'Unknown',
      artist: model.artist ?? 'Unknown Artist',
      album: model.album ?? 'Unknown Album',
      duration: model.duration ?? 0,
      uri: model.uri,
      albumId: model.albumId,
      dateAdded: model.dateModified ?? 0,
      folder: folder,
    );
  }

  String get durationFormatted {
    final d = Duration(milliseconds: duration);
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
