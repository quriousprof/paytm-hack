import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../config.dart';
import '../services/voice_cart_service.dart';

enum _VoiceState { listening, processing, done, error }

class VoiceListeningSheet extends StatefulWidget {
  final void Function(List<VoiceCartItem> items) onItemsConfirmed;

  const VoiceListeningSheet({super.key, required this.onItemsConfirmed});

  @override
  State<VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<VoiceListeningSheet>
    with TickerProviderStateMixin {
  final _service = VoiceCartService();

  late final AnimationController _wavePhaseController;
  Timer? _ampTimer;
  double _normalizedAmp = 0.1; // 0.0 – 1.0, live mic level

  _VoiceState _state = _VoiceState.listening;
  String _transcript = '';
  List<VoiceCartItem> _items = [];
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();

    // Drives sine-wave phase across the bars (full cycle every 700 ms)
    _wavePhaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();

    _startSession();
  }

  Future<void> _startSession() async {
    await _service.startRecording();
    // Poll mic amplitude every 80 ms to animate the waveform
    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      if (_state != _VoiceState.listening) return;
      final db = await _service.getAmplitudeDb();
      // dB range: -60 (silence) → 0 (max). Normalize to 0–1.
      final norm = ((db + 60) / 60).clamp(0.0, 1.0);
      if (mounted) setState(() => _normalizedAmp = norm);
    });
  }

  Future<void> _stopAndProcess() async {
    _ampTimer?.cancel();
    setState(() => _state = _VoiceState.processing);
    try {
      final result = await _service.stopAndSend();
      if (mounted) {
        setState(() {
          _transcript = result.transcript;
          _items = result.items;
          _state = _VoiceState.done;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceFirst('Exception: ', '');
          _state = _VoiceState.error;
        });
      }
    }
  }

  void _cancel() {
    _ampTimer?.cancel();
    if (_state == _VoiceState.listening) _service.cancel();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _ampTimer?.cancel();
    _wavePhaseController.dispose();
    _service.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 14, 24, 28 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(),
          const SizedBox(height: 20),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _dragHandle() => Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildBody() {
    switch (_state) {
      case _VoiceState.listening:
        return _buildListening();
      case _VoiceState.processing:
        return _buildProcessing();
      case _VoiceState.done:
        return _buildDone();
      case _VoiceState.error:
        return _buildError();
    }
  }

  // ── Listening ─────────────────────────────────────────────────────────────

  Widget _buildListening() {
    return Column(
      children: [
        const Text(
          'Listening…',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Try: "ek kilo pyaaz aur do kilo tamatar"',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        const SizedBox(height: 36),
        // Live waveform
        _LiveWaveform(
          phaseAnimation: _wavePhaseController,
          amplitude: _normalizedAmp,
        ),
        const SizedBox(height: 40),
        // Red stop button
        GestureDetector(
          onTap: _stopAndProcess,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withValues(alpha: 0.35),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(Icons.stop_rounded, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tap to stop',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cancel,
          child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
        ),
      ],
    );
  }

  // ── Processing ────────────────────────────────────────────────────────────

  Widget _buildProcessing() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircularProgressIndicator(color: kBlue, strokeWidth: 2.5),
          SizedBox(height: 24),
          Text(
            'Processing…',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Transcribing speech and parsing items',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── Done ──────────────────────────────────────────────────────────────────

  Widget _buildDone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transcript bubble
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.record_voice_over_outlined,
                  size: 16, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '"$_transcript"',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_items.isEmpty) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 44, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text('No items recognised',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              ),
            ),
          ),
          _cancelButton(),
        ] else ...[
          Text(
            '${_items.length} ${_items.length == 1 ? 'item' : 'items'} found',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map(_itemRow),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onItemsConfirmed(_items);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                'Add ${_items.length} ${_items.length == 1 ? 'item' : 'items'} to Cart',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _cancelButton(),
        ],
      ],
    );
  }

  Widget _itemRow(VoiceCartItem item) {
    final qtyStr = item.qty % 1 == 0
        ? item.qty.toInt().toString()
        : item.qty.toString();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check, size: 16, color: kBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
            ),
          ),
          Text(
            '$qtyStr ${item.unit}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
          const SizedBox(height: 12),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMsg,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          _cancelButton(),
        ],
      ),
    );
  }

  Widget _cancelButton() => Center(
        child: TextButton(
          onPressed: _cancel,
          child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
        ),
      );
}

// ── Live Waveform ─────────────────────────────────────────────────────────────
// 9 bars whose heights are modulated by a sine wave (phase from animation)
// and scaled by the real microphone amplitude.

class _LiveWaveform extends StatelessWidget {
  final Animation<double> phaseAnimation;
  final double amplitude; // 0.0 – 1.0

  const _LiveWaveform({
    required this.phaseAnimation,
    required this.amplitude,
  });

  static const _bars = 9;
  static const _minH = 8.0;
  static const _maxH = 60.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _maxH + 4,
      child: AnimatedBuilder(
        animation: phaseAnimation,
        builder: (context, _) {
          final t = phaseAnimation.value * 2 * pi;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(_bars, (i) {
              final phase = (i / _bars) * 2 * pi;
              // Sine value 0..1 drives the shape of the wave
              final sine = (0.5 + 0.5 * sin(t + phase));
              // Scale the wave by real amplitude; floor at 15 % so bars never vanish
              final scale = 0.15 + 0.85 * amplitude;
              final height = _minH + (_maxH - _minH) * sine * scale;
              final opacity = 0.35 + 0.65 * sine * scale;
              return Container(
                width: 6,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                decoration: BoxDecoration(
                  color: kBlue.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
