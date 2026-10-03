import 'package:flutter/material.dart';
import 'cart_sheet.dart';
import 'payment_method_screen.dart';

const _kBlue = Color(0xFF002970);

class KiranaStoreScreen extends StatefulWidget {
  const KiranaStoreScreen({super.key});

  @override
  State<KiranaStoreScreen> createState() => _KiranaStoreScreenState();
}

class _KiranaStoreScreenState extends State<KiranaStoreScreen> {
  final _searchController = TextEditingController();
  final Map<String, int> _cart = {};
  String _selectedCategory = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _categories = [
    'All',
    'Vegetables',
    'Dairy',
    'Bakery',
    'Snacks',
    'Beverages',
    'Grains',
  ];

  List<_Product> get _filtered => _kProducts.where((p) {
        final matchesCat =
            _selectedCategory == 'All' || p.category == _selectedCategory;
        final matchesQ = _query.isEmpty ||
            p.name.toLowerCase().contains(_query.toLowerCase());
        return matchesCat && matchesQ;
      }).toList();

  int get _cartCount =>
      _cart.values.fold(0, (sum, qty) => sum + qty);

  double get _cartTotal => _kProducts
      .where((p) => _cart.containsKey(p.id))
      .fold(0.0, (sum, p) => sum + p.price * (_cart[p.id] ?? 0));

  void _increment(String id) =>
      setState(() => _cart[id] = (_cart[id] ?? 0) + 1);

  void _decrement(String id) => setState(() {
        if ((_cart[id] ?? 0) <= 1) {
          _cart.remove(id);
        } else {
          _cart[id] = _cart[id]! - 1;
        }
      });

