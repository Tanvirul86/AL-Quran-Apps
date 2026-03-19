import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/tasbih_service.dart';
import '../theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> 
    with TickerProviderStateMixin {
  final TasbihService _tasbihService = TasbihService();
  late AnimationController _rippleController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  
  String _selectedDhikr = 'SubhanAllah';
  int _currentCount = 0;
  bool _hapticEnabled = true;
  String? _customDhikr;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTasbihState();
  }

  void _initializeAnimations() {
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _loadTasbihState() async {
    await _tasbihService.initialize();
    setState(() {
      _selectedDhikr = _tasbihService.currentDhikr;
      _currentCount = _tasbihService.currentCount;
      _hapticEnabled = _tasbihService.hapticEnabled;
    });
  }

  Future<void> _incrementCounter() async {
    await _tasbihService.increment();
    setState(() {
      _currentCount = _tasbihService.currentCount;
    });
    
    // Trigger animations
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });
    _rippleController.forward().then((_) {
      _rippleController.reset();
    });
  }

  Future<void> _resetCounter() async {
    final confirm = await _showResetConfirmation();
    if (confirm == true) {
      await _tasbihService.reset();
      setState(() {
        _currentCount = 0;
      });
    }
  }

  Future<bool?> _showResetConfirmation() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Counter'),
        content: const Text(
          'This will save your current session and reset the counter to 0. Continue?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDhikr() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DhikrSelectionSheet(
        currentDhikr: _selectedDhikr,
        customDhikr: _customDhikr,
      ),
    );
    
    if (result != null && result != _selectedDhikr) {
      await _tasbihService.setDhikr(result);
      setState(() {
        _selectedDhikr = result;
        // Load the saved count for this dhikr
        _currentCount = _tasbihService.currentCount;
        if (result == 'Custom Dhikr') {
          // Custom dhikr will be handled in the bottom sheet
        }
      });
    }
  }

  void _showStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasbihStatisticsScreen(),
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TasbihSettingsScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.forestPrimary,
        elevation: 0,
        title: const Text(
          'Digital Tasbih',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: _showStatistics,
            tooltip: 'Statistics',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.forestBackground,
              AppTheme.forestSurface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Dhikr selection
              _buildDhikrSelector(),
              
              // Counter display
              const SizedBox(height: 8),
              _buildCounterDisplay(),
              
              // Interactive counter button
              Expanded(
                child: _buildCounterButton(),
              ),
              
              // Action buttons
              _buildActionButtons(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Dhikr',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectDhikr,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _customDhikr ?? _selectedDhikr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Count',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _currentCount.toString(),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGreen,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildMilestoneIndicator(),
        ],
      ),
    );
  }

  Widget _buildMilestoneIndicator() {
    final remaining33 = 33 - (_currentCount % 33);
    final remaining99 = 99 - (_currentCount % 99);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_currentCount % 33 == 0 && _currentCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '✨ Milestone x33',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          Text(
            '$remaining33 to next 33',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.primaryGreen,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        
        const SizedBox(height: 2),
        
        if (_currentCount >= 99)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '🌟 Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          Text(
            '$remaining99 to complete Tasbih',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildCounterButton() {
    return Center(
      child: GestureDetector(
        onTap: _incrementCounter,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  AnimatedBuilder(
                    animation: _rippleAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 200 + (_rippleAnimation.value * 50),
                        height: 200 + (_rippleAnimation.value * 50),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGreen.withOpacity(
                            0.3 * (1 - _rippleAnimation.value),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Main counter button
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryGreen,
                          AppTheme.darkGreen,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'TAP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        if (_hapticEnabled) ...[
                          const SizedBox(height: 4),
                          Icon(
                            Icons.vibration,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Reset',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
                foregroundColor: AppTheme.primaryGreen,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.primaryGreen.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectDhikr,
              icon: const Icon(Icons.list, size: 18),
              label: const Text(
                'Change',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DhikrSelectionSheet extends StatefulWidget {
  final String currentDhikr;
  final String? customDhikr;

  const DhikrSelectionSheet({
    super.key,
    required this.currentDhikr,
    this.customDhikr,
  });

  @override
  State<DhikrSelectionSheet> createState() => _DhikrSelectionSheetState();
}

class _DhikrSelectionSheetState extends State<DhikrSelectionSheet> {
  final TasbihService _tasbihService = TasbihService();
  final TextEditingController _customController = TextEditingController();
  String _selectedDhikr = '';

  @override
  void initState() {
    super.initState();
    _selectedDhikr = widget.currentDhikr;
    if (widget.customDhikr != null) {
      _customController.text = widget.customDhikr!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Dhikr',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGreen,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tasbihService.predefinedDhikr.length,
              itemBuilder: (context, index) {
                final dhikr = _tasbihService.predefinedDhikr[index];
                final isSelected = _selectedDhikr == dhikr;
                final isCustom = dhikr == 'Custom Dhikr';
                
                return Column(
                  children: [
                    ListTile(
                      leading: Radio<String>(
                        value: dhikr,
                        groupValue: _selectedDhikr,
                        onChanged: (value) {
                          setState(() {
                            _selectedDhikr = value!;
                          });
                        },
                        activeColor: AppTheme.primaryGreen,
                      ),
                      title: Text(
                        dhikr,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.darkGreen : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDhikr = dhikr;
                        });
                      },
                    ),
                    
                    if (isCustom && isSelected)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _customController,
                          decoration: InputDecoration(
                            hintText: 'Enter your custom dhikr',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String result = _selectedDhikr;
                  if (_selectedDhikr == 'Custom Dhikr' && _customController.text.isNotEmpty) {
                    result = _customController.text;
                  }
                  Navigator.pop(context, result);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TasbihStatisticsScreen extends StatelessWidget {
  final TasbihService _tasbihService = TasbihService();

  TasbihStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dhikrCounts = _tasbihService.dhikrCounts;
    
    // Calculate total count (all current dhikr counts)
    final totalCount = dhikrCounts.values.fold(0, (sum, count) => sum + count);
    
    // Calculate today's count (same as total since we're tracking current counts only)
    final todayCount = totalCount;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Statistics'),
        backgroundColor: AppTheme.forestPrimary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              'Total Count',
              totalCount.toString(),
              Icons.countertops,
              AppTheme.primaryGreen,
            ),
            const SizedBox(height: 12),
            _buildStatCard(
              'Today\'s Count',
              todayCount.toString(),
              Icons.today,
              AppTheme.accentGold,
            ),
            const SizedBox(height: 24),
            Text(
              'Individual Dhikr Counts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.forestPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Show all dhikr counts
            ...dhikrCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildDhikrCountCard(entry.key, entry.value),
              );
            }).toList(),
            // Show predefined dhikrs with zero counts
            ..._tasbihService.predefinedDhikr
                .where((dhikr) => !dhikrCounts.containsKey(dhikr))
                .map((dhikr) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildDhikrCountCard(dhikr, 0),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDhikrCountCard(String dhikr, int count) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                dhikr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TasbihSettingsScreen extends StatefulWidget {
  const TasbihSettingsScreen({super.key});

  @override
  State<TasbihSettingsScreen> createState() => _TasbihSettingsScreenState();
}

class _TasbihSettingsScreenState extends State<TasbihSettingsScreen> {
  final TasbihService _tasbihService = TasbihService();
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _hapticEnabled = _tasbihService.hapticEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Settings'),
        backgroundColor: AppTheme.forestPrimary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibration feedback when counting'),
            value: _hapticEnabled,
            activeColor: AppTheme.primaryGreen,
            onChanged: (value) async {
              await _tasbihService.setHapticEnabled(value);
              setState(() {
                _hapticEnabled = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all sessions and reset counter'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Data'),
                  content: const Text(
                    'This will permanently delete all your Tasbih sessions and reset everything. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true) {
                await _tasbihService.clearAllData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All Tasbih data cleared'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}