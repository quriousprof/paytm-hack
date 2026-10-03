import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import 'cart_sheet.dart';
import 'payment_method_screen.dart';
import 'pos_home_screen.dart';
import 'receipt_screen.dart';

const _kBlue = Color(0xFF002970);

class PaymentProcessingScreen extends StatefulWidget {
  final double amount;
  final PaymentMethod method;
  final List<CartItem>? items;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.method,
    this.items,
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
  late final String _txnId;
  late final DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    _txnId = 'PAY${DateTime.now().millisecondsSinceEpoch % 1000000}';
    _timestamp = DateTime.now();

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

  void _openReceipt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          items: widget.items,
          total: widget.amount,
          method: widget.method,
          txnId: _txnId,
          timestamp: _timestamp,
        ),
      ),
    );
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
    if (widget.method == PaymentMethod.qr) {
      return _buildQrWaiting(context);
    }
    final cfg = _methodConfig(widget.method);
    return Column(
      children: [
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

  Widget _buildQrWaiting(BuildContext context) {
    final upiUrl =
        'upi://pay?pa=shreeram@paytm&pn=Shree+Ram+Kirana+Store&am=${widget.amount.toStringAsFixed(2)}&cu=INR&tn=Payment';
    return Column(
      children: [
        Container(
          color: _kBlue,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              const Text(
                'Scan & Pay',
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Scan to Pay',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Use any UPI app to complete payment',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: upiUrl,
                    version: QrVersions.auto,
                    size: 200,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _kBlue,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.grey[400]!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Waiting for payment…',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final bool isUdhaar = widget.method == PaymentMethod.udhaar;
    final Color accentColor =
        isUdhaar ? const Color(0xFF3949AB) : const Color(0xFF00897B);
    final String title =
        isUdhaar ? 'Postpaid Request Sent!' : 'Payment Successful!';
    final String subtitle = isUdhaar
        ? '₹ ${widget.amount.toStringAsFixed(2)} received via Paytm Postpaid'
        : 'Transaction completed';
    final String statusLabel = isUdhaar ? 'Approved' : 'Success';

    return Column(
      children: [
        Container(
          color: _kBlue,
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            isUdhaar ? 'Postpaid Request' : 'Payment Complete',
            style: const TextStyle(
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                  child: Icon(
                    isUdhaar ? Icons.credit_score : Icons.check,
                    color: Colors.white,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: isUdhaar ? accentColor : const Color(0xFF888888),
                    fontSize: 14,
                    fontWeight: isUdhaar
                        ? FontWeight.w600
                        : FontWeight.normal),
              ),
              if (isUdhaar) ...[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 48),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF3949AB).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Amount added to customer\'s Paytm Postpaid bill',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xFF3949AB),
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
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
                    _summaryRow('Amount',
                        '₹ ${widget.amount.toStringAsFixed(2)}',
                        isAmount: true),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),
                    _summaryRow('Method', _methodLabel(widget.method)),
                    const SizedBox(height: 8),
                    _summaryRow('Status', statusLabel,
                        valueColor: accentColor),
                    const SizedBox(height: 8),
                    _summaryRow('Txn ID', _txnId),
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
                child: OutlinedButton.icon(
                  onPressed: _openReceipt,
                  icon: const Icon(Icons.receipt_long_outlined,
                      size: 18, color: _kBlue),
                  label: const Text(
                    'Print Receipt',
                    style: TextStyle(
                        color: _kBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _kBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value,
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
      case PaymentMethod.udhaar:
        return 'Paytm Postpaid';
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
      case PaymentMethod.udhaar:
        return _MethodConfig(
          icon: Icons.credit_score,
          color: const Color(0xFF3949AB),
          waitingText: 'Sending Postpaid Request',
          waitingSubtext:
              'Charging ₹${widget.amount.toStringAsFixed(2)} to\ncustomer\'s Paytm Postpaid account',
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
