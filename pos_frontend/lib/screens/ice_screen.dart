import 'dart:math';
import 'package:flutter/material.dart';

const _kBlue = Color(0xFF002970);
const _kCritical = Color(0xFFD32F2F);
const _kLow = Color(0xFFE65100);
const _kHealthy = Color(0xFF1A56DB);

// ── Data model ────────────────────────────────────────────────────────────────

enum _StockStatus { critical, low, healthy }

class _IceItem {
  final String id;
  final String name;
  final String emoji;
  final Color bgColor;
  final String unit;
  final double stockEst; // estimated current stock
  final double capacity; // typical max stock
  final double velocity; // units consumed per day
  final int confidence; // 0-100 %
  final _StockStatus status;
  final double reorderQty;
  final double reorderCost;
  final double trendPct; // +/- % change vs last week
  final String category;

  const _IceItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.bgColor,
    required this.unit,
    required this.stockEst,
    required this.capacity,
    required this.velocity,
    required this.confidence,
    required this.status,
    required this.reorderQty,
    required this.reorderCost,
    required this.trendPct,
    required this.category,
  });

  double get daysLeft => velocity > 0 ? stockEst / velocity : 99;
  double get stockPct => (stockEst / capacity).clamp(0.0, 1.0);
}

class _Insight {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String body;

  const _Insight({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.body,
  });
}

// ── Mock data ─────────────────────────────────────────────────────────────────

const _kItems = <_IceItem>[
  _IceItem(
    id: 'onion', name: 'Onions', emoji: '🧅',
    bgColor: Color(0xFFFFF3E0), unit: 'kg',
    stockEst: 2.4, capacity: 20, velocity: 3.1, confidence: 87,
    status: _StockStatus.critical, reorderQty: 15, reorderCost: 525,
    trendPct: 42, category: 'Vegetables',
  ),
  _IceItem(
    id: 'tomato', name: 'Tomatoes', emoji: '🍅',
    bgColor: Color(0xFFFFEBEE), unit: 'kg',
    stockEst: 1.8, capacity: 15, velocity: 2.4, confidence: 91,
    status: _StockStatus.critical, reorderQty: 12, reorderCost: 480,
    trendPct: 18, category: 'Vegetables',
  ),
  _IceItem(
    id: 'milk', name: 'Milk', emoji: '🥛',
    bgColor: Color(0xFFE3F2FD), unit: 'L',
    stockEst: 4, capacity: 30, velocity: 5.2, confidence: 94,
    status: _StockStatus.critical, reorderQty: 20, reorderCost: 1200,
    trendPct: 8, category: 'Dairy',
  ),
  _IceItem(
    id: 'potato', name: 'Potatoes', emoji: '🥔',
    bgColor: Color(0xFFFFF8E1), unit: 'kg',
    stockEst: 6.5, capacity: 25, velocity: 2.8, confidence: 83,
    status: _StockStatus.low, reorderQty: 10, reorderCost: 300,
    trendPct: -5, category: 'Vegetables',
  ),
  _IceItem(
    id: 'bread', name: 'Brown Bread', emoji: '🍞',
    bgColor: Color(0xFFFFF3E0), unit: 'pkt',
    stockEst: 5, capacity: 20, velocity: 2.0, confidence: 78,
    status: _StockStatus.low, reorderQty: 10, reorderCost: 450,
    trendPct: 12, category: 'Bakery',
  ),
  _IceItem(
    id: 'egg', name: 'Eggs', emoji: '🥚',
    bgColor: Color(0xFFFFF8E1), unit: 'tray',
    stockEst: 2, capacity: 10, velocity: 0.9, confidence: 72,
    status: _StockStatus.low, reorderQty: 5, reorderCost: 300,
    trendPct: 3, category: 'Bakery',
  ),
  _IceItem(
    id: 'curd', name: 'Curd', emoji: '🍶',
    bgColor: Color(0xFFE0F2F1), unit: 'kg',
    stockEst: 3, capacity: 12, velocity: 1.1, confidence: 81,
    status: _StockStatus.low, reorderQty: 6, reorderCost: 240,
    trendPct: -2, category: 'Dairy',
  ),
  _IceItem(
    id: 'rice', name: 'Basmati Rice', emoji: '🍚',
    bgColor: Color(0xFFF3E5F5), unit: 'kg',
    stockEst: 18, capacity: 50, velocity: 2.1, confidence: 96,
    status: _StockStatus.healthy, reorderQty: 0, reorderCost: 0,
    trendPct: 1, category: 'Grains',
  ),
  _IceItem(
    id: 'dal', name: 'Yellow Dal', emoji: '🫘',
    bgColor: Color(0xFFFFF3E0), unit: 'kg',
    stockEst: 14, capacity: 30, velocity: 1.0, confidence: 88,
    status: _StockStatus.healthy, reorderQty: 0, reorderCost: 0,
    trendPct: -3, category: 'Grains',
  ),
  _IceItem(
    id: 'flour', name: 'Wheat Flour', emoji: '🌾',
    bgColor: Color(0xFFFFF8E1), unit: 'kg',
    stockEst: 22, capacity: 40, velocity: 1.5, confidence: 90,
    status: _StockStatus.healthy, reorderQty: 0, reorderCost: 0,
    trendPct: 0, category: 'Grains',
  ),
  _IceItem(
    id: 'tea', name: 'Tata Tea', emoji: '🍵',
    bgColor: Color(0xFFE8F5E9), unit: 'pkt',
    stockEst: 8, capacity: 20, velocity: 0.6, confidence: 85,
    status: _StockStatus.healthy, reorderQty: 0, reorderCost: 0,
    trendPct: 5, category: 'Beverages',
  ),
  _IceItem(
    id: 'water', name: 'Bisleri Water', emoji: '💧',
    bgColor: Color(0xFFE1F5FE), unit: 'bottle',
    stockEst: 24, capacity: 48, velocity: 4.0, confidence: 92,
    status: _StockStatus.healthy, reorderQty: 0, reorderCost: 0,
    trendPct: 9, category: 'Beverages',
  ),
];

