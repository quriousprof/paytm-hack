import 'package:flutter/material.dart';

const _kOrange = Color(0xFFEF6C00);

// ── Data ──────────────────────────────────────────────────────────────────────

class _Product {
  final String id;
  final String emoji;
  final String name;
  final double price;
  final String unit;
  final Color bgColor;
  final String category;

  const _Product({
    required this.id,
    required this.emoji,
    required this.name,
    required this.price,
    required this.unit,
    required this.bgColor,
    required this.category,
  });
}

const _kProducts = [
  _Product(id: 'onion',   emoji: '🧅', name: 'Onions',        price: 30,  unit: 'kg',     bgColor: Color(0xFFFFF3E0), category: 'Vegetables'),
  _Product(id: 'tomato',  emoji: '🍅', name: 'Tomatoes',      price: 40,  unit: 'kg',     bgColor: Color(0xFFFFEBEE), category: 'Vegetables'),
  _Product(id: 'potato',  emoji: '🥔', name: 'Potatoes',      price: 30,  unit: 'kg',     bgColor: Color(0xFFFFF8E1), category: 'Vegetables'),
  _Product(id: 'milk',    emoji: '🥛', name: 'Milk',          price: 60,  unit: '1 L',    bgColor: Color(0xFFE3F2FD), category: 'Dairy'),
  _Product(id: 'curd',    emoji: '🍶', name: 'Curd',          price: 40,  unit: 'kg',     bgColor: Color(0xFFE0F2F1), category: 'Dairy'),
  _Product(id: 'egg',     emoji: '🥚', name: 'Eggs',          price: 72,  unit: 'dozen',  bgColor: Color(0xFFFFF8E1), category: 'Dairy'),
  _Product(id: 'bread',   emoji: '🍞', name: 'Brown Bread',   price: 45,  unit: 'pkt',    bgColor: Color(0xFFFFF3E0), category: 'Bakery'),
  _Product(id: 'rice',    emoji: '🍚', name: 'Basmati Rice',  price: 120, unit: 'kg',     bgColor: Color(0xFFF3E5F5), category: 'Grains'),
  _Product(id: 'dal',     emoji: '🫘', name: 'Yellow Dal',    price: 140, unit: 'kg',     bgColor: Color(0xFFFFF3E0), category: 'Grains'),
  _Product(id: 'flour',   emoji: '🌾', name: 'Wheat Flour',   price: 55,  unit: 'kg',     bgColor: Color(0xFFFFF8E1), category: 'Grains'),
  _Product(id: 'tea',     emoji: '🍵', name: 'Tata Tea',      price: 120, unit: 'pkt',    bgColor: Color(0xFFE8F5E9), category: 'Beverages'),
  _Product(id: 'water',   emoji: '💧', name: 'Bisleri Water', price: 20,  unit: 'bottle', bgColor: Color(0xFFE1F5FE), category: 'Beverages'),
];

const _kCategories = ['All', 'Vegetables', 'Dairy', 'Bakery', 'Grains', 'Beverages'];

