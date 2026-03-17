import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _goldController = TextEditingController();
  final _silverController = TextEditingController();
  final _cashController = TextEditingController();
  final _tradeGoodsController = TextEditingController();
  final _debtsController = TextEditingController();

  // Current metal prices (user can update)
  final _goldPriceController = TextEditingController(text: '90.00');
  final _silverPriceController = TextEditingController(text: '1.10');

  // Results
  double? _totalWealth = 0;
  double? _zakatAmount = 0;
  bool? _zakatDue;
  bool _calculated = false;

  // Nisab thresholds
  static const double _nisabGoldGrams = 87.48;
  static const double _nisabSilverGrams = 612.36;
  static const double _zakatRate = 0.025; // 2.5%

  late AnimationController _resultAnimController;
  late Animation<double> _resultFadeAnim;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _resultFadeAnim = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    _cashController.dispose();
    _tradeGoodsController.dispose();
    _debtsController.dispose();
    _goldPriceController.dispose();
    _silverPriceController.dispose();
    _resultAnimController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final double goldGrams = double.tryParse(_goldController.text) ?? 0;
    final double silverGrams = double.tryParse(_silverController.text) ?? 0;
    final double cash = double.tryParse(_cashController.text) ?? 0;
    final double tradeGoods = double.tryParse(_tradeGoodsController.text) ?? 0;
    final double debts = double.tryParse(_debtsController.text) ?? 0;
    final double goldPricePerGram = double.tryParse(_goldPriceController.text) ?? 90.0;
    final double silverPricePerGram = double.tryParse(_silverPriceController.text) ?? 1.1;

    final double goldValue = goldGrams * goldPricePerGram;
    final double silverValue = silverGrams * silverPricePerGram;
    final double totalAssets = goldValue + silverValue + cash + tradeGoods;
    final double netWealth = (totalAssets - debts).clamp(0, double.infinity);

    // Nisab in terms of currency (use silver nisab as it benefits more poor)
    final double nisabValue = _nisabSilverGrams * silverPricePerGram;

    final bool zakatDue = netWealth >= nisabValue;
    final double zakatAmount = zakatDue ? netWealth * _zakatRate : 0;

    setState(() {
      _totalWealth = netWealth;
      _zakatAmount = zakatAmount;
      _zakatDue = zakatDue;
      _calculated = true;
    });

    _resultAnimController.forward(from: 0);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _goldController.clear();
    _silverController.clear();
    _cashController.clear();
    _tradeGoodsController.clear();
    _debtsController.clear();
    setState(() {
      _calculated = false;
      _zakatDue = null;
    });
    _resultAnimController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Zakat Calculator'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoBanner(primaryColor),
            const SizedBox(height: 20),
            _buildSectionHeader('Precious Metals', Icons.diamond_outlined, primaryColor),
            const SizedBox(height: 12),
            _buildInputCard(cardColor, [
              _buildTextField(
                controller: _goldController,
                label: 'Gold (grams)',
                hint: '0.0',
                icon: Icons.circle,
                iconColor: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _silverController,
                label: 'Silver (grams)',
                hint: '0.0',
                icon: Icons.circle_outlined,
                iconColor: Colors.grey,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionHeader('Financial Assets', Icons.account_balance_wallet_outlined, primaryColor),
            const SizedBox(height: 12),
            _buildInputCard(cardColor, [
              _buildTextField(
                controller: _cashController,
                label: 'Cash & Bank Savings (\$)',
                hint: '0.00',
                icon: Icons.attach_money,
                iconColor: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _tradeGoodsController,
                label: 'Trade Goods / Stock Value (\$)',
                hint: '0.00',
                icon: Icons.store_outlined,
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _debtsController,
                label: 'Outstanding Debts (\$)',
                hint: '0.00',
                icon: Icons.money_off,
                iconColor: Colors.red,
                isDebt: true,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionHeader('Metal Prices (per gram)', Icons.trending_up, primaryColor),
            const SizedBox(height: 12),
            _buildInputCard(cardColor, [
              _buildTextField(
                controller: _goldPriceController,
                label: 'Gold Price (\$ per gram)',
                hint: '90.00',
                icon: Icons.circle,
                iconColor: const Color(0xFFD4AF37),
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _silverPriceController,
                label: 'Silver Price (\$ per gram)',
                hint: '1.10',
                icon: Icons.circle_outlined,
                iconColor: Colors.grey,
              ),
            ]),
            const SizedBox(height: 24),
            _buildNisabInfo(primaryColor),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text(
                  'Calculate Zakat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_calculated) ...[
              FadeTransition(
                opacity: _resultFadeAnim,
                child: _buildResultCard(primaryColor),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Zakat is 2.5% of total net wealth held for one full lunar year (Hawl), provided it meets the Nisab threshold.',
              style: TextStyle(fontSize: 13, color: primaryColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard(Color cardColor, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    bool isDebt = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDebt ? Colors.red : Theme.of(context).primaryColor,
            width: 1.8,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        filled: true,
        fillColor: isDebt
            ? Colors.red.withOpacity(0.04)
            : Theme.of(context).primaryColor.withOpacity(0.03),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (double.tryParse(value) == null) return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildNisabInfo(Color primaryColor) {
    final double silverPrice = double.tryParse(_silverPriceController.text) ?? 1.1;
    final double goldPrice = double.tryParse(_goldPriceController.text) ?? 90.0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.balance, color: Color(0xFFD4AF37), size: 20),
              SizedBox(width: 8),
              Text(
                'Nisab Thresholds',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildNisabRow(
            'Gold Nisab:',
            '${_nisabGoldGrams}g ≈ \$${(goldPrice * _nisabGoldGrams).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 4),
          _buildNisabRow(
            'Silver Nisab:',
            '${_nisabSilverGrams}g ≈ \$${(silverPrice * _nisabSilverGrams).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),
          Text(
            '* Silver Nisab is used as the standard threshold (benefits the poor more).',
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildResultCard(Color primaryColor) {
    final bool due = _zakatDue ?? false;
    final Color resultColor = due ? primaryColor : Colors.orange;
    final IconData resultIcon = due ? Icons.check_circle : Icons.info;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            resultColor.withOpacity(0.12),
            resultColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: resultColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: resultColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(resultIcon, color: resultColor, size: 26),
                const SizedBox(width: 10),
                Text(
                  due ? 'Zakat is Due' : 'Zakat Not Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildResultRow('Net Wealth', '\$${_totalWealth!.toStringAsFixed(2)}', Colors.black87),
            const SizedBox(height: 8),
            if (due) ...[
              _buildResultRow(
                'Zakat Amount (2.5%)',
                '\$${_zakatAmount!.toStringAsFixed(2)}',
                resultColor,
                bold: true,
                large: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'You are obligated to pay \$${_zakatAmount!.toStringAsFixed(2)} in Zakat. This should be given to eligible recipients (Asnaf) such as the poor, needy, and those in debt.',
                  style: TextStyle(fontSize: 13, color: resultColor, height: 1.5),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Your net wealth does not meet the Nisab threshold. Zakat is not obligatory, but voluntary charity (Sadaqah) is always encouraged.',
                  style: TextStyle(fontSize: 13, color: Colors.orange, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    Color valueColor, {
    bool bold = false,
    bool large = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: large ? 15 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 20 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