const _kInsights = <_Insight>[
  _Insight(
    icon: Icons.trending_up,
    color: _kCritical,
    bgColor: Color(0xFFFFEBEE),
    title: 'Onions selling 42% faster',
    body: 'Spike detected over last 4 days — likely festival demand. Reorder 15 kg today to avoid stockout.',
  ),
  _Insight(
    icon: Icons.access_time_rounded,
    color: _kLow,
    bgColor: Color(0xFFFFF3E0),
    title: 'Milk runs out in ~18 hrs',
    body: 'Current sell-through rate of 5.2 L/day will exhaust stock by tomorrow morning.',
  ),
  _Insight(
    icon: Icons.auto_graph,
    color: _kBlue,
    bgColor: Color(0xFFE8EAF6),
    title: 'Rice demand stable',
    body: 'Basmati Rice shows consistent 2.1 kg/day velocity. Next restock needed in ~8 days.',
  ),
  _Insight(
    icon: Icons.savings_outlined,
    color: Color(0xFF00695C),
    bgColor: Color(0xFFE0F2F1),
    title: 'Bundle opportunity detected',
    body: 'Tomatoes + Onions + Potatoes are bought together 68% of the time. Stock them together.',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class IceScreen extends StatelessWidget {
  const IceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final critical = _kItems.where((i) => i.status == _StockStatus.critical).toList();
    final low = _kItems.where((i) => i.status == _StockStatus.low).toList();
    final healthy = _kItems.where((i) => i.status == _StockStatus.healthy).toList();
    final reorderItems = _kItems.where((i) => i.reorderQty > 0).toList();
    final reorderTotal = reorderItems.fold(0.0, (s, i) => s + i.reorderCost);
    final healthScore = (healthy.length / _kItems.length * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(healthScore, critical.length, low.length, healthy.length),
          const SizedBox(height: 20),
          _buildInsightsRow(),
          const SizedBox(height: 24),
          if (critical.isNotEmpty) ...[
            _sectionHeader('Critical', _kCritical, critical.length,
                Icons.warning_amber_rounded),
            const SizedBox(height: 10),
            ...critical.map(_buildItemCard),
            const SizedBox(height: 20),
          ],
          if (low.isNotEmpty) ...[
            _sectionHeader('Low Stock', _kLow, low.length,
                Icons.arrow_downward_rounded),
            const SizedBox(height: 10),
            ...low.map(_buildItemCard),
            const SizedBox(height: 20),
          ],
          if (healthy.isNotEmpty) ...[
            _sectionHeader('Healthy', _kHealthy, healthy.length,
                Icons.check_circle_outline_rounded),
            const SizedBox(height: 10),
            ...healthy.map(_buildItemCard),
            const SizedBox(height: 20),
          ],
          if (reorderItems.isNotEmpty) ...[
            _buildReorderSummary(reorderItems, reorderTotal),
          ],
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(int score, int crit, int low, int healthy) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002970), Color(0xFF1A56DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                    SizedBox(width: 5),
                    Text('AI-Powered',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Updated just now',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$score%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Inventory Health',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              const Spacer(),
              _HealthRing(score: score),
            ],
          ),
          const SizedBox(height: 18),
          // Status chips
          Row(
            children: [
              _statusChip('$crit Critical', _kCritical),
              const SizedBox(width: 8),
              _statusChip('$low Low', _kLow),
              const SizedBox(width: 8),
              _statusChip('$healthy Healthy', Colors.white.withValues(alpha: 0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  // ── Insights ───────────────────────────────────────────────────────────────

  Widget _buildInsightsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text('AI Insights',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _kInsights.length,
            separatorBuilder: (context, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _buildInsightCard(_kInsights[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(_Insight insight) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: insight.bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(insight.icon, color: insight.color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: insight.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight.body,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────

  Widget _sectionHeader(String label, Color color, int count, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
      ],
    );
  }

  // ── Item card ──────────────────────────────────────────────────────────────

  Widget _buildItemCard(_IceItem item) {
    final statusColor = item.status == _StockStatus.critical
        ? _kCritical
        : item.status == _StockStatus.low
            ? _kLow
            : _kHealthy;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.status == _StockStatus.healthy
              ? const Color(0xFFEEEEEE)
              : statusColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: emoji + name + days left badge
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: item.bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
                    const SizedBox(height: 2),
                    Text(
                      '≈ ${_fmtStock(item.stockEst, item.unit)} remaining',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              _daysLeftBadge(item, statusColor),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: stock bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Stock level',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const Spacer(),
                  Text('${(item.stockPct * 100).round()}%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.stockPct,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF0F2F5),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 3: velocity + confidence + trend
          Row(
            children: [
              _metricChip(Icons.speed_rounded, '${item.velocity} ${item.unit}/day', Colors.grey[700]!),
              const SizedBox(width: 8),
              _metricChip(
                Icons.verified_outlined,
                '${item.confidence}% conf.',
                _kBlue,
              ),
              const Spacer(),
              _trendBadge(item.trendPct),
            ],
          ),

          // Reorder suggestion (only for critical/low)
          if (item.reorderQty > 0) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.shopping_cart_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  'Suggest reorder: ${item.reorderQty} ${item.unit}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '₹${item.reorderCost.toInt()}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _daysLeftBadge(_IceItem item, Color color) {
    if (item.status == _StockStatus.healthy) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _kHealthy.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${item.daysLeft.round()}d',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: _kHealthy),
        ),
      );
    }
    final hours = item.daysLeft < 1
        ? '${(item.daysLeft * 24).round()} hrs'
        : '${item.daysLeft.toStringAsFixed(1)}d';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(hours,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          Text('left', style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  Widget _metricChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }

  Widget _trendBadge(double pct) {
    if (pct == 0) return const SizedBox.shrink();
    final up = pct > 0;
    final color = up ? _kCritical : _kHealthy;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(up ? Icons.north_rounded : Icons.south_rounded,
            size: 11, color: color),
        Text(
          '${pct.abs().toStringAsFixed(0)}%',
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: color),
        ),
        Text(' vs last wk',
            style: TextStyle(fontSize: 10, color: Colors.grey[400])),
      ],
    );
  }

  // ── Reorder summary ────────────────────────────────────────────────────────

  Widget _buildReorderSummary(List<_IceItem> items, double total) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_checkout_rounded,
                    color: _kBlue, size: 18),
                const SizedBox(width: 8),
                const Text('Suggested Reorder',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${items.length} items',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _kBlue)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          ...items.map((item) {
            final statusColor = item.status == _StockStatus.critical
                ? _kCritical
                : _kLow;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  Text('${item.reorderQty} ${item.unit}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(width: 12),
                  Text('₹${item.reorderCost.toInt()}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                ],
              ),
            );
          }),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                const Text('Total Reorder Cost',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                Text('₹${total.toInt()}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _kBlue)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Send Reorder to Supplier',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _fmtStock(double v, String unit) {
    final s = v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
    return '$s $unit';
  }
}

// ── Health ring (arc painter) ─────────────────────────────────────────────────

class _HealthRing extends StatelessWidget {
  final int score; // 0-100

  const _HealthRing({required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(
        painter: _RingPainter(score / 100),
        child: Center(
          child: Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress; // 0-1

  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 5;
    const stroke = 6.0;
    const start = -pi / 2;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Progress
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      start,
      2 * pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
