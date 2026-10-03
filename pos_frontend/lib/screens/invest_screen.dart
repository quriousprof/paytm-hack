import 'dart:math';
import 'package:flutter/material.dart';
import 'gold_investment_screen.dart';

const _kGold1 = Color(0xFFB45309);
const _kGold2 = Color(0xFFD97706);
const _kGold3 = Color(0xFFFBBF24);

// ── Constants ─────────────────────────────────────────────────────────────────

const _kDailyRevenue     = 4230.0;
const _kDailyProfit      = 761.0;    // ~18% kirana margin
const _kWeekAvgProfit    = 680.0;
const _kGoldPricePerGram = 15351.96; // live price per gram
const _kGoldChangePct    = 0.41;     // % change today

const _kPortfolioInvested = 8200.0;
const _kPortfolioValue    = 9142.0;

// Percentage tiers (of daily profit)
const _kTierPcts = [3, 4, 5];
const _kTierLabels = ['Safe', 'Balanced', 'Growth'];
const _kDefaultTier = 1; // 4% recommended

// ── Screen ────────────────────────────────────────────────────────────────────

class InvestScreen extends StatefulWidget {
  const InvestScreen({super.key});

  @override
  State<InvestScreen> createState() => _InvestScreenState();
}

class _InvestScreenState extends State<InvestScreen> {
  int _tierIndex = _kDefaultTier;

  // Daily ₹ amount for the selected tier
  int get _dailyAmount =>
      (_kDailyProfit * _kTierPcts[_tierIndex] / 100).round();

  int get _monthlyAmount => _dailyAmount * 30;

  // Gold in milligrams for the daily amount
  double get _dailyGoldMg =>
      _dailyAmount / _kGoldPricePerGram * 1000;

