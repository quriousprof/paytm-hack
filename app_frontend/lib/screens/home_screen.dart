import 'package:flutter/material.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeBody();
      case 3:
        return const StoreScreen();
      default:
        return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    final labels = ['', 'Scan & Pay', 'Passbook', '', 'Profile'];
    return Center(
      child: Text(
        labels[_currentIndex],
        style: const TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildHomeBody() {
    return CustomScrollView(
      slivers: [
        // Top bar
        SliverToBoxAdapter(child: _buildTopBar()),
        // Search bar
        SliverToBoxAdapter(child: _buildSearchBar()),
        // Wallet card
        SliverToBoxAdapter(child: _buildWalletCard()),
        // Quick actions
        SliverToBoxAdapter(child: _buildQuickActions()),
        // Recharge & Bills
        SliverToBoxAdapter(child: _buildSectionHeader('Recharge & Pay Bills')),
        SliverToBoxAdapter(child: _buildRechargeGrid()),
        // Mini Apps section
        SliverToBoxAdapter(child: _buildSectionHeader('Mini Apps')),
        SliverToBoxAdapter(child: _buildMiniApps()),
        // Promo banner
        SliverToBoxAdapter(child: _buildPromoBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFF002970),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/paytm-logo.jpg',
            width: 96,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          _topBarIcon(Icons.qr_code_scanner, onTap: () {}),
          const SizedBox(width: 16),
          _topBarIcon(Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: 16),
          _topBarIcon(Icons.headset_mic_outlined, onTap: () {}),
        ],
      ),
    );
  }

  Widget _topBarIcon(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF002970),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7), size: 20),
            const SizedBox(width: 10),
            Text(
              'Search for "Mobile Recharge"',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3A7A), Color(0xFF002970)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF002970).withValues(alpha: 0.3),
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
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Paytm Wallet',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Add Money',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 1,250.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'UPI ID: user@paytm',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(Icons.qr_code_scanner, 'Scan &\nPay', const Color(0xFF002970)),
      _QuickAction(Icons.send, 'Send\nMoney', const Color(0xFF00897B)),
      _QuickAction(Icons.account_balance, 'Bank\nTransfer', const Color(0xFF5C6BC0)),
      _QuickAction(Icons.receipt_long, 'Check\nBalance', const Color(0xFFEF6C00)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: a.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(a.icon, color: a.color, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, height: 1.3),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          const Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF002970),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRechargeGrid() {
    final items = [
      _GridItem(Icons.phone_android, 'Mobile\nRecharge'),
      _GridItem(Icons.bolt, 'Electricity'),
      _GridItem(Icons.satellite_alt, 'DTH'),
      _GridItem(Icons.water_drop, 'Water'),
      _GridItem(Icons.local_gas_station, 'Gas\nBill'),
      _GridItem(Icons.wifi, 'Broadband'),
      _GridItem(Icons.credit_card, 'Credit\nCard'),
      _GridItem(Icons.apartment, 'Rent'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.85,
        children: items.map((item) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: const Color(0xFF002970), size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, height: 1.3),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMiniApps() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Kirana Storefront mini app entry
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 3),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF6C00),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kirana Storefront',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Your neighbourhood store, now digital',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Color(0xFFEF6C00)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Other mini apps
          Row(
            children: [
              _miniAppTile(Icons.local_mall, 'Paytm\nMall', const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _miniAppTile(Icons.movie, 'Movie\nTickets', const Color(0xFFC62828)),
              const SizedBox(width: 12),
              _miniAppTile(Icons.train, 'Train\nTickets', const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _miniAppTile(Icons.flight, 'Flights', const Color(0xFF6A1B9A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniAppTile(IconData icon, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002970), Color(0xFF1A3A7A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Go Digital with POS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Accept payments & manage your store digitally',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Explore',
              style: TextStyle(
                color: Color(0xFF002970),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF002970),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan & Pay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Passbook'),
          BottomNavigationBarItem(
              icon: Icon(Icons.storefront), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _GridItem {
  final IconData icon;
  final String label;
  const _GridItem(this.icon, this.label);
}
