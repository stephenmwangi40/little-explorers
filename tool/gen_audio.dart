// Generates the small sound effects and the gentle music loop used by the app.
// Everything is synthesised here, so no third-party audio is bundled.
// Run with: dart run tool/gen_audio.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

const rate = 22050;

double note(String n) {
  const names = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2};
  final octave = int.parse(n.substring(n.length - 1));
  final semis = names[n[0]]! + (octave - 4) * 12;
  return 440 * pow(2, semis / 12).toDouble();
}

List<double> tone(double freq, double secs, {double vol = .5, double decay = 4}) {
  final n = (secs * rate).round();
  return List.generate(n, (i) {
    final t = i / rate;
    final attack = min(1.0, t / 0.01);
    final env = attack * exp(-decay * t);
    // A soft bell: fundamental plus a quiet octave.
    return vol * env * (sin(2 * pi * freq * t) + .3 * sin(4 * pi * freq * t)) / 1.3;
  });
}

List<double> mix(List<List<double>> parts, List<double> offsets) {
  var len = 0;
  for (var i = 0; i < parts.length; i++) {
    len = max(len, (offsets[i] * rate).round() + parts[i].length);
  }
  final out = List<double>.filled(len, 0);
  for (var i = 0; i < parts.length; i++) {
    final o = (offsets[i] * rate).round();
    for (var j = 0; j < parts[i].length; j++) {
      out[o + j] += parts[i][j];
    }
  }
  return out;
}

void writeWav(String path, List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void str(int off, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(off + i, s.codeUnitAt(i));
    }
  }

  str(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  str(8, 'WAVE');
  str(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little);
  data.setUint16(22, 1, Endian.little);
  data.setUint32(24, rate, Endian.little);
  data.setUint32(28, rate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  str(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(44 + i * 2, (samples[i].clamp(-1.0, 1.0) * 32000).round(), Endian.little);
  }
  File(path).writeAsBytesSync(data.buffer.asUint8List());
}

void main() {
  Directory('assets/audio').createSync(recursive: true);
  writeWav('assets/audio/tap.wav', tone(note('E5'), .12, vol: .35, decay: 30));
  writeWav('assets/audio/correct.wav',
      mix([tone(note('C5'), .4), tone(note('E5'), .4), tone(note('G5'), .6)], [0, .09, .18]));
  // Gentle and never harsh: "try again" is a soft two-note step, not a buzzer.
  writeWav('assets/audio/try.wav',
      mix([tone(note('G4'), .3, vol: .3, decay: 7), tone(note('E4'), .4, vol: .3, decay: 6)], [0, .14]));
  writeWav(
      'assets/audio/reward.wav',
      mix([
        for (final n in ['C5', 'E5', 'G5', 'C6', 'G5', 'C6']) tone(note(n), .5, vol: .4),
      ], [0, .12, .24, .36, .52, .64]));
  // A calm pentatonic loop for background music (16 seconds).
  final melody = ['C4', 'E4', 'G4', 'A4', 'G4', 'E4', 'D4', 'E4', 'G4', 'A4', 'C5', 'A4', 'G4', 'E4', 'D4', 'C4'];
  final bass = ['C3', 'A2', 'F2', 'G2'];
  final parts = <List<double>>[];
  final offs = <double>[];
  for (var bar = 0; bar < 2; bar++) {
    for (var i = 0; i < melody.length; i++) {
      parts.add(tone(note(melody[i]), .9, vol: .16, decay: 2.5));
      offs.add(bar * 8 + i * .5);
    }
    for (var i = 0; i < bass.length; i++) {
      parts.add(tone(note(bass[i]), 2.0, vol: .14, decay: 1.2));
      offs.add(bar * 8 + i * 2.0);
    }
  }
  final music = mix(parts, offs).sublist(0, 16 * rate);
  writeWav('assets/audio/music.wav', music);
  stdout.writeln('Audio written to assets/audio');
}
