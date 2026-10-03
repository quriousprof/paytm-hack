import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

const _kBlue = Color(0xFF002970);

class ChargeScreen extends StatefulWidget {
  const ChargeScreen({super.key});

  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  String _amount = '';

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount += key;
      } else {
        if (_amount.length < 10) _amount += key;
      }
    });
  }

  String get _displayAmount => _amount.isEmpty ? '0' : _amount;

  bool get _hasAmount =>
      _amount.isNotEmpty && double.tryParse(_amount) != 0;

  void _proceedToPayment() {
    if (!_hasAmount) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentMethodScreen(amount: double.parse(_amount)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _kBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Sale',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          _buildAmountDisplay(),
          const Divider(height: 1),
          Expanded(child: _buildNumpad()),
          _buildChargeButton(),
        ],
      ),
    );
  }

  Widget _buildAmountDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'ENTER AMOUNT',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: _amount.isEmpty ? Colors.grey[300] : _kBlue,
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
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
                      color:
                          _amount.isEmpty ? Colors.grey[300] : Colors.black87,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_hasAmount) ...[
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 80,
              decoration: BoxDecoration(
                color: _kBlue,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _hasAmount ? _proceedToPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            disabledBackgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: _hasAmount ? 2 : 0,
          ),
          child: Text(
            _hasAmount ? 'Charge  ₹$_amount' : 'Enter an amount',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _hasAmount ? Colors.white : Colors.grey[400],
            ),
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
        decoration: BoxDecoration(
          color: isBackspace ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: isBackspace
            ? Icon(Icons.backspace_outlined,
                size: 22, color: Colors.red[400])
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
      ),
    );
  }
}
