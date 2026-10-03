import 'package:flutter/material.dart';
import 'dart:async';
import 'payment_method_screen.dart';
import 'pos_home_screen.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final double amount;
  final PaymentMethod method;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with TickerProviderStateMixin {
  _ProcessState _state = _ProcessState.waiting;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScale;
  Timer? _simulationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );

    _startSimulation();
  }

  void _startSimulation() {
    // Simulate payment processing → success after 3s
    _simulationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _state = _ProcessState.success);
        _pulseController.stop();
        _successController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _successController.dispose();
    _simulationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: _state == _ProcessState.waiting
            ? _buildWaiting()
            : _buildSuccess(context),
      ),
    );
  }

  Widget _buildWaiting() {
    final config = _methodConfig(widget.method);
    return Column(
      children: [
        // Header
        Container(
          color: const Color(0xFF1A1A2E),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Text(
                config.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: config.color.withValues(alpha: 0.15),
                    border: Border.all(
                        color: config.color.withValues(alpha: 0.5), width: 2),
                  ),
                  child: Icon(config.icon, color: config.color, size: 52),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                config.waitingText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                config.waitingSubtext,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              // Amount chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: config.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '₹ ${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(config.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _successScale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00897B),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 60),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction completed',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
              ),
              const SizedBox(height: 36),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _receiptRow('Amount', '₹ ${widget.amount.toStringAsFixed(2)}',
                        isAmount: true),
                    const Divider(color: Colors.white12, height: 24),
                    _receiptRow('Method', _methodLabel(widget.method)),
                    const SizedBox(height: 8),
                    _receiptRow('Status', 'Success',
                        valueColor: const Color(0xFF00897B)),
                    const SizedBox(height: 8),
                    _receiptRow('Txn ID',
                        'PAY${DateTime.now().millisecondsSinceEpoch % 1000000}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const PosHomeScreen()),
                      (_) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A56DB),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'New Transaction',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    'Print Receipt',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _receiptRow(String label, String value,
      {bool isAmount = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: isAmount ? 18 : 13,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _methodLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.qr:
        return 'QR Code';
      case PaymentMethod.tap:
        return 'Tap to Pay';
      case PaymentMethod.swipe:
        return 'Card Swipe';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  _MethodConfig _methodConfig(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.qr:
        return _MethodConfig(
          icon: Icons.qr_code_2,
          color: const Color(0xFF00897B),
          title: 'QR Payment',
          waitingText: 'Waiting for Customer',
          waitingSubtext: 'Show this terminal to the customer\nto scan the QR code',
        );
      case PaymentMethod.tap:
        return _MethodConfig(
          icon: Icons.contactless,
          color: const Color(0xFF1A56DB),
          title: 'Tap to Pay',
          waitingText: 'Tap Card or Device',
          waitingSubtext: 'Hold card or phone near\nthe terminal reader',
        );
      case PaymentMethod.swipe:
        return _MethodConfig(
          icon: Icons.credit_card,
          color: const Color(0xFF7B1FA2),
          title: 'Card Payment',
          waitingText: 'Insert or Swipe Card',
          waitingSubtext: 'Insert chip card or swipe\nthrough the card reader',
        );
      case PaymentMethod.cash:
        return _MethodConfig(
          icon: Icons.currency_rupee,
          color: const Color(0xFFEF6C00),
          title: 'Cash Payment',
          waitingText: 'Collecting Cash',
          waitingSubtext: 'Collect ₹${widget.amount.toStringAsFixed(2)}\nfrom the customer',
        );
    }
  }
}

class _MethodConfig {
  final IconData icon;
  final Color color;
  final String title;
  final String waitingText;
  final String waitingSubtext;

  const _MethodConfig({
    required this.icon,
    required this.color,
    required this.title,
    required this.waitingText,
    required this.waitingSubtext,
  });
}

enum _ProcessState { waiting, success }
