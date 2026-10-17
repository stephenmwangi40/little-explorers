import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../content/phonics.dart';
import 'state/models.dart';

/// Narration (on-device text-to-speech, no network) plus captions,
/// sound effects and gentle background music with ducking.
class Audio {
  Audio._();
  static final Audio I = Audio._();

  // Created in init(), so nothing touches platform plugins before then.
  late final FlutterTts _tts;
  late final AudioPlayer _music;
  late final List<AudioPlayer> _sfx;
  int _sfxNext = 0;
  bool _ready = false;
  Settings _s = Settings();
  bool _musicWanted = false;

  /// The caption for the line being narrated (shown under the coach).
  final ValueNotifier<String> caption = ValueNotifier('');

  /// True while Tiko is talking. Games wait for this before "Next" is
  /// enabled, so every explanation is heard in full.
  final ValueNotifier<bool> speaking = ValueNotifier(false);
  Timer? _speechGuard;

  void _doneSpeaking() {
    _speechGuard?.cancel();
    speaking.value = false;
  }

  Future<void> init(Settings s) async {
    _s = s;
    try {
      _tts = FlutterTts();
      _music = AudioPlayer(playerId: 'music');
      _sfx = List.generate(3, (i) => AudioPlayer(playerId: 'sfx$i'));
      await _tts.awaitSpeakCompletion(false);
      _tts.setStartHandler(() => _duck(true));
      _tts.setCompletionHandler(() {
        _duck(false);
        _doneSpeaking();
      });
      _tts.setCancelHandler(() => _duck(false));
      _tts.setErrorHandler((_) {
        _duck(false);
        _doneSpeaking();
      });
      await _music.setReleaseMode(ReleaseMode.loop);
      for (final p in _sfx) {
        await p.setReleaseMode(ReleaseMode.stop);
      }
      _ready = true;
      await apply(s);
    } catch (e) {
      debugPrint('Audio init failed: $e');
    }
  }

  Future<void> apply(Settings s) async {
    _s = s;
    if (!_ready) return;
    try {
      final lang = switch (s.english) { 'UK' => 'en-GB', 'AU' => 'en-AU', _ => 'en-US' };
      await _tts.setLanguage(lang);
      // Slow narration for younger children.
      await _tts.setSpeechRate(kIsWeb ? (s.slowNarration ? .7 : .9) : (s.slowNarration ? .32 : .45));
      await _tts.setPitch(1.15);
      if (!s.music) {
        await _music.pause();
      } else if (_musicWanted) {
        await _startMusic();
      }
    } catch (e) {
      debugPrint('Audio settings failed: $e');
    }
  }

  /// Converts phonics notation like "/a/" into something TTS can say.
  static String speakable(String text) => text.replaceAllMapped(RegExp(r'/([a-z]{1,3})/'), (m) {
        final g = m.group(1)!;
        return speakSound[g] ?? g;
      });

  Future<void> say(String text, {String? speech}) async {
    caption.value = text;
    // Until the voice says it has finished, assume talking. A backup timer
    // (about the time it takes to read the words) covers devices without a
    // voice or with narration switched off, so the child can always go on.
    final words = (speech ?? text).split(RegExp(r's+')).length;
    final slow = _s.slowNarration ? 1.35 : 1.0;
    final estimate = Duration(milliseconds: (900 + words * 420 * slow).round());
    speaking.value = true;
    _speechGuard?.cancel();
    _speechGuard = Timer(
        !_ready || !_s.narration ? Duration(milliseconds: (600 + words * 250).clamp(1200, 4000)) : estimate * 1.6,
        _doneSpeaking);
    if (!_ready || !_s.narration) return;
    try {
      await _tts.stop();
      await _tts.speak(speech ?? speakable(text));
    } catch (e) {
      debugPrint('TTS failed: $e');
      _doneSpeaking();
    }
  }

  Future<void> stopSpeaking() async {
    try {
      if (_ready) await _tts.stop();
    } catch (_) {}
  }

  Future<void> sfx(String name) async {
    if (!_s.sound) return;
    if (name == 'tap') HapticFeedback.selectionClick();
    if (!_ready) return;
    try {
      final p = _sfx[_sfxNext++ % _sfx.length];
      await p.stop();
      await p.play(AssetSource('audio/$name.wav'), volume: .7);
    } catch (e) {
      debugPrint('SFX failed: $e');
    }
  }

  Future<void> musicOn() async {
    _musicWanted = true;
    if (_s.music) await _startMusic();
  }

  Future<void> musicOff() async {
    _musicWanted = false;
    try {
      if (_ready) await _music.pause();
    } catch (_) {}
  }

  bool _musicPlaying = false;
  Future<void> _startMusic() async {
    if (!_ready || _musicPlaying && _music.state == PlayerState.playing) return;
    try {
      if (_music.source == null) {
        await _music.setSource(AssetSource('audio/music.wav'));
      }
      await _music.setVolume(.25);
      await _music.resume();
      _musicPlaying = true;
    } catch (e) {
      debugPrint('Music failed: $e');
    }
  }

  void _duck(bool speaking) {
    if (!_ready) return;
    _music.setVolume(speaking ? .07 : .25).catchError((_) {});
  }
}
