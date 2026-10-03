import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key});

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  String _amount = '';
  static const _bgDark = Color(0xFF0D0D1A);
  static const _surface = Color(0xFF1A1A2E);
  static const _accentLight = Color(0xFF1A56DB);

  void _onKey(String key) {
    setState(() {
      if (key == 'C') {
        _amount = '';
      } else if (key == '⌫') {
        if (_amount.isNotEmpty) _amount = _amount.substring(0, _amount.length - 1);
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount += key;
      } else {
        if (_amount.length < 10) _amount += key;
      }
    });
  }

  String get _displayAmount {
    if (_amount.isEmpty) return '0';
    return _amount;
  }

  void _proceedToPayment() {
    if (_amount.isEmpty || double.tryParse(_amount) == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentMethodScreen(amount: double.parse(_amount)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildAmountDisplay()),
            _buildNumpad(),
            _buildChargeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Image.asset('assets/paytm-logo.jpg',
              width: 80, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Text(
            'POS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          _headerChip(Icons.wifi, 'Online'),
          const SizedBox(width: 8),
          _headerChip(Icons.battery_full, '98%'),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.greenAccent),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'ENTER AMOUNT',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: _amount.isEmpty
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _displayAmount,
                    style: TextStyle(
                      color: _amount.isEmpty
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_amount.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_accentLight, _accentLight.withValues(alpha: 0)],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _NumKey(
                      label: key,
                      onTap: () => _onKey(key),
                      isBackspace: key == '⌫',
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChargeButton() {
    final hasAmount = _amount.isNotEmpty && double.tryParse(_amount) != 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: hasAmount ? _proceedToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasAmount ? _accentLight : _surface,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: hasAmount ? 4 : 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payments_outlined, size: 22),
              const SizedBox(width: 10),
              Text(
                hasAmount
                    ? 'Charge  ₹$_amount'
                    : 'Enter an amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hasAmount ? Colors.white : Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isBackspace;

  const _NumKey({
    required this.label,
    required this.onTap,
    this.isBackspace = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isBackspace
              ? const Color(0xFF2A1A1A)
              : const Color(0xFF1E1E30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        alignment: Alignment.center,
        child: isBackspace
            ? Icon(Icons.backspace_outlined,
                size: 22, color: Colors.redAccent.withValues(alpha: 0.8))
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
      ),
    );
  }
}
