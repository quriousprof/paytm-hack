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

class _PosHomeScreenState extends State<PosHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildSalesTab()),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Text(
            'Shree Ram Kirana Store',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
          ),
        ],
      ),
      actions: [
        // Notifications with ICE alert badge
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => _showNotificationsSheet(context),
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 24),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text('3',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        // Store avatar
        GestureDetector(
          onTap: () => _showStoreSheet(context),
          child: Container(
            margin: const EdgeInsets.only(right: 14, left: 4),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Text('SR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showStoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _StoreProfileSheet(),
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const IceScreen()),
      ),
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

// ── Notifications sheet ───────────────────────────────────────────────────────

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Alerts',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('3 critical',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
              Text('Just now',
                  style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
          const SizedBox(height: 14),
          _alertSection(context, 'Critical - stockout imminent',
              const Color(0xFFEF4444), const Color(0xFFFFEBEE), [
            _AlertItem('🧅', 'Onions', '2.4 kg left · stockout in < 1 day',
                const Color(0xFFEF4444)),
            _AlertItem('🍅', 'Tomatoes', '1.8 kg left · stockout in < 1 day',
                const Color(0xFFEF4444)),
            _AlertItem('🥛', 'Milk', '4 L left · stockout in ~18 hrs',
                const Color(0xFFEF4444)),
          ]),
          const SizedBox(height: 12),
          _alertSection(context, 'Low stock - reorder soon',
              const Color(0xFFE65100), const Color(0xFFFFF3E0), [
            _AlertItem('🥔', 'Potatoes', '6.5 kg · 2.3 days left',
                const Color(0xFFE65100)),
            _AlertItem('🍞', 'Brown Bread', '5 pkt · 2.5 days left',
                const Color(0xFFE65100)),
            _AlertItem('🥚', 'Eggs', '2 trays · 2.2 days left',
                const Color(0xFFE65100)),
            _AlertItem('🍶', 'Curd', '3 kg · 2.7 days left',
                const Color(0xFFE65100)),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to ICE tab via the parent's tab controller is
                // not trivially accessible here; user can tap the ICE tab
              },
              icon: const Icon(Icons.inventory_2_outlined,
                  size: 16, color: Colors.white),
              label: const Text('Open ICE Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertSection(
    BuildContext context,
    String title,
    Color titleColor,
    Color bgColor,
    List<_AlertItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: titleColor)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final item = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Text(item.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A1A))),
                              Text(item.detail,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (e.key < items.length - 1)
                    Divider(
                        height: 1,
                        color: item.color.withValues(alpha: 0.15),
                        indent: 40),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AlertItem {
  final String emoji;
  final String name;
  final String detail;
  final Color color;
  const _AlertItem(this.emoji, this.name, this.detail, this.color);
}

// ── Store profile sheet ───────────────────────────────────────────────────────

class _StoreProfileSheet extends StatelessWidget {
  const _StoreProfileSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Avatar
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF002970), Color(0xFF1A56DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('SR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          const Text('Shree Ram Kirana Store',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Active Merchant',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A))),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Column(
              children: [
                _profileRow(Icons.person_outline, 'Owner',
                    'Ramnath Sharma'),
                _divider(),
                _profileRow(Icons.payments_outlined, 'UPI ID',
                    'shreeram@paytm'),
                _divider(),
                _profileRow(Icons.location_on_outlined, 'Address',
                    '14, SV Road, Andheri West\nMumbai – 400 058'),
                _divider(),
                _profileRow(Icons.point_of_sale_outlined, 'Terminal ID',
                    'POS-MUM-1042'),
                _divider(),
                _profileRow(Icons.calendar_today_outlined, 'Member Since',
                    'January 2022'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.edit_outlined, size: 15),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kBlue,
                    side: const BorderSide(color: _kBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.logout, size: 15, color: Colors.white),
                  label: const Text('Logout',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: _kBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: Color(0xFFEEEEEE), indent: 44);
}
