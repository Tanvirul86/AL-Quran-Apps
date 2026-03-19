import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

enum ReadingMode { day, sepia, night }

/// Reading mode colors
class ReadingModeColors {
  static Color background(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.day:   return const Color(0xFFFAF8F4);
      case ReadingMode.sepia: return const Color(0xFFF5ECD7);
      case ReadingMode.night: return const Color(0xFF141414);
    }
  }

  static Color text(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.day:   return const Color(0xFF1A1A2E);
      case ReadingMode.sepia: return const Color(0xFF3B2A1A);
      case ReadingMode.night: return const Color(0xFFE0D8CC);
    }
  }

  static Color arabic(ReadingMode mode) {
    switch (mode) {
      case ReadingMode.day:   return const Color(0xFF1A1A2E);
      case ReadingMode.sepia: return const Color(0xFF2C1A0E);
      case ReadingMode.night: return const Color(0xFFEDE0C4);
    }
  }
}

/// Shows the reading controls bottom sheet
void showReadingControlsSheet(
  BuildContext context, {
  required ReadingMode currentMode,
  required ValueChanged<ReadingMode> onModeChanged,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ReadingControlsSheet(
      currentMode: currentMode,
      onModeChanged: onModeChanged,
    ),
  );
}

class _ReadingControlsSheet extends StatefulWidget {
  final ReadingMode currentMode;
  final ValueChanged<ReadingMode> onModeChanged;

  const _ReadingControlsSheet({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  State<_ReadingControlsSheet> createState() => _ReadingControlsSheetState();
}

class _ReadingControlsSheetState extends State<_ReadingControlsSheet> {
  late ReadingMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primary = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Reading Controls',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 20),

                // Reading Mode Selector
                Text(
                  'Background Mode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: ReadingMode.values.map((m) {
                    final labels = ['☀️ Day', '📜 Sepia', '🌙 Night'];
                    final backgrounds = [
                      const Color(0xFFFAF8F4),
                      const Color(0xFFF5ECD7),
                      const Color(0xFF1A1A2E),
                    ];
                    final textColors = [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF3B2A1A),
                      const Color(0xFFE0D8CC),
                    ];
                    final isSelected = _mode == m;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _mode = m);
                          widget.onModeChanged(m);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 6),
                          decoration: BoxDecoration(
                            color: backgrounds[m.index],
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primary.withOpacity(0.25),
                                      blurRadius: 8,
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Text(
                                labels[m.index],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: textColors[m.index],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isSelected) ...[
                                const SizedBox(height: 4),
                                Icon(Icons.check_circle,
                                    size: 14, color: primary),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Arabic Font Size slider
                Consumer<SettingsProvider>(
                  builder: (ctx, settings, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Arabic Font Size',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${settings.arabicFontSize.round()}px',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(ctx).copyWith(
                          activeTrackColor: primary,
                          inactiveTrackColor: primary.withOpacity(0.2),
                          thumbColor: primary,
                          overlayColor: primary.withOpacity(0.1),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: settings.arabicFontSize,
                          min: 18,
                          max: 42,
                          divisions: 12,
                          onChanged: (v) {
                            settings.setArabicFontSize(v);
                          },
                        ),
                      ),
                      // Preview text
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: ReadingModeColors.background(_mode),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Uthmanic',
                            fontSize: settings.arabicFontSize,
                            color: ReadingModeColors.arabic(_mode),
                            height: 2.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Translation toggles
                      Text(
                        'Translations',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ToggleChip(
                              label: '🇧🇩 বাংলা',
                              value: settings.showBangla,
                              color: const Color(0xFF006A4E),
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                settings.setShowBangla(v);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ToggleChip(
                              label: '🇬🇧 English',
                              value: settings.showEnglish,
                              color: const Color(0xFF1565C0),
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                settings.setShowEnglish(v);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color color;
  final ValueChanged<bool> onChanged;

  const _ToggleChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: value ? color.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? color : Colors.grey.shade300,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              value ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: value ? color : Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: value ? FontWeight.bold : FontWeight.normal,
                color: value ? color : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