  // FV of monthly annuity at 11% p.a. (monthly compounding)
  int _fv(int months) {
    const r = 0.11 / 12;
    return (_monthlyAmount * (pow(1 + r, months) - 1) / r).round();
  }

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
          const SizedBox(height: 16),
          _buildDailySuggestion(),
          const SizedBox(height: 16),
          _buildTierSelector(),
          const SizedBox(height: 16),
          _buildReturnsCard(),
          const SizedBox(height: 20),
          _buildPortfolioSnapshot(),
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
              const Text('💰', style: TextStyle(fontSize: 20)),
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
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _earningsStat('Revenue', '₹${_fmt(_kDailyRevenue)}'),
              _earningsDiv(),
              _earningsStat('Net Profit', '₹${_fmt(_kDailyProfit)}',
                  highlight: true),
              _earningsDiv(),
              _earningsStat('Margin', '18%'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_graph, color: Colors.white, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '7-day avg profit ₹${_fmt(_kWeekAvgProfit)}  ·  '
                    'Invest 3–5% daily to grow passively',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        height: 1.4),
                  ),
                ),
              ],
            ),
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
          Text(value,
              style: TextStyle(
                color: Colors.white,
                fontSize: highlight ? 20 : 16,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _earningsDiv() => Container(
      width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3));

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
                Text('99.9% Pure · MMTC-PAMP · Paytm Gold',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF888888))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmtExact(_kGoldPricePerGram)}/g',
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

  // ── Daily suggestion (hero) ──────────────────────────────────────────────

  Widget _buildDailySuggestion() {
    final pct = _kTierPcts[_tierIndex];
    final mg = _dailyGoldMg;
    final mgStr = mg < 1
        ? '${(mg * 1000).toStringAsFixed(0)} µg'
        : '${mg.toStringAsFixed(2)} mg';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _kGold3.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💡',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text("Today's Investment Suggestion",
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹$_dailyAmount',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: _kGold1,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'invest today  ·  $pct% of ₹${_fmt(_kDailyProfit)} profit',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF92400E)),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  children: [
                    Text(
                      mgStr,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _kGold1),
                    ),
                    const SizedBox(height: 2),
                    const Text('of gold',
                        style: TextStyle(
                            fontSize: 10, color: Color(0xFF92400E))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _suggestionStat(
                      'Monthly invest', '₹$_monthlyAmount'),
                ),
                Container(
                    width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: _suggestionStat(
                      '1-year est.', '₹${_fmtK(_fv(12))}'),
                ),
                Container(
                    width: 1, height: 28, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: _suggestionStat(
                      'At ₹/g today', '₹${_fmtExact(_kGoldPricePerGram)}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _suggestionStat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A))),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: Color(0xFF888888))),
      ],
    );
  }

  // ── Tier selector ────────────────────────────────────────────────────────

  Widget _buildTierSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Adjust your comfort level',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444))),
        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            final pct = _kTierPcts[i];
            final amt = (_kDailyProfit * pct / 100).round();
            final mg = amt / _kGoldPricePerGram * 1000;
            final selected = _tierIndex == i;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tierIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 11),
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
                        '$pct%  ·  ₹$amt/day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${mg.toStringAsFixed(2)} mg/day',
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.8)
                              : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _kTierLabels[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? Colors.white.withValues(alpha: 0.7)
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Returns card ─────────────────────────────────────────────────────────

  Widget _buildReturnsCard() {
    final rows = [
      (period: '1 Month',  months: 1,  invested: _monthlyAmount * 1),
      (period: '3 Months', months: 3,  invested: _monthlyAmount * 3),
      (period: '1 Year',   months: 12, invested: _monthlyAmount * 12),
      (period: '3 Years',  months: 36, invested: _monthlyAmount * 36),
    ];

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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                const Text('Projected Returns',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                Text('@ 11% p.a.',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              '₹$_dailyAmount/day  ·  ₹$_monthlyAmount/month',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF888888)),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF5F5F5)),
          ...rows.asMap().entries.map((e) {
            final highlight = e.key >= 2;
            final fv = _fv(e.value.months);
            final gain = fv - e.value.invested;
            final gainPct = gain / e.value.invested * 100;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 76,
                        child: Text(e.value.period,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: highlight
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: const Color(0xFF444444))),
                      ),
                      Expanded(
                        child: Text(
                            '₹${_fmtK(e.value.invested)} invested',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500])),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${_fmtK(fv)}',
                            style: TextStyle(
                              fontSize: highlight ? 15 : 13,
                              fontWeight: FontWeight.bold,
                              color: highlight
                                  ? _kGold1
                                  : const Color(0xFF1A1A1A),
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
                ),
                if (e.key < rows.length - 1)
                  const Divider(
                      height: 1,
                      color: Color(0xFFF5F5F5),
                      indent: 16),
              ],
            );
          }),
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
                  border: Border.all(color: const Color(0xFF86EFAC)),
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
              _portfolioStat(
                  'Current Value', '₹${_fmt(_kPortfolioValue)}', _kGold1),
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
              valueColor: const AlwaysStoppedAnimation<Color>(_kGold2),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${grams.toStringAsFixed(4)} g gold',
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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

  // ── Why gold ─────────────────────────────────────────────────────────────

  Widget _buildWhyGold() {
    const points = [
      ('🔒', 'Starts at ₹1', 'No minimum — add to your stack daily'),
      ('📈', '11% avg annual growth', 'Outperformed FD every year since 2019'),
      ('⚡', 'Sell anytime', 'Instant redemption, no lock-in period'),
      ('✅', '99.9% pure, insured', 'Stored in Brinks vault, MMTC-PAMP certified'),
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoldInvestmentScreen(
                  amount: _dailyAmount.toDouble(),
                ),
              ),
            ),
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
                  'Invest ₹$_dailyAmount in Paytm Gold',
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
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) {
      final s = v.toInt().toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toInt().toString();
  }

  String _fmtK(int v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(2)}L';
    if (v >= 1000) {
      final s = v.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return v.toString();
  }

  String _fmtExact(double v) {
    // Format with commas, keep decimals
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final dec = parts[1];
    if (intPart.length > 3) {
      return '${intPart.substring(0, intPart.length - 3)},${intPart.substring(intPart.length - 3)}.$dec';
    }
    return '$intPart.$dec';
  }
}