// ── Screen ────────────────────────────────────────────────────────────────────

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String _selectedCategory = 'All';
  final Map<String, int> _cart = {};

  List<_Product> get _filtered => _selectedCategory == 'All'
      ? _kProducts
      : _kProducts.where((p) => p.category == _selectedCategory).toList();

  int get _cartCount => _cart.values.fold(0, (s, q) => s + q);
  double get _cartTotal => _cart.entries.fold(0, (s, e) {
        final p = _kProducts.firstWhere((p) => p.id == e.key);
        return s + p.price * e.value;
      });

  void _increment(String id) => setState(() => _cart[id] = (_cart[id] ?? 0) + 1);
  void _decrement(String id) => setState(() {
        if ((_cart[id] ?? 0) <= 1) {
          _cart.remove(id);
        } else {
          _cart[id] = _cart[id]! - 1;
        }
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(child: _buildCategoryBar()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, _cartCount > 0 ? 100 : 24),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildProductCard(_filtered[i]),
                    childCount: _filtered.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.82,
                  ),
                ),
              ),
            ],
          ),
          if (_cartCount > 0) _buildCartBar(),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: _kOrange,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEF6C00), Color(0xFFF57C00), Color(0xFFFF8F00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🛒', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Shree Ram Kirana Store',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '14, SV Road, Andheri West, Mumbai',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Open',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: Container(
          color: _kOrange,
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.yellow, size: 14),
              const SizedBox(width: 4),
              const Text('4.8',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Text('(243 ratings)',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11)),
              const Spacer(),
              const Icon(Icons.access_time, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text('10 min delivery',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
              const SizedBox(width: 16),
            ],
          ).wrapPadding(const EdgeInsets.fromLTRB(16, 6, 0, 10)),
        ),
      ),
    );
  }

  // ── Category bar ─────────────────────────────────────────────────────────────

  Widget _buildCategoryBar() {
    return Container(
      color: Colors.white,
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _kCategories.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _kCategories[i];
          final selected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _kOrange : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Product card ─────────────────────────────────────────────────────────────

  Widget _buildProductCard(_Product p) {
    final qty = _cart[p.id] ?? 0;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji tile
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: p.bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            alignment: Alignment.center,
            child: Text(p.emoji, style: const TextStyle(fontSize: 44)),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '1 ${p.unit}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Price + add button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                Text(
                  '₹${p.price.toInt()}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
                const Spacer(),
                qty == 0
                    ? _addButton(p.id)
                    : _qtyControl(p.id, qty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(String id) {
    return GestureDetector(
      onTap: () => _increment(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _kOrange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('ADD',
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _qtyControl(String id, int qty) {
    return Container(
      decoration: BoxDecoration(
        color: _kOrange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _decrement(id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Text('$qty',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => _increment(id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Cart bar ─────────────────────────────────────────────────────────────────

  Widget _buildCartBar() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => _showCartSheet(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _kOrange,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _kOrange.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_cartCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              const Text('View Cart',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                '₹${_cartTotal.toInt()}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Cart bottom sheet ────────────────────────────────────────────────────────

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CartSheet(
        cart: Map.from(_cart),
        onChanged: (id, delta) {
          if (delta > 0) {
            _increment(id);
          } else {
            _decrement(id);
          }
        },
        total: _cartTotal,
      ),
    );
  }
}

// ── Cart sheet ────────────────────────────────────────────────────────────────

class _CartSheet extends StatefulWidget {
  final Map<String, int> cart;
  final void Function(String id, int delta) onChanged;
  final double total;

  const _CartSheet({
    required this.cart,
    required this.onChanged,
    required this.total,
  });

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> {
  late final Map<String, int> _local;

  @override
  void initState() {
    super.initState();
    _local = Map.from(widget.cart);
  }

  double get _total => _local.entries.fold(0, (s, e) {
        final p = _kProducts.firstWhere((p) => p.id == e.key);
        return s + p.price * e.value;
      });

  void _change(String id, int delta) {
    setState(() {
      final next = (_local[id] ?? 0) + delta;
      if (next <= 0) {
        _local.remove(id);
      } else {
        _local[id] = next;
      }
    });
    widget.onChanged(id, delta);
  }

  @override
  Widget build(BuildContext context) {
    final items = _local.entries.map((e) {
      return (product: _kProducts.firstWhere((p) => p.id == e.key), qty: e.value);
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Your Cart',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_local.values.fold(0, (s, q) => s + q)} items',
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kOrange,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text('from Shree Ram Kirana',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[400])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Your cart is empty',
                  style: TextStyle(color: Colors.grey[400])),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                separatorBuilder: (context, _) =>
                    const Divider(height: 1, color: Color(0xFFF5F5F5)),
                itemBuilder: (context, i) {
                  final p = items[i].product;
                  final qty = items[i].qty;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: p.bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(p.emoji,
                              style: const TextStyle(fontSize: 20)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text('₹${p.price.toInt()} / ${p.unit}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[500])),
                            ],
                          ),
                        ),
                        // Qty control
                        Container(
                          decoration: BoxDecoration(
                            color: _kOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => _change(p.id, -1),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  child: Icon(Icons.remove,
                                      color: Colors.white, size: 13),
                                ),
                              ),
                              Text('$qty',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              GestureDetector(
                                onTap: () => _change(p.id, 1),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 52,
                          child: Text(
                            '₹${(p.price * qty).toInt()}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                Text('₹${_total.toInt()}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: _kOrange)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: items.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showOrderSuccess(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Pay ₹${_total.toInt()} with Paytm',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showOrderSuccess(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFEF6C00),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text('Order Placed!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 6),
          Text('Your order from Shree Ram Kirana Store\nwill arrive in ~10 minutes.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Done',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Extension helper ──────────────────────────────────────────────────────────

extension _PaddingExt on Widget {
  Widget wrapPadding(EdgeInsets p) => Padding(padding: p, child: this);
}
