import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/music_scanner.dart';

class MusicProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final MusicScanner _scanner = MusicScanner();

  List<Song> _allSongs = [];
  List<Song> _recentlyPlayed = [];
  Set<int> _favoriteIds = {};
  Map<String, List<Song>> _folders = {};
  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;
  SortType _currentSort = SortType.title;
  bool _overlayEnabled = false;
  bool _shuffleMode = false;
  LoopMode _loopMode = LoopMode.off;

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Song> get recentlyPlayed => _recentlyPlayed;
  Set<int> get favoriteIds => _favoriteIds;
  List<Song> get favorites => _allSongs.where((s) => _favoriteIds.contains(s.id)).toList();
  Map<String, List<Song>> get folders => _folders;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get totalDuration => _totalDuration;
  bool get isLoading => _isLoading;
  SortType get currentSort => _currentSort;
  AudioPlayerService get audioService => _audioService;
  bool get overlayEnabled => _overlayEnabled;
  bool get shuffleMode => _shuffleMode;
  LoopMode get loopMode => _loopMode;

  MusicProvider() {
    _init();
  }

  void _init() {
    // Listen to position
    _audioService.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
      _updateOverlay();
    });

    // Listen to duration
    _audioService.durationStream.listen((dur) {
      _totalDuration = dur ?? Duration.zero;
      notifyListeners();
    });

    // Listen to playing state
    _audioService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
      _updateOverlay();
    });

    // Auto-next on song complete
    _audioService.setupAutoNext(() {
      playNext();
    });

    _loadPreferences();
  }

  /// Load favorites and settings from SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favoriteIds') ?? [];
    _favoriteIds = favIds.map((id) => int.parse(id)).toSet();

    _overlayEnabled = prefs.getBool('overlayEnabled') ?? false;
    notifyListeners();
  }

  /// Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoriteIds',
      _favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  /// Save recently played to SharedPreferences
  Future<void> _saveRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recentlyPlayedIds',
      _recentlyPlayed.map((s) => s.id.toString()).toList(),
    );
  }

  /// Load all songs from device
  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSongs = await _scanner.scanAllSongs();
      _allSongs = _scanner.sortSongs(_allSongs, _currentSort);
      _folders = _scanner.groupByFolder(_allSongs);

      // Restore recently played
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList('recentlyPlayedIds') ?? [];
      _recentlyPlayed = recentIds
          .map((id) => _allSongs.where((s) => s.id == int.tryParse(id)).firstOrNull)
          .whereType<Song>()
          .take(20)
          .toList();
    } catch (e) {
      print('Error loading songs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Play a song
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    _currentSong = song;
    notifyListeners();

    await _audioService.playSong(
      song,
      playlist: playlist ?? _allSongs,
      index: index ?? _allSongs.indexOf(song),
    );

    _addToRecentlyPlayed(song);
    _updateOverlay();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  /// Play next
  Future<void> playNext() async {
    await _audioService.playNext();
    _currentSong = _audioService.currentSong;
    if (_currentSong != null) {
      _addToRecentlyPlayed(_currentSong!);
    }
    notifyListeners();
    _updateOverlay();
  }

  /// Play previous
  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    _currentSong = _audioService.currentSong;
    notifyListeners();
    _updateOverlay();
  }

  /// Seek
  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  /// Toggle shuffle
  void toggleShuffle() {
    _audioService.toggleShuffle();
    _shuffleMode = _audioService.shuffleMode;
    notifyListeners();
  }

  /// Toggle loop mode
  void toggleLoopMode() {
    _audioService.toggleLoopMode();
    _loopMode = _audioService.loopMode;
    notifyListeners();
  }

  /// Toggle favorite
  void toggleFavorite(int songId) {
    if (_favoriteIds.contains(songId)) {
      _favoriteIds.remove(songId);
    } else {
      _favoriteIds.add(songId);
    }
    _saveFavorites();
    notifyListeners();
  }

  /// Check if song is favorite
  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  /// Add to recently played
  void _addToRecentlyPlayed(Song song) {
    _recentlyPlayed.removeWhere((s) => s.id == song.id);
    _recentlyPlayed.insert(0, song);
    if (_recentlyPlayed.length > 20) {
      _recentlyPlayed = _recentlyPlayed.sublist(0, 20);
    }
    _saveRecentlyPlayed();
  }

  /// Sort songs
  void sortSongs(SortType sortType) {
    _currentSort = sortType;
    _allSongs = _scanner.sortSongs(_allSongs, sortType);
    notifyListeners();
  }

  /// Search songs
  List<Song> searchSongs(String query) {
    if (query.isEmpty) return _allSongs;
    final q = query.toLowerCase();
    return _allSongs.where((s) =>
      s.title.toLowerCase().contains(q) ||
      s.artist.toLowerCase().contains(q) ||
      s.album.toLowerCase().contains(q)
    ).toList();
  }

  /// Toggle overlay
  Future<void> toggleOverlay(bool enabled) async {
    _overlayEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('overlayEnabled', enabled);
    
    if (enabled && _currentSong != null) {
      await _showOverlay();
    } else if (!enabled) {
      try {
        await FlutterOverlayWindow.closeOverlay();
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Show overlay
  Future<void> _showOverlay() async {
    try {
      final isActive = await FlutterOverlayWindow.isActive();
      if (!isActive) {
        await FlutterOverlayWindow.showOverlay(
          enableDrag: true,
          overlayTitle: "Vibeland",
          overlayContent: _currentSong?.title ?? '',
          flag: OverlayFlag.defaultFlag,
          visibility: NotificationVisibility.visibilityPublic,
          positionGravity: PositionGravity.auto,
          height: 120,
          width: WindowSize.matchParent,
        );
      }
    } catch (_) {}
  }

  /// Update overlay data
  void _updateOverlay() {
    if (!_overlayEnabled || _currentSong == null) return;
    
    try {
      final data = jsonEncode({
        'title': _currentSong!.title,
        'artist': _currentSong!.artist,
        'isPlaying': _isPlaying,
        'position': _position.inMilliseconds,
        'duration': _totalDuration.inMilliseconds,
        'songId': _currentSong!.id,
      });
      FlutterOverlayWindow.shareData(data);
    } catch (_) {}
  }

  /// Rescan music library
  Future<void> rescanLibrary() async {
    await loadSongs();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
