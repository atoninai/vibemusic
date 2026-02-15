import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _shuffleMode = false;
  LoopMode _loopMode = LoopMode.off;

  // Getters
  AudioPlayer get player => _player;
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get shuffleMode => _shuffleMode;
  LoopMode get loopMode => _loopMode;
  bool get isPlaying => _player.playing;
  
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;
  
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;

  /// Play a specific song
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    _currentSong = song;
    if (playlist != null) {
      _queue = List.from(playlist);
      _currentIndex = index ?? 0;
    }
    
    try {
      if (song.uri != null) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      } else {
        // Fallback: try using file path from data
        await _player.setFilePath(song.uri ?? '');
      }
      await _player.play();
    } catch (e) {
      // Log error but continue
      print('Error playing song: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  /// Pause
  Future<void> pause() async => await _player.pause();

  /// Resume
  Future<void> resume() async => await _player.play();

  /// Stop
  Future<void> stop() async => await _player.stop();

  /// Seek to position
  Future<void> seek(Duration position) async => await _player.seek(position);

  /// Play next song in queue
  Future<void> playNext() async {
    if (_queue.isEmpty) return;
    
    if (_shuffleMode) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _queue.length).toInt();
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    
    await playSong(_queue[_currentIndex]);
  }

  /// Play previous song in queue
  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;
    
    // If more than 3 seconds in, restart current song
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await playSong(_queue[_currentIndex]);
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _shuffleMode = !_shuffleMode;
  }

  /// Toggle loop mode: off → all → one → off
  void toggleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        _player.setLoopMode(_loopMode);
      case LoopMode.all:
        _loopMode = LoopMode.one;
        _player.setLoopMode(_loopMode);
      case LoopMode.one:
        _loopMode = LoopMode.off;
        _player.setLoopMode(_loopMode);
    }
  }

  /// Setup auto-next when song completes
  void setupAutoNext(Function onComplete) {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          seek(Duration.zero);
          _player.play();
        } else {
          onComplete();
        }
      }
    });
  }

  /// Dispose
  Future<void> dispose() async {
    await _player.dispose();
  }
}
