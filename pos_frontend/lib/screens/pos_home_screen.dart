import 'dart:math';
import 'package:flutter/material.dart';
import 'charge_screen.dart';
import 'kirana_store_screen.dart';

const _kBlue = Color(0xFF002970);

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key});

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSalesTab(),
                _buildPlaceholder('Invoices'),
                _buildPlaceholder('Products'),
              ],
            ),
          ),
          _buildFilterBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChargeScreen()),
        ),
        backgroundColor: _kBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Sale',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kBlue,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: const Text(
        'Dashboard',
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white)),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white)),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _kBlue,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Sales'),
          Tab(text: 'Invoices'),
          Tab(text: 'Products'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: _kBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/paytm-logo.jpg',
                    width: 120, fit: BoxFit.contain),
                const SizedBox(height: 8),
                const Text('Merchant Dashboard',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard_outlined, 'Dashboard', selected: true),
          _drawerItem(Icons.receipt_long_outlined, 'Invoices'),
          _drawerItem(Icons.inventory_2_outlined, 'Products'),
          _drawerItem(Icons.bar_chart_outlined, 'Reports'),
          _drawerItem(Icons.settings_outlined, 'Settings'),
          const Spacer(),
          _drawerItem(Icons.logout, 'Logout'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, {bool selected = false}) {
    return ListTile(
      leading: Icon(icon,
          color: selected ? _kBlue : Colors.grey[600], size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? _kBlue : Colors.grey[800],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      tileColor:
          selected ? _kBlue.withValues(alpha: 0.07) : null,
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildSalesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      children: [
        _buildBusinessBanner(),
        const SizedBox(height: 16),
        _buildKiranaCard(),
        const SizedBox(height: 16),
        _buildPaymentSplitCard(),
        const SizedBox(height: 88), // FAB clearance
      ],
    );
  }

  Widget _buildBusinessBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Business',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Text(
            'with',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 6),
          Image.asset('assets/paytm-logo.jpg',
              width: 140, fit: BoxFit.contain),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == 0 ? _kBlue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildKiranaCard() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KiranaStoreScreen()),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left panel
            Container(
              width: 110,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0C8A4E), Color(0xFF1DB868)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🛒', style: TextStyle(fontSize: 30)),
                  SizedBox(height: 8),
                  Text(
                    'Kirana',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Store',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Right panel — stats
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    _kiranaStatRow("Today's Sales", '₹4,230',
                        color: const Color(0xFF0C8A4E)),
                    const Divider(height: 14, color: Color(0xFFEEEEEE)),
                    _kiranaStatRow('Items Sold', '47'),
                    const Divider(height: 14, color: Color(0xFFEEEEEE)),
                    _kiranaStatRow('Active Orders', '8'),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: Colors.grey, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kiranaStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSplitCard() {
    const segments = [
      _ChartSegment(
          color: Color(0xFF00BCD4), fraction: 0.45, label: 'CASH'),
      _ChartSegment(
          color: Color(0xFF002970), fraction: 0.41, label: 'CARD'),
      _ChartSegment(
          color: Color(0xFF1A56DB), fraction: 0.09, label: 'PAYTM'),
      _ChartSegment(
          color: Color(0xFFFF7043), fraction: 0.05, label: 'COUPONS'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Payment Split',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A)),
              ),
              const Spacer(),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CustomPaint(
                    painter: _DonutChartPainter(segments)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _legendRow(segments[0], '₹1,23,546.00'),
                    _legendRow(segments[1], '₹1,70,046.00'),
                    _legendRow(segments[2], '₹2,046.29'),
                    _legendRowNegative(segments[3], '₹11,546.00'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendRow(_ChartSegment seg, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: seg.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            seg.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A)),
          ),
        ],
      ),
    );
  }

  Widget _legendRowNegative(_ChartSegment seg, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: seg.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            seg.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_downward, size: 12, color: Colors.red[400]),
          const SizedBox(width: 2),
          Text(
            '-$amount',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.red[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 15, color: Color(0xFF555555)),
          const SizedBox(width: 8),
          const Text(
            'YESTERDAY',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
              letterSpacing: 0.5,
            ),
          ),
          const Icon(Icons.arrow_drop_down,
              color: Color(0xFF555555), size: 20),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 15, color: Colors.white),
            label: const Text(
              'FILTER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}

// ── Data & Chart ─────────────────────────────────────────────────────────────

class _ChartSegment {
  final Color color;
  final double fraction;
  final String label;
  const _ChartSegment(
      {required this.color,
      required this.fraction,
      required this.label});
}

class _DonutChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  const _DonutChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerR = size.width * 0.47;
    final innerR = size.width * 0.28;
    final arcR = (outerR + innerR) / 2;
    final strokeW = outerR - innerR;
    const gap = 0.05; // radians between segments

    double startAngle = -pi / 2;
    for (final seg in segments) {
      final sweep = 2 * pi * seg.fraction - gap;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcR),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = seg.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
