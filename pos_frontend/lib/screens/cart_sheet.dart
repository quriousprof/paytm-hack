import 'package:flutter/material.dart';

const _kBlue = Color(0xFF002970);

class CartItem {
  final String name;
  final String emoji;
  final double price;
  final int qty;

  const CartItem({
    required this.name,
    required this.emoji,
    required this.price,
    required this.qty,
  });

  double get subtotal => price * qty;
}

class CartSheet extends StatelessWidget {
  final List<CartItem> items;
  final VoidCallback onMoveToPOS;

  const CartSheet({
    super.key,
    required this.items,
    required this.onMoveToPOS,
  });

  double get _itemTotal =>
      items.fold(0.0, (sum, i) => sum + i.subtotal);
  static const _handlingFee = 5.0;
  double get _grandTotal => _itemTotal + _handlingFee;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Flexible(child: _buildItemList()),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          _buildBillSummary(),
          _buildMoveToPos(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Row(
        children: [
          const Text(
            '🛒',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 10),
          const Text(
            'Your Cart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${items.length} ${items.length == 1 ? 'item' : 'items'}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: items.length,
      separatorBuilder: (context, i) =>
          const Divider(height: 1, indent: 20, endIndent: 20,
              color: Color(0xFFF5F5F5)),
      itemBuilder: (_, i) => _buildItemRow(items[i]),
    );
  }

  Widget _buildItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Emoji tile
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(item.emoji,
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          // Name + qty breakdown
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
                  '${item.qty} × ₹${item.price.toInt()}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Subtotal
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

  Widget _buildBillSummary() {
    return Container(
      color: const Color(0xFFFAFAFA),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF555555),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          _billRow('Item Total', '₹${_itemTotal.toInt()}'),
          const SizedBox(height: 6),
          _billRow('Handling Fee', '₹${_handlingFee.toInt()}',
              valueColor: Colors.grey[600]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _billRow(
            'Total',
            '₹${_grandTotal.toInt()}',
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            valueStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _kBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _billRow(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ??
              const TextStyle(
                  fontSize: 13, color: Color(0xFF666666)),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF1A1A1A),
              ),
        ),
      ],
    );
  }

  Widget _buildMoveToPos(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onMoveToPOS,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Move to POS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '₹${_grandTotal.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