  List<CartItem> get _cartItems => _kProducts
      .where((p) => _cart.containsKey(p.id))
      .map((p) => CartItem(
            name: p.name,
            emoji: p.emoji,
            unit: p.unit,
            price: p.price,
            qty: _cart[p.id]!,
          ))
      .toList();

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CartSheet(
        items: _cartItems,
        onPlaceOrder: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentMethodScreen(amount: _cartTotal),
            ),
          );
        },
      ),
    );
  }

  void _showQuantityPicker(_Product product) {
    int qty = _cart[product.id] ?? 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, 24 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Product info
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: product.bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(product.emoji,
                        style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${product.price.toInt()} per ${product.unit}',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Quantity stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _qtyBtn(
                    Icons.remove,
                    qty > 1
                        ? () => setSheet(() => qty--)
                        : null,
                  ),
                  const SizedBox(width: 28),
                  Column(
                    children: [
                      Text(
                        '$qty',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _kBlue,
                        ),
                      ),
                      Text(
                        product.unit,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  const SizedBox(width: 28),
                  _qtyBtn(
                    Icons.add,
                    () => setSheet(() => qty++),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              // Add to cart button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _cart[product.id] = qty);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add $qty ${product.unit} to Cart  ·  ₹${(product.price * qty).toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? _kBlue.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon,
            size: 22,
            color: enabled ? _kBlue : Colors.grey[400]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(topPad),
          _buildCategories(),
          Expanded(child: _buildGrid()),
        ],
      ),
      bottomNavigationBar:
          _cartCount > 0 ? _buildCartBar() : null,
    );
  }

  // ── Header (app bar + search) ──────────────────────────────────────────────

  Widget _buildHeader(double topPad) {
    return Container(
      color: _kBlue,
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 14),
              const Text(
                'Kirana Store',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _cartBadge(),
            ],
          ),
          const SizedBox(height: 12),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _cartBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart_outlined,
            color: Colors.white, size: 26),
        if (_cartCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B00),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$_cartCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search for groceries...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic, color: _kBlue, size: 20),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Voice input coming soon'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        ),
      ),
    );
  }

  // ── Category chips ─────────────────────────────────────────────────────────

  Widget _buildCategories() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _categories.map((cat) {
            final sel = cat == _selectedCategory;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: sel ? _kBlue : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: sel
                      ? null
                      : Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    color: sel ? Colors.white : Colors.grey[700],
                    fontSize: 13,
                    fontWeight:
                        sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Product grid ───────────────────────────────────────────────────────────

  Widget _buildGrid() {
    final items = _filtered;
    if (items.isEmpty) {
      return const Center(
        child: Text('No items found',
            style: TextStyle(color: Colors.grey, fontSize: 15)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildProductCard(items[i]),
    );
  }

  Widget _buildProductCard(_Product p) {
    final qty = _cart[p.id] ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji tile
          Container(
            width: double.infinity,
            height: 88,
            decoration: BoxDecoration(
              color: p.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(p.emoji,
                style: const TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 8),
          Text(
            p.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            p.unit,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                '₹${p.price.toInt()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              qty == 0
                  ? GestureDetector(
                      onTap: () => _showQuantityPicker(p),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _kBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 18),
                      ),
                    )
                  : _counterRow(p.id, qty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterRow(String id, int qty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _counterBtn(Icons.remove, () => _decrement(id)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '$qty',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _kBlue,
            ),
          ),
        ),
        _counterBtn(Icons.add, () => _increment(id)),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: _kBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: _kBlue),
      ),
    );
  }

  // ── Cart bar ───────────────────────────────────────────────────────────────

  Widget _buildCartBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _showCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 0,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_cartCount ${_cartCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Expanded(
                child: Text(
                  'Show Cart',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '₹${_cartTotal.toInt()}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _Product {
  final String id;
  final String name;
  final String unit;
  final double price;
  final String emoji;
  final Color bgColor;
  final String category;

  const _Product({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.emoji,
    required this.bgColor,
    required this.category,
  });
}

const _kProducts = <_Product>[
  // Vegetables
  _Product(id: 'tomato', name: 'Tomatoes', unit: '1 kg', price: 40, emoji: '🍅', bgColor: Color(0xFFFFEBEE), category: 'Vegetables'),
  _Product(id: 'onion', name: 'Onions', unit: '1 kg', price: 35, emoji: '🧅', bgColor: Color(0xFFFFF3E0), category: 'Vegetables'),
  _Product(id: 'potato', name: 'Potatoes', unit: '1 kg', price: 30, emoji: '🥔', bgColor: Color(0xFFFFF8E1), category: 'Vegetables'),
  _Product(id: 'spinach', name: 'Spinach', unit: '250 g', price: 25, emoji: '🥬', bgColor: Color(0xFFE8F5E9), category: 'Vegetables'),
  _Product(id: 'carrot', name: 'Carrots', unit: '500 g', price: 30, emoji: '🥕', bgColor: Color(0xFFFFF3E0), category: 'Vegetables'),
  _Product(id: 'capsicum', name: 'Capsicum', unit: '250 g', price: 40, emoji: '🫑', bgColor: Color(0xFFE8F5E9), category: 'Vegetables'),
  // Dairy
  _Product(id: 'milk', name: 'Milk', unit: '500 ml', price: 30, emoji: '🥛', bgColor: Color(0xFFE3F2FD), category: 'Dairy'),
  _Product(id: 'butter', name: 'Butter', unit: '100 g', price: 55, emoji: '🧈', bgColor: Color(0xFFFFFDE7), category: 'Dairy'),
  _Product(id: 'curd', name: 'Curd', unit: '400 g', price: 40, emoji: '🍶', bgColor: Color(0xFFE0F2F1), category: 'Dairy'),
  _Product(id: 'cheese', name: 'Cheese Slice', unit: '200 g', price: 90, emoji: '🧀', bgColor: Color(0xFFFFF9C4), category: 'Dairy'),
  // Bakery
  _Product(id: 'bread', name: 'Brown Bread', unit: '400 g', price: 45, emoji: '🍞', bgColor: Color(0xFFFFF3E0), category: 'Bakery'),
  _Product(id: 'egg', name: 'Eggs', unit: '6 pcs', price: 60, emoji: '🥚', bgColor: Color(0xFFFFF8E1), category: 'Bakery'),
  // Snacks
  _Product(id: 'chips', name: 'Lays Classic', unit: '26 g', price: 20, emoji: '🥔', bgColor: Color(0xFFFFF9C4), category: 'Snacks'),
  _Product(id: 'biscuits', name: 'Parle-G', unit: '100 g', price: 10, emoji: '🍪', bgColor: Color(0xFFEFEBE9), category: 'Snacks'),
  _Product(id: 'namkeen', name: 'Aloo Bhujia', unit: '200 g', price: 35, emoji: '🥨', bgColor: Color(0xFFFFF3E0), category: 'Snacks'),
  _Product(id: 'chocolate', name: 'Dairy Milk', unit: '40 g', price: 40, emoji: '🍫', bgColor: Color(0xFFEFEBE9), category: 'Snacks'),
  // Beverages
  _Product(id: 'coke', name: 'Coca-Cola', unit: '500 ml', price: 40, emoji: '🥤', bgColor: Color(0xFFFFEBEE), category: 'Beverages'),
  _Product(id: 'water', name: 'Bisleri Water', unit: '1 L', price: 20, emoji: '💧', bgColor: Color(0xFFE1F5FE), category: 'Beverages'),
  _Product(id: 'tea', name: 'Tata Tea Gold', unit: '250 g', price: 85, emoji: '🍵', bgColor: Color(0xFFE8F5E9), category: 'Beverages'),
  _Product(id: 'juice', name: 'Real Juice', unit: '200 ml', price: 25, emoji: '🧃', bgColor: Color(0xFFFFF3E0), category: 'Beverages'),
  // Grains
  _Product(id: 'rice', name: 'Basmati Rice', unit: '1 kg', price: 80, emoji: '🍚', bgColor: Color(0xFFF3E5F5), category: 'Grains'),
  _Product(id: 'dal', name: 'Yellow Dal', unit: '1 kg', price: 120, emoji: '🫘', bgColor: Color(0xFFFFF3E0), category: 'Grains'),
  _Product(id: 'flour', name: 'Wheat Flour', unit: '1 kg', price: 55, emoji: '🌾', bgColor: Color(0xFFFFF8E1), category: 'Grains'),
  _Product(id: 'poha', name: 'Poha', unit: '500 g', price: 45, emoji: '🌾', bgColor: Color(0xFFF3E5F5), category: 'Grains'),
];
