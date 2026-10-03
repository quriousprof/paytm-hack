import 'package:flutter/material.dart';
import 'dart:async';
import 'payment_method_screen.dart';
import 'pos_home_screen.dart';

const _kBlue = Color(0xFF002970);

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
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _successScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
          parent: _successController, curve: Curves.elasticOut),
    );

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
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: _state == _ProcessState.waiting
            ? _buildWaiting(context)
            : _buildSuccess(context),
      ),
    );
  }

  Widget _buildWaiting(BuildContext context) {
    final cfg = _methodConfig(widget.method);
    return Column(
      children: [
        // Header
        Container(
          color: _kBlue,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text(
                'Processing Payment',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cfg.color.withValues(alpha: 0.1),
                    border: Border.all(
                        color: cfg.color.withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: Icon(cfg.icon, color: cfg.color, size: 48),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                cfg.waitingText,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                cfg.waitingSubtext,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFF888888), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '₹ ${widget.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _kBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(cfg.color),
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
        Container(
          color: _kBlue,
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: const Text(
            'Payment Complete',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _successScale,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF00897B),
                  ),
                  child: const Icon(Icons.check,
                      color: Colors.white, size: 56),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Transaction completed',
                style: TextStyle(color: Color(0xFF888888), fontSize: 14),
              ),
              const SizedBox(height: 32),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _receiptRow('Amount',
                        '₹ ${widget.amount.toStringAsFixed(2)}',
                        isAmount: true),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _receiptRow('Method', _methodLabel(widget.method)),
                    const SizedBox(height: 8),
                    _receiptRow('Status', 'Success',
                        valueColor: const Color(0xFF00897B)),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Txn ID',
                      'PAY${DateTime.now().millisecondsSinceEpoch % 1000000}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const PosHomeScreen()),
                    (_) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
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
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Print Receipt',
                    style: TextStyle(
                        color: Color(0xFF555555), fontSize: 15),
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
            style: const TextStyle(
                color: Color(0xFF888888), fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1A1A1A),
            fontSize: isAmount ? 17 : 13,
            fontWeight:
                isAmount ? FontWeight.bold : FontWeight.w500,
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
          waitingText: 'Waiting for Customer',
          waitingSubtext:
              'Show the QR code to the customer\nto complete payment',
        );
      case PaymentMethod.tap:
        return _MethodConfig(
          icon: Icons.contactless,
          color: _kBlue,
          waitingText: 'Tap Card or Device',
          waitingSubtext:
              'Hold card or phone near\nthe terminal reader',
        );
      case PaymentMethod.swipe:
        return _MethodConfig(
          icon: Icons.credit_card,
          color: const Color(0xFF7B1FA2),
          waitingText: 'Insert or Swipe Card',
          waitingSubtext:
              'Insert chip card or swipe\nthrough the card reader',
        );
      case PaymentMethod.cash:
        return _MethodConfig(
          icon: Icons.currency_rupee,
          color: const Color(0xFFEF6C00),
          waitingText: 'Collecting Cash',
          waitingSubtext:
              'Collect ₹${widget.amount.toStringAsFixed(2)}\nfrom the customer',
        );
    }
  }
}

class _MethodConfig {
  final IconData icon;
  final Color color;
  final String waitingText;
  final String waitingSubtext;

  const _MethodConfig({
    required this.icon,
    required this.color,
    required this.waitingText,
    required this.waitingSubtext,
  });
}

enum _ProcessState { waiting, success }
