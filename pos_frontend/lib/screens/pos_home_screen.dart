import 'dart:math';
import 'package:flutter/material.dart';
import 'charge_screen.dart';
import 'kirana_store_screen.dart';
import 'ice_screen.dart';
import 'invest_screen.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
                const IceScreen(),
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
          Tab(text: 'ICE'),
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
        _buildIceCard(),
        const SizedBox(height: 16),
        _buildInvestCard(),
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
    return _FeatureCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KiranaStoreScreen()),
      ),
      gradientColors: const [Color(0xFF002970), Color(0xFF1565C0)],
      accentColor: const Color(0xFF1A56DB),
      emoji: '🛒',
      title: 'Kirana Store',
      subtitle: 'Digital storefront',
      badge: '8 active',
      badgeColor: const Color(0xFF1A56DB),
      stats: const [
        _CardStat(value: '₹4,230', label: "Today's Sales",
            color: Color(0xFF1A56DB)),
        _CardStat(value: '47', label: 'Items Sold'),
        _CardStat(value: '8', label: 'Orders', color: Color(0xFF16A34A)),
      ],
    );
  }

  Widget _buildIceCard() {
    return _FeatureCard(
      onTap: () => _tabController.animateTo(3),
      gradientColors: const [Color(0xFF0D47A1), Color(0xFF00838F)],
      accentColor: const Color(0xFF00ACC1),
      emoji: '📦',
      title: 'ICE Engine',
      subtitle: 'AI-powered inventory',
      badge: 'AI',
      badgeColor: const Color(0xFF00ACC1),
      stats: const [
        _CardStat(value: '74%', label: 'Health Score',
            color: Color(0xFF00ACC1)),
        _CardStat(value: '3', label: 'Critical',
            color: Color(0xFFD32F2F)),
        _CardStat(value: '₹3,180', label: 'Reorder'),
      ],
    );
  }

  Widget _buildInvestCard() {
    return _FeatureCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InvestScreen()),
      ),
      gradientColors: const [Color(0xFFB45309), Color(0xFFD97706)],
      accentColor: const Color(0xFFD97706),
      emoji: '🥇',
      title: 'Invest Now',
      subtitle: 'Paytm Gold',
      badge: '+11.5%',
      badgeColor: const Color(0xFF16A34A),
      stats: const [
        _CardStat(value: '₹761', label: "Today's Profit",
            color: Color(0xFFB45309)),
        _CardStat(value: '₹9,142', label: 'Portfolio',
            color: Color(0xFF16A34A)),
        _CardStat(value: '+11.5%', label: 'Returns',
            color: Color(0xFF16A34A)),
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

// ── Feature cards ─────────────────────────────────────────────────────────────

class _CardStat {
  final String value;
  final String label;
  final Color? color;
  const _CardStat({required this.value, required this.label, this.color});
}

class _FeatureCard extends StatelessWidget {
  final VoidCallback onTap;
  final List<Color> gradientColors;
  final Color accentColor;
  final String emoji;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final List<_CardStat> stats;

  const _FeatureCard({
    required this.onTap,
    required this.gradientColors,
    required this.accentColor,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.06),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors.last.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji,
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 1),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: badgeColor.withValues(alpha: 0.25)),
                    ),
                    child: Text(badge,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: badgeColor)),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: Colors.grey[400]),
                ],
              ),
            ),
            // ── Stats row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 14, horizontal: 6),
              child: Row(
                children: [
                  for (int i = 0; i < stats.length; i++) ...[
                    Expanded(child: _statCol(stats[i])),
                    if (i < stats.length - 1)
                      Container(
                        width: 1,
                        height: 32,
                        color: const Color(0xFFEEEEEE),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCol(_CardStat stat) {
    return Column(
      children: [
        Text(
          stat.value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: stat.color ?? const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          stat.label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
          textAlign: TextAlign.center,
        ),
      ],
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
