import 'package:flutter/material.dart';

const _kGold1 = Color(0xFFB45309);
const _kGold2 = Color(0xFFD97706);
const _kGold3 = Color(0xFFFBBF24);
// ── Data ──────────────────────────────────────────────────────────────────────

class _Tier {
  final int daily;
  final int monthly;
  final int fv1m;
  final int fv3m;
  final int fv1y;
  final int fv3y;
  final int gain1y;
  final int gain3y;

  const _Tier({
    required this.daily,
    required this.monthly,
    required this.fv1m,
    required this.fv3m,
    required this.fv1y,
    required this.fv3y,
    required this.gain1y,
    required this.gain3y,
  });
}

// FV of monthly annuity at 11% p.a. (monthly compounding)
// fvNm = monthly × [(1.009167)^N − 1] / 0.009167
const _kTiers = [
  _Tier(
    daily: 50,  monthly: 1500,
    fv1m:   1514, fv3m:   4530,
    fv1y:  18940, gain1y:   940,
    fv3y:  63870, gain3y:  9870,
  ),
  _Tier(
    daily: 100, monthly: 3000,
    fv1m:   3028, fv3m:   9060,
    fv1y:  37880, gain1y:  1880,
    fv3y: 127740, gain3y: 19740,
  ),
  _Tier(
    daily: 200, monthly: 6000,
    fv1m:   6056, fv3m:  18120,
    fv1y:  75760, gain1y:  3760,
    fv3y: 255480, gain3y: 39480,
  ),
];

// Mock merchant stats
const _kDailyRevenue = 4230.0;
const _kDailyProfit  = 761.0;   // ~18% kirana margin
const _kWeekAvgProfit = 680.0;
const _kGoldPricePerGram = 6842.0;
const _kGoldChangePct    = 0.41; // % today

// Mock existing portfolio
const _kPortfolioInvested = 8200.0;
const _kPortfolioValue    = 9142.0;

