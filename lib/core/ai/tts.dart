import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

class ElevenLabsTTS {
  final AudioPlayer _player = AudioPlayer();
  String apiKey;
  String voiceId;
  String modelId;

  Function()? _onComplete;
  bool _stoppedManually = false;

  ElevenLabsTTS({
    required this.apiKey,
    required this.voiceId,
    required this.modelId,
  }) {
    _player.onPlayerComplete.listen((_) {
      if (_stoppedManually) return;
      final cb = _onComplete;
      _onComplete = null;
      cb?.call();
    });
  }

  Future<void> speak(String text, {Function()? onComplete}) async {
    _stoppedManually = false;
    _onComplete = onComplete;

    try { await _player.stop(); } catch (_) {}

    final bytes = await _synthesize(text);
    if (bytes == null || bytes.isEmpty) {
      final cb = _onComplete;
      _onComplete = null;
      cb?.call();
      return;
    }

    await _player.play(BytesSource(bytes));
  }

  Future<void> stop() async {
    _stoppedManually = true;
    _onComplete = null;
    try { await _player.stop(); } catch (_) {}
  }

  Future<void> dispose() async {
    try { await _player.dispose(); } catch (_) {}
  }

  Future<Uint8List?> _synthesize(String text) async {
    final url = Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId');
    final body = jsonEncode({
      "text": text,
      "model_id": modelId,
      "voice_settings": {
        "stability": 0.25,
        "similarity_boost": 0.55,
        "style": 0.0,
        "use_speaker_boost": true
      },
    });

    final res = await http.post(
      url,
      headers: {
        "xi-api-key": apiKey,
        "accept": "audio/mpeg",
        "content-type": "application/json",
      },
      body: body,
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return res.bodyBytes;
    }
    return null;
  }
}