import 'package:flutter/material.dart';
import 'payment_processing_screen.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double amount;

  const PaymentMethodScreen({super.key, required this.amount});

  static const _bgDark = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF1A1A2E);

  void _selectMethod(BuildContext context, PaymentMethod method) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(
          amount: amount,
          method: method,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildAmountBanner(),
            const SizedBox(height: 24),
            Expanded(child: _buildMethods(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Choose Payment Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002970), Color(0xFF1A56DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Collect',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildMethods(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            'SELECT METHOD',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _methodTile(
            context,
            method: PaymentMethod.qr,
            icon: Icons.qr_code_2,
            title: 'QR Code',
            subtitle: 'Show QR — customer scans & pays',
            color: const Color(0xFF00897B),
            badge: 'POPULAR',
          ),
          const SizedBox(height: 14),
          _methodTile(
            context,
            method: PaymentMethod.tap,
            icon: Icons.contactless,
            title: 'Tap to Pay (NFC)',
            subtitle: 'Tap card or phone to terminal',
            color: const Color(0xFF1A56DB),
          ),
          const SizedBox(height: 14),
          _methodTile(
            context,
            method: PaymentMethod.swipe,
            icon: Icons.credit_card,
            title: 'Swipe / Insert Card',
            subtitle: 'Debit or credit card via terminal',
            color: const Color(0xFF7B1FA2),
          ),
          const SizedBox(height: 14),
          _methodTile(
            context,
            method: PaymentMethod.cash,
            icon: Icons.currency_rupee,
            title: 'Cash',
            subtitle: 'Record a cash transaction',
            color: const Color(0xFFEF6C00),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(
    BuildContext context, {
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () => _selectMethod(context, method),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFF00897B),
                                width: 0.5),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF00897B),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod { qr, tap, swipe, cash }
