import 'package:flutter/material.dart';

/// Advanced Navigation Widget - Juz/Hizb/Ruku navigation and quick ayah reference
class AdvancedNavigationWidget extends StatefulWidget {
  final Function(int surah, int ayah)? onNavigate;

  const AdvancedNavigationWidget({
    super.key,
    this.onNavigate,
  });

  @override
  State<AdvancedNavigationWidget> createState() =>
      _AdvancedNavigationWidgetState();
}

class _AdvancedNavigationWidgetState extends State<AdvancedNavigationWidget> {
  final TextEditingController _referenceController = TextEditingController();

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Quick Reference Input
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Ayah Reference',
                hintText: 'e.g., 2:255',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _navigateToReference,
                ),
              ),
              onSubmitted: (_) => _navigateToReference(),
            ),

            const SizedBox(height: 16),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showJuzNavigation(context),
                    icon: const Icon(Icons.book),
                    label: const Text('Juz'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showHizbNavigation(context),
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Hizb'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRukuNavigation(context),
                    icon: const Icon(Icons.layers),
                    label: const Text('Ruku'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReference() {
    final reference = _referenceController.text.trim();
    final parts = reference.split(':');

    if (parts.length == 2) {
      final surah = int.tryParse(parts[0]);
      final ayah = int.tryParse(parts[1]);

      if (surah != null && ayah != null && surah >= 1 && surah <= 114) {
        widget.onNavigate?.call(surah, ayah);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Navigating to Surah $surah, Ayah $ayah')),
        );
      } else {
        _showError('Invalid reference format');
      }
    } else {
      _showError('Use format: Surah:Ayah (e.g., 2:255)');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showJuzNavigation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Juz'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 30,
            itemBuilder: (context, index) {
              final juzNumber = index + 1;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  final startingAyah = _getJuzStartingAyah(juzNumber);
                  widget.onNavigate?.call(startingAyah.surah, startingAyah.ayah);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Navigating to Juz $juzNumber')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor),
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Text(
                      '$juzNumber',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHizbNavigation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Hizb'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: 60, // 30 Juz × 2 Hizb per Juz
            itemBuilder: (context, index) {
              final hizbNumber = index + 1;
              final juzNumber = (hizbNumber / 2).ceil();
              return ListTile(
                leading: CircleAvatar(
                  child: Text('$hizbNumber'),
                ),
                title: Text('Hizb $hizbNumber'),
                subtitle: Text('Juz $juzNumber'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hizb $hizbNumber selected')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRukuNavigation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Ruku'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: Colors.blue),
                SizedBox(height: 16),
                Text(
                  'Ruku navigation coming soon!',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Quran has 558 Rukus across 114 Surahs',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Helper: Get starting ayah for each Juz
  ({int surah, int ayah}) _getJuzStartingAyah(int juz) {
    final juzStarts = {
      1: (surah: 1, ayah: 1),
      2: (surah: 2, ayah: 142),
      3: (surah: 2, ayah: 253),
      4: (surah: 3, ayah: 93),
      5: (surah: 4, ayah: 24),
      6: (surah: 4, ayah: 148),
      7: (surah: 5, ayah: 82),
      8: (surah: 6, ayah: 111),
      9: (surah: 7, ayah: 88),
      10: (surah: 8, ayah: 41),
      11: (surah: 9, ayah: 93),
      12: (surah: 11, ayah: 6),
      13: (surah: 12, ayah: 53),
      14: (surah: 15, ayah: 1),
      15: (surah: 17, ayah: 1),
      16: (surah: 18, ayah: 75),
      17: (surah: 21, ayah: 1),
      18: (surah: 23, ayah: 1),
      19: (surah: 25, ayah: 21),
      20: (surah: 27, ayah: 56),
      21: (surah: 29, ayah: 46),
      22: (surah: 33, ayah: 31),
      23: (surah: 36, ayah: 28),
      24: (surah: 39, ayah: 32),
      25: (surah: 41, ayah: 47),
      26: (surah: 46, ayah: 1),
      27: (surah: 51, ayah: 31),
      28: (surah: 58, ayah: 1),
      29: (surah: 67, ayah: 1),
      30: (surah: 78, ayah: 1),
    };

    return juzStarts[juz] ?? (surah: 1, ayah: 1);
  }
}
