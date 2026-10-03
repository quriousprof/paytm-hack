import 'dart:math';
import 'package:flutter/material.dart';
import 'cart_sheet.dart';
import 'payment_method_screen.dart';

const _kBlue = Color(0xFF002970);

// ── Store info ─────────────────────────────────────────────────────────────

const _storeName = 'Shree Ram Kirana Store';
const _storeTagline = 'Fresh • Local • Trusted';
const _storeAddress = '14, SV Road, Andheri West';
const _storeCity = 'Mumbai – 400 058';
const _storePhone = '+91 98765 43210';
const _storeGST = 'GSTIN: 29AABCU9603R1ZX';

class ReceiptScreen extends StatelessWidget {
  final List<CartItem>? items;
  final double total;
  final PaymentMethod method;
  final String txnId;
  final DateTime timestamp;

  const ReceiptScreen({
    super.key,
    required this.items,
    required this.total,
    required this.method,
    required this.txnId,
    required this.timestamp,
  });

  String get _methodLabel {
    switch (method) {
      case PaymentMethod.qr:
        return 'UPI / QR';
      case PaymentMethod.tap:
        return 'Tap to Pay (NFC)';
      case PaymentMethod.swipe:
        return 'Card Swipe';
      case PaymentMethod.cash:
        return 'Cash';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        backgroundColor: _kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          children: [
            _buildReceiptCard(context),
            const SizedBox(height: 24),
            _buildDoneButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStoreHeader(),
          _buildDashedDivider(),
          _buildMetaSection(),
          _buildDashedDivider(),
          _buildItemsSection(),
          _buildDashedDivider(),
          _buildTotalsSection(),
          _buildDashedDivider(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── Store header ───────────────────────────────────────────────────────────

  Widget _buildStoreHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          const Text(
            _storeName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            _storeTagline,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _storeAddress,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
          Text(
            _storeCity,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 4),
          Text(
            'Ph: $_storePhone',
            style: const TextStyle(fontSize: 12, color: Color(0xFF555555)),
          ),
          const SizedBox(height: 4),
          Text(
            _storeGST,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Meta (date / txn) ─────────────────────────────────────────────────────

  Widget _buildMetaSection() {
    final date =
        '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    final time =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          _metaRow('Date', date),
          const SizedBox(height: 6),
          _metaRow('Time', time),
          const SizedBox(height: 6),
          _metaRow('Txn ID', txnId),
          const SizedBox(height: 6),
          _metaRow('Payment', _methodLabel),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF888888))),
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333))),
      ],
    );
  }

  // ── Items ─────────────────────────────────────────────────────────────────

  Widget _buildItemsSection() {
    final lineItems = items != null && items!.isNotEmpty
        ? items!
        : [
            CartItem(
              name: 'Custom Charge',
              emoji: '',
              unit: 'item',
              price: total,
              qty: 1,
            ),
          ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: const [
              Expanded(
                flex: 4,
                child: Text('ITEM',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                        letterSpacing: 0.5)),
              ),
              SizedBox(
                width: 56,
                child: Text('QTY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                        letterSpacing: 0.5)),
              ),
              SizedBox(
                width: 64,
                child: Text('AMOUNT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF888888),
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...lineItems.map((item) => _itemRow(item)),
        ],
      ),
    );
  }

  Widget _itemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  '${item.unit}  ×  ₹${item.price.toInt()}',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFFAAAAAA)),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${item.qty}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF444444)),
            ),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '₹${item.subtotal.toInt()}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Totals ────────────────────────────────────────────────────────────────

  Widget _buildTotalsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Column(
        children: [
          if (items != null && items!.isNotEmpty) ...[
            _totalRow('Subtotal',
                '₹${items!.fold(0.0, (s, i) => s + i.subtotal).toInt()}'),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 10),
          ],
          _totalRow(
            'TOTAL',
            '₹${total.toInt()}',
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            valueStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _kBlue,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle,
                    size: 14, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  'Paid via $_methodLabel',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value,
      {TextStyle? labelStyle,
      TextStyle? valueStyle,
      Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: labelStyle ??
                const TextStyle(
                    fontSize: 13, color: Color(0xFF666666))),
        Text(value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1A1A1A),
                )),
      ],
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          const Text(
            'Thank you for shopping with us!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Color(0xFF555555),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit again!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.power, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Powered by Paytm POS',
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildDashedDivider() {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          // Pop back to the POS home
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _kBlue,
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
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(min(x + 6, size.width), 0), paint);
      x += 10;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
