import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import 'dashboard_screen.dart';
import 'translations_selector_screen.dart';
import 'bookmarks_screen.dart';
import 'settings_screen.dart';
import '../features/ai_assistant/screens/ai_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;

  // Tabs config
  static const _tabs = [
    _TabConfig(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard_rounded, label: 'Home'),
    _TabConfig(icon: Icons.auto_awesome_outlined, selectedIcon: Icons.auto_awesome, label: 'Ask AI'),
    _TabConfig(icon: Icons.translate_outlined, selectedIcon: Icons.translate_rounded, label: 'Translation'),
    _TabConfig(icon: Icons.bookmark_outline, selectedIcon: Icons.bookmark_rounded, label: 'Bookmarks'),
    _TabConfig(icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  List<Widget> _buildScreens() {
    return [
      const DashboardScreen(),
      const AIAssistantScreen(),
      TranslationsSelectorScreen(
        onApplyAndGoReading: () => setState(() => _currentIndex = 0),
      ),
      const BookmarksScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _navController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahs();
    });
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF111827) : Colors.white;
    final inactiveColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _buildScreens(),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: navBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: primary.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final selected = _currentIndex == i;
                  return GestureDetector(
                    onTap: () => _onTabTapped(i),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? primary.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: selected
                            ? Border.all(color: primary.withValues(alpha: 0.25), width: 0.8)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              selected ? tab.selectedIcon : tab.icon,
                              key: ValueKey(selected),
                              color: selected ? primary : inactiveColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                              color: selected ? primary : inactiveColor,
                            ),
                            child: Text(tab.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _TabConfig({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