// ── Screen ────────────────────────────────────────────────────────────────────

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  int _tierIndex = 1; // default ₹100/day

  _Tier get _tier => _kTiers[_tierIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: _kGold1,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Invest Now',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text('🥇', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Text('Paytm Gold',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          _buildEarningsHeader(),
          const SizedBox(height: 16),
          _buildGoldPriceTile(),
          const SizedBox(height: 20),
          _buildPortfolioSnapshot(),
          const SizedBox(height: 24),
          _buildSuggestionBanner(),
          const SizedBox(height: 16),
          _buildTierSelector(),
          const SizedBox(height: 16),
          _buildReturnsCard(),
          const SizedBox(height: 20),
          _buildWhyGold(),
          const SizedBox(height: 24),
          _buildInvestButton(),
        ],
      ),
    );
  }

  // ── Earnings header ──────────────────────────────────────────────────────

  Widget _buildEarningsHeader() {
    final portfolioGain = _kPortfolioValue - _kPortfolioInvested;
    final portfolioGainPct = portfolioGain / _kPortfolioInvested * 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGold1, _kGold2, _kGold3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _kGold2.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💰',
                  style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Today's Earnings",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Shree Ram Kirana',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _earningsStat('Revenue', '₹${_fmt(_kDailyRevenue)}'),
              _earningsDivider(),
              _earningsStat('Net Profit', '₹${_fmt(_kDailyProfit)}',
                  highlight: true),
              _earningsDivider(),
              _earningsStat('Margin', '18%'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_graph,
                    color: Colors.white, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your 7-day avg profit is ₹${_fmt(_kWeekAvgProfit)} — '
                    'a great base to start building wealth.',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _portfolioChip(
                  '₹${_fmt(_kPortfolioValue)}', 'Portfolio value', Colors.white),
              const SizedBox(width: 8),
              _portfolioChip(
                  '+${portfolioGainPct.toStringAsFixed(1)}%',
                  'Total returns',
                  const Color(0xFFDCFCE7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningsStat(String label, String value,
      {bool highlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: highlight ? 20 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _earningsDivider() {
    return Container(
        width: 1,
        height: 32,
        color: Colors.white.withValues(alpha: 0.3));
  }

  Widget _portfolioChip(String value, String label, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11)),
        ],
      ),
    );
  }

  // ── Gold price tile ──────────────────────────────────────────────────────

  Widget _buildGoldPriceTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('🥇', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('24K Digital Gold',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                SizedBox(height: 2),
                Text('99.9% Pure · Paytm Gold',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF888888))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmt(_kGoldPricePerGram)}/g',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_upward,
                      size: 12, color: Color(0xFF16A34A)),
                  Text(
                    '+${_kGoldChangePct.toStringAsFixed(2)}% today',
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF16A34A),
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Portfolio snapshot ───────────────────────────────────────────────────

  Widget _buildPortfolioSnapshot() {
    final gain = _kPortfolioValue - _kPortfolioInvested;
    final grams = _kPortfolioValue / _kGoldPricePerGram;

    return Container(
      padding: const EdgeInsets.all(16),
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
              const Text('Your Gold Portfolio',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text('Active',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A))),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _portfolioStat('Invested',
                  '₹${_fmt(_kPortfolioInvested)}', Colors.grey[700]!),
              _portfolioStat('Current Value',
                  '₹${_fmt(_kPortfolioValue)}', _kGold1),
              _portfolioStat(
                  'Earned',
                  '+₹${_fmt(gain)}',
                  const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _kPortfolioInvested / _kPortfolioValue,
              minHeight: 6,
              backgroundColor: const Color(0xFFFEF3C7),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_kGold2),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${grams.toStringAsFixed(4)} g gold',
                style: TextStyle(
                    fontSize: 11, color: Colors.grey[500]),
              ),
              const Spacer(),
              Text(
                '+${((gain / _kPortfolioInvested) * 100).toStringAsFixed(1)}% returns',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portfolioStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF888888))),
        ],
      ),
    );
  }

  // ── Suggestion banner ────────────────────────────────────────────────────

  Widget _buildSuggestionBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How much should you invest?',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Text('💡', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Based on your 7-day avg profit of ₹${_fmt(_kWeekAvgProfit)}, '
                  'investing ₹100/day puts ~13% of profit to work — a balanced start.',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tier selector ────────────────────────────────────────────────────────

  Widget _buildTierSelector() {
    const labels = ['₹50 / day', '₹100 / day', '₹200 / day'];
    const sublabels = ['Conservative', 'Recommended', 'Growth'];

    return Row(
      children: List.generate(3, (i) {
        final selected = _tierIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tierIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? _kGold1 : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: selected
                        ? _kGold1
                        : const Color(0xFFE0E0E0)),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: _kGold1.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color:
                          selected ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Returns card ─────────────────────────────────────────────────────────

  Widget _buildReturnsCard() {
    final t = _tier;
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                const Text('Projected Returns',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                Text('@ 11% p.a. (gold avg)',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              'Investing ₹${t.daily}/day  ·  ₹${_fmt(t.monthly.toDouble())}/month',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF888888)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          _returnRow('1 Month', t.monthly, t.fv1m,
              t.fv1m - t.monthly, false),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 16),
          _returnRow('3 Months', t.monthly * 3, t.fv3m,
              t.fv3m - t.monthly * 3, false),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 16),
          _returnRow(
              '1 Year', t.monthly * 12, t.fv1y, t.gain1y, true),
          const Divider(height: 1, color: Color(0xFFF5F5F5), indent: 16),
          _returnRow(
              '3 Years', t.monthly * 36, t.fv3y, t.gain3y, true),
        ],
      ),
    );
  }

  Widget _returnRow(String period, int invested, int fv, int gain,
      bool highlight) {
    final gainPct = gain / invested * 100;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(period,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: highlight
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: const Color(0xFF444444))),
          ),
          Expanded(
            child: Text('₹${_fmtK(invested)} invested',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey[500])),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmtK(fv)}',
                style: TextStyle(
                  fontSize: highlight ? 15 : 13,
                  fontWeight: FontWeight.bold,
                  color: highlight ? _kGold1 : const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                '+₹${_fmtK(gain)}  (${gainPct.toStringAsFixed(1)}%)',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Why gold ─────────────────────────────────────────────────────────────

  Widget _buildWhyGold() {
    const points = [
      ('🔒', 'Starts at ₹1', 'No minimum — invest what you can, daily'),
      ('📈', '11% avg annual growth', 'Gold outperformed FD every year since 2019'),
      ('⚡', 'Sell anytime', 'Instant redemption to bank account, no lock-in'),
      ('✅', '99.9% pure, insured', 'Stored in Brinks vault, insured by MMTC-PAMP'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text('Why Paytm Gold?',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 12),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$1, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.$2,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A))),
                          Text(p.$3,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── CTA ──────────────────────────────────────────────────────────────────

  Widget _buildInvestButton() {
    final t = _tier;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🥇', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Text(
                  'Invest ₹${t.daily} in Paytm Gold',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Powered by Paytm Gold  ·  MMTC-PAMP certified',
          style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(double v) {
    if (v >= 100000) {
      return '${(v / 100000).toStringAsFixed(1)}L';
    }
    if (v >= 1000) {
      final parts = v.toInt().toString();
      if (parts.length > 3) {
        return '${parts.substring(0, parts.length - 3)},${parts.substring(parts.length - 3)}';
      }
      return parts;
    }
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(0);
  }

  String _fmtK(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000) {
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }
}
