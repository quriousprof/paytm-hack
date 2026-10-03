import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../config.dart';

class VoiceCartItem {
  final String name;
  final double qty;
  final String unit;

  const VoiceCartItem({
    required this.name,
    required this.qty,
    required this.unit,
  });
}

class VoiceCartResult {
  final String transcript;
  final List<VoiceCartItem> items;

  const VoiceCartResult({required this.transcript, required this.items});
}

class VoiceCartService {
  final _recorder = AudioRecorder();
  String? _tempPath;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<void> startRecording() async {
    final dir = await getTemporaryDirectory();
    _tempPath =
        '${dir.path}/voice_cart_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _tempPath!,
    );
  }

  /// Returns dB amplitude (current), or -60 if unavailable.
  Future<double> getAmplitudeDb() async {
    try {
      final amp = await _recorder.getAmplitude();
      return amp.current;
    } catch (_) {
      return -60;
    }
  }

  Future<VoiceCartResult> stopAndSend() async {
    await _recorder.stop();

    final path = _tempPath;
    if (path == null) throw Exception('No active recording');

    final file = File(path);
    if (!await file.exists()) throw Exception('Recording file missing');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$kBackendBaseUrl/voice-cart'),
    );
    request.files.add(await http.MultipartFile.fromPath('audio', path));

    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();

    try { await file.delete(); } catch (_) {}
    _tempPath = null;

    if (streamed.statusCode != 200) {
      throw Exception('Server error ${streamed.statusCode}: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final transcript = json['transcript'] as String;
    final items = (json['items'] as List)
        .map((i) => VoiceCartItem(
              name: i['name'] as String,
              qty: (i['qty'] as num).toDouble(),
              unit: i['unit'] as String,
            ))
        .toList();

    return VoiceCartResult(transcript: transcript, items: items);
  }

  void cancel() {
    _recorder.cancel().catchError((Object _) => null);
    if (_tempPath != null) {
      try { File(_tempPath!).delete(); } catch (_) {}
      _tempPath = null;
    }
  }

  Future<void> dispose() => _recorder.dispose();
}
