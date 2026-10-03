import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

const _kGold1 = Color(0xFFB45309);
const _kGold2 = Color(0xFFD97706);
const _kGold3 = Color(0xFFFBBF24);
const _kGoldPricePerGram = 15351.96;

enum _Stage { processing, success }

class GoldInvestmentScreen extends StatefulWidget {
  final double amount;

  const GoldInvestmentScreen({super.key, required this.amount});

  @override
  State<GoldInvestmentScreen> createState() => _GoldInvestmentScreenState();
}

class _GoldInvestmentScreenState extends State<GoldInvestmentScreen>
    with TickerProviderStateMixin {
  _Stage _stage = _Stage.processing;

  late final AnimationController _spinController;
  late final AnimationController _pulseController;
  late final AnimationController _successController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.easeIn,
    );

    // Auto-advance to success after 2.4 s
    Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _stage = _Stage.success);
      _spinController.stop();
      _pulseController.stop();
      _successController.forward();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    super.dispose();
  }

  double get _goldGrams => widget.amount / _kGoldPricePerGram;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _stage == _Stage.success,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFBEB),
        body: SafeArea(
          child: _stage == _Stage.processing
              ? _buildProcessing()
              : _buildSuccess(),
        ),
      ),
    );
  }

  // ── Processing ──────────────────────────────────────────────────────────────

  Widget _buildProcessing() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spinning ring with coin inside
            AnimatedBuilder(
              animation: _spinController,
              builder: (context, _) => Transform.rotate(
                angle: _spinController.value * 2 * pi,
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: CustomPaint(painter: _SpinRingPainter()),
                ),
              ),
            ),
            // Coin emoji pulsing inside
            Transform.translate(
              offset: const Offset(0, -75),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) => Transform.scale(
                  scale: 0.9 + 0.1 * _pulseController.value,
                  child: const Text('🥇',
                      style: TextStyle(fontSize: 42)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Investing from your account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kGold1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Please wait…',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: [
                  BoxShadow(
                    color: _kGold3.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _detailRow('Amount', '₹${widget.amount.toInt()}'),
                  const SizedBox(height: 8),
                  _detailRow('Gold', '${(_goldGrams * 1000).toStringAsFixed(2)} mg'),
                  const SizedBox(height: 8),
                  _detailRow('Source', 'Paytm Wallet / UPI'),
                  const SizedBox(height: 8),
                  _detailRow('Rate', '₹${_fmtExact(_kGoldPricePerGram)}/g'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success ─────────────────────────────────────────────────────────────────

  Widget _buildSuccess() {
    final newPortfolio = 9142.0 + widget.amount;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success ring + checkmark
            ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kGold1, _kGold2, _kGold3],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _kGold2.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 56),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Investment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${widget.amount.toInt()} invested in Paytm Gold',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
                boxShadow: [
                  BoxShadow(
                    color: _kGold3.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _successStat(
                    '🥇',
                    'Gold Added',
                    '${(_goldGrams * 1000).toStringAsFixed(2)} mg',
                    _kGold1,
                  ),
                  const Divider(height: 20, color: Color(0xFFF5F5F5)),
                  _successStat(
                    '💼',
                    'Portfolio Value',
                    '₹${newPortfolio.toStringAsFixed(0)}',
                    const Color(0xFF16A34A),
                  ),
                  const Divider(height: 20, color: Color(0xFFF5F5F5)),
                  _successStat(
                    '📈',
                    'Total Returns',
                    '+11.6%',
                    const Color(0xFF16A34A),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.autorenew,
                      size: 15, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Set a daily reminder to invest ₹${widget.amount.toInt()} every day and build your gold stack automatically.',
                      style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF166534),
                          height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == '/invest'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGold1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Widget _successStat(
      String emoji, String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }

  String _fmtExact(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final s = parts[0];
    return s.length > 3
        ? '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}.${parts[1]}'
        : '$s.${parts[1]}';
  }
}

// ── Spinning arc painter ──────────────────────────────────────────────────────

class _SpinRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - 6;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFFDE68A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      pi * 1.3,
      false,
      Paint()
        ..shader = const LinearGradient(
          colors: [_kGold1, _kGold3],
        ).createShader(Rect.fromCircle(
            center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
