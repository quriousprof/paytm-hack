import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../config.dart';
import '../services/voice_cart_service.dart';

// ── Preview model ─────────────────────────────────────────────────────────────
// Returned by the resolveItems callback so the sheet can render catalog-matched
// items in the same style as the inventory / cart sheet.

class VoiceCartPreviewItem {
  final String name;
  final String emoji;
  final Color bgColor;
  final double pricePerUnit; // product's base price per unit
  final double qty; // from voice command
  final String unit; // product's catalog unit string, e.g. "1 kg"
  final bool found; // false ↔ no catalog match

  const VoiceCartPreviewItem({
    required this.name,
    required this.emoji,
    required this.bgColor,
    required this.pricePerUnit,
    required this.qty,
    required this.unit,
    required this.found,
  });

  double get subtotal => pricePerUnit * qty;
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

enum _VoiceState { listening, processing, done, error }

class VoiceListeningSheet extends StatefulWidget {
  final void Function(List<VoiceCartItem> items) onItemsConfirmed;

  /// Resolves raw VoiceCartItems → VoiceCartPreviewItems by fuzzy-matching
  /// against the product catalog. Provided by KiranaStoreScreen.
  final List<VoiceCartPreviewItem> Function(List<VoiceCartItem>) resolveItems;

  const VoiceListeningSheet({
    super.key,
    required this.onItemsConfirmed,
    required this.resolveItems,
  });

  @override
  State<VoiceListeningSheet> createState() => _VoiceListeningSheetState();
}

class _VoiceListeningSheetState extends State<VoiceListeningSheet>
    with TickerProviderStateMixin {
  final _service = VoiceCartService();

  late final AnimationController _wavePhaseController;
  Timer? _ampTimer;
  double _normalizedAmp = 0.1;

  _VoiceState _state = _VoiceState.listening;
  String _transcript = '';
  List<VoiceCartItem> _rawItems = [];
  List<VoiceCartPreviewItem> _preview = [];
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _wavePhaseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat();
    _startSession();
  }

  Future<void> _startSession() async {
    await _service.startRecording();
    _ampTimer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
      if (_state != _VoiceState.listening) return;
      final db = await _service.getAmplitudeDb();
      final norm = ((db + 60) / 60).clamp(0.0, 1.0);
      if (mounted) setState(() => _normalizedAmp = norm);
    });
  }

  Future<void> _stopAndProcess() async {
    _ampTimer?.cancel();
    setState(() => _state = _VoiceState.processing);
    try {
      final result = await _service.stopAndSend();
      final preview = widget.resolveItems(result.items);
      if (mounted) {
        setState(() {
          _transcript = result.transcript;
          _rawItems = result.items;
          _preview = preview;
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

  Future<void> _tryAgain() async {
    setState(() {
      _state = _VoiceState.listening;
      _transcript = '';
      _rawItems = [];
      _preview = [];
      _normalizedAmp = 0.1;
    });
    _wavePhaseController.repeat();
    await _startSession();
  }

  @override
  void dispose() {
    _ampTimer?.cancel();
    _wavePhaseController.dispose();
    _service.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 14),
          _dragHandle(),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildBody(),
            ),
          ),
          const SizedBox(height: 8),
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

  // ── Listening ──────────────────────────────────────────────────────────────

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
        _LiveWaveform(
          phaseAnimation: _wavePhaseController,
          amplitude: _normalizedAmp,
        ),
        const SizedBox(height: 40),
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
            child:
                const Icon(Icons.stop_rounded, color: Colors.white, size: 34),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Tap to stop',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _cancel,
          child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Processing ─────────────────────────────────────────────────────────────

  Widget _buildProcessing() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
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

  // ── Done ───────────────────────────────────────────────────────────────────

  Widget _buildDone() {
    final matched = _preview.where((p) => p.found).toList();
    final unmatched = _preview.where((p) => !p.found).toList();
    final total = matched.fold(0.0, (s, p) => s + p.subtotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transcript bubble
        _transcriptBubble(),
        const SizedBox(height: 20),

        if (_preview.isEmpty || matched.isEmpty) ...[
          _parseFailedState(),
          const SizedBox(height: 20),
          _tryAgainButton(),
          const SizedBox(height: 8),
          _cancelButton(),
        ] else ...[
          // Header count
          _sectionLabel(
            '${matched.length} ${matched.length == 1 ? 'item' : 'items'} found'
            '${unmatched.isNotEmpty ? '  ·  ${unmatched.length} not in catalog' : ''}',
          ),
          const SizedBox(height: 10),

          // Matched items — cart-sheet row style
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFEEEEEE)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                for (int i = 0; i < matched.length; i++) ...[
                  _matchedRow(matched[i]),
                  if (i < matched.length - 1)
                    const Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFF5F5F5)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _billSummary(matched.length, total),

          // Unmatched items — dimmed
          if (unmatched.isNotEmpty) ...[
            const SizedBox(height: 12),
            _sectionLabel('Not in catalog'),
            const SizedBox(height: 8),
            ...unmatched.map(_unmatchedRow),
          ],

          const SizedBox(height: 20),
          _addToCartButton(matched.length, total),
          const SizedBox(height: 8),
          _cancelButton(),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _transcriptBubble() => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.record_voice_over_outlined,
                size: 15, color: Colors.grey[400]),
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
      );

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.2,
        ),
      );

  // Mirrors CartSheet._buildItemRow exactly
  Widget _matchedRow(VoiceCartPreviewItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji,
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.qty.toInt()} × ${item.unit}  ·  ₹${item.pricePerUnit.toInt()} each',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            '₹${item.subtotal.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _unmatchedRow(VoiceCartPreviewItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.help_outline,
                size: 20, color: Colors.grey[400]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${item.name}"',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  'Not found — add manually',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _billSummary(int count, double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Text(
            'Total  ($count ${count == 1 ? 'item' : 'items'})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          const Spacer(),
          Text(
            '₹${total.toInt()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addToCartButton(int count, double total) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onItemsConfirmed(_rawItems);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add $count ${count == 1 ? 'item' : 'items'} to Cart',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '₹${total.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _parseFailedState() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(Icons.mic_off_rounded, size: 44, color: Colors.grey[300]),
              const SizedBox(height: 12),
              const Text(
                'Could not parse your list',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'None of the items matched our catalog.\nPlease try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
              ),
            ],
          ),
        ),
      );

  Widget _tryAgainButton() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _tryAgain,
          icon: const Icon(Icons.mic, color: Colors.white, size: 18),
          label: const Text(
            'Try Again',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      );

  Widget _cancelButton() => Center(
        child: TextButton(
          onPressed: _cancel,
          child: Text('Cancel',
              style: TextStyle(color: Colors.grey[500])),
        ),
      );

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: Colors.red[300]),
          const SizedBox(height: 12),
          const Text('Something went wrong',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
}

// ── Live Waveform ─────────────────────────────────────────────────────────────

class _LiveWaveform extends StatelessWidget {
  final Animation<double> phaseAnimation;
  final double amplitude;

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
              final sine = (0.5 + 0.5 * sin(t + phase));
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
