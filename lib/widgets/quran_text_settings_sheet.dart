import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class QuranTextSettingsSheet extends StatelessWidget {
  const QuranTextSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quran Text Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customize your reading experience with different scripts and Tajweed rules.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                  ),
            ),
            const SizedBox(height: 32),
            
            // Script Type Selection
            _buildSectionTitle(context, 'Arabic Script Type'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ScriptTypeCard(
                    title: 'Uthmani',
                    subtitle: 'Madani Mushaf',
                    isSelected: settings.scriptType == QuranScriptType.uthmani,
                    onTap: () => settings.setScriptType(QuranScriptType.uthmani),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ScriptTypeCard(
                    title: 'IndoPak',
                    subtitle: 'South Asian Style',
                    isSelected: settings.scriptType == QuranScriptType.indopak,
                    onTap: () => settings.setScriptType(QuranScriptType.indopak),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Tajweed Toggle
            _buildSectionTitle(context, 'Tajweed Color Coding'),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Enable Tajweed Colors'),
              subtitle: const Text('Highlight rules like Ghunnah, Qalqalah, etc.'),
              value: settings.isTajweedEnabled,
              onChanged: (value) => settings.setTajweedEnabled(value),
              activeColor: Theme.of(context).primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            if (settings.isTajweedEnabled) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _TajweedLegendChip(
                    label: 'Ghunnah',
                    color: Color(0xFF16A085),
                  ),
                  _TajweedLegendChip(
                    label: 'Qalqalah',
                    color: Color(0xFF2980B9),
                  ),
                  _TajweedLegendChip(
                    label: 'Ikhfa',
                    color: Color(0xFFE67E22),
                  ),
                  _TajweedLegendChip(
                    label: 'Madd',
                    color: Color(0xFFE74C3C),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Preview
            _buildSectionTitle(context, 'Preview'),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  ),
                ),
                child: const Text(
                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                  style: TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle(context, 'Licensed Text Sources'),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                ),
              ),
              child: Text(
                'Arabic script data is sourced from verified providers such as Quran.com and Tanzil.net. Please keep attribution and license terms when packaging or redistributing text datasets.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.75),
                      height: 1.4,
                    ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Settings'),
              ),
            ),
            const SizedBox(height: 16),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}

class _TajweedLegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TajweedLegendChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScriptTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScriptTypeCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.15)
              : (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
