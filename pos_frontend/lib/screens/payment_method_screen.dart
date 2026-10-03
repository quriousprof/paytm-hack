import 'package:flutter/material.dart';
import 'cart_sheet.dart';
import 'payment_processing_screen.dart';

const _kBlue = Color(0xFF002970);

class PaymentMethodScreen extends StatelessWidget {
  final double amount;
  final List<CartItem>? items;

  const PaymentMethodScreen({
    super.key,
    required this.amount,
    this.items,
  });

  void _selectMethod(BuildContext context, PaymentMethod method) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentProcessingScreen(
          amount: amount,
          method: method,
          items: items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: _kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Payment Method',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildAmountBanner(),
          const SizedBox(height: 8),
          Expanded(child: _buildMethods(context)),
        ],
      ),
    );
  }

  Widget _buildAmountBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002970), Color(0xFF1A56DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount to Collect',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '₹ ${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.receipt_long,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildMethods(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _methodTile(
          context,
          method: PaymentMethod.qr,
          icon: Icons.qr_code_2,
          title: 'QR Code',
          subtitle: 'Show QR — customer scans & pays',
          color: const Color(0xFF00897B),
          badge: 'POPULAR',
        ),
        const SizedBox(height: 12),
        _methodTile(
          context,
          method: PaymentMethod.tap,
          icon: Icons.contactless,
          title: 'Tap to Pay (NFC)',
          subtitle: 'Tap card or phone to terminal',
          color: _kBlue,
        ),
        const SizedBox(height: 12),
        _methodTile(
          context,
          method: PaymentMethod.swipe,
          icon: Icons.credit_card,
          title: 'Swipe / Insert Card',
          subtitle: 'Debit or credit card via terminal',
          color: const Color(0xFF7B1FA2),
        ),
        const SizedBox(height: 12),
        _methodTile(
          context,
          method: PaymentMethod.cash,
          icon: Icons.currency_rupee,
          title: 'Cash',
          subtitle: 'Record a cash transaction',
          color: const Color(0xFFEF6C00),
        ),
      ],
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B)
                                .withValues(alpha: 0.1),
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
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod { qr, tap, swipe, cash }
