import 'package:flutter/material.dart';

/// Juz navigation widget for quick access to Quran divisions
class JuzNavigationWidget extends StatelessWidget {
  final Function(int juzNumber) onJuzSelected;

  const JuzNavigationWidget({
    super.key,
    required this.onJuzSelected,
  });

  // Juz starting surahs (simplified mapping)
  static const Map<int, Map<String, dynamic>> juzInfo = {
    1: {'surah': 1, 'ayah': 1, 'name': 'Alif Lam Mim'},
    2: {'surah': 2, 'ayah': 142, 'name': 'Sayaqul'},
    3: {'surah': 2, 'ayah': 253, 'name': 'Tilka Rusul'},
    4: {'surah': 3, 'ayah': 93, 'name': 'Lan Tana Lu'},
    5: {'surah': 4, 'ayah': 24, 'name': 'Wal Muhsanat'},
    6: {'surah': 4, 'ayah': 148, 'name': 'La Yuhibbullah'},
    7: {'surah': 5, 'ayah': 82, 'name': 'Wa Iza Samiu'},
    8: {'surah': 6, 'ayah': 111, 'name': 'Wa Lau Annana'},
    9: {'surah': 7, 'ayah': 88, 'name': 'Qal Almalao'},
    10: {'surah': 8, 'ayah': 41, 'name': 'Walamoo'},
    11: {'surah': 9, 'ayah': 93, 'name': 'Yatazeroon'},
    12: {'surah': 11, 'ayah': 6, 'name': 'Wa Mamin'},
    13: {'surah': 12, 'ayah': 53, 'name': 'Wa Ma Ubri'},
    14: {'surah': 15, 'ayah': 1, 'name': 'Rubama'},
    15: {'surah': 17, 'ayah': 1, 'name': 'Subhana Allazi'},
    16: {'surah': 18, 'ayah': 75, 'name': 'Qal Alam'},
    17: {'surah': 21, 'ayah': 1, 'name': 'Aqtaraba'},
    18: {'surah': 23, 'ayah': 1, 'name': 'Qad Aflaha'},
    19: {'surah': 25, 'ayah': 21, 'name': 'Wa Qalallazina'},
    20: {'surah': 27, 'ayah': 56, 'name': 'Amman Khalaqa'},
    21: {'surah': 29, 'ayah': 46, 'name': 'Utlu Ma Oohi'},
    22: {'surah': 33, 'ayah': 31, 'name': 'Wa Man Yaqnut'},
    23: {'surah': 36, 'ayah': 28, 'name': 'Wa Mali'},
    24: {'surah': 39, 'ayah': 32, 'name': 'Faman Azlam'},
    25: {'surah': 41, 'ayah': 47, 'name': 'Ilaihi Yuraddo'},
    26: {'surah': 46, 'ayah': 1, 'name': 'Ha Mim'},
    27: {'surah': 51, 'ayah': 31, 'name': 'Qala Fama'},
    28: {'surah': 58, 'ayah': 1, 'name': 'Qad Samia'},
    29: {'surah': 67, 'ayah': 1, 'name': 'Tabarakalazi'},
    30: {'surah': 78, 'ayah': 1, 'name': 'Amma Yatasa aloon'},
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jump to Juz',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Juz grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: 30,
              itemBuilder: (context, index) {
                final juzNumber = index + 1;
                final info = juzInfo[juzNumber]!;
                
                return InkWell(
                  onTap: () {
                    onJuzSelected(juzNumber);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Juz',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$juzNumber',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Flexible(
                          child: Text(
                            'Surah ${info['surah']}',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Show Juz navigation bottom sheet
void showJuzNavigation(
  BuildContext context, {
  required Function(int juzNumber) onJuzSelected,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => JuzNavigationWidget(
      onJuzSelected: onJuzSelected,
    ),
  );
}
