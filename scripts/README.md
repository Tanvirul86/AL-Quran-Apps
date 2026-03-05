# Quran Data Fetching Scripts

## Overview

These scripts help you populate the app with complete Quran data from verified sources.

## Python Script

### Prerequisites

```bash
pip install requests
```

### Usage

**Fetch a single surah:**
```bash
python scripts/fetch_quran_data.py --surah 1 --output assets/data/
```

**Fetch all surahs:**
```bash
python scripts/fetch_quran_data.py --all --output assets/data/
```

**Fetch without translations (Arabic only):**
```bash
python scripts/fetch_quran_data.py --all --no-translations
```

## Important Notes

### Data Sources

1. **Arabic Text**: 
   - Uses Al-Quran Cloud API (api.alquran.cloud)
   - Provides authentic Uthmani text
   - Free and reliable

2. **English Translation**:
   - Currently uses Asad translation
   - You can modify the script to use other translations
   - Available translations: Sahih International, Yusuf Ali, Pickthall, etc.

3. **Bangla Translation**:
   - **IMPORTANT**: The script currently has a placeholder for Bangla
   - You need to find a reliable Bangla translation API or source
   - Recommended: Use published translations and add manually
   - Or find a Bangla translation API and update the script

### Manual Data Addition

For the most authentic data, consider:

1. **Download from verified sources**:
   - King Fahd Complex (Madinah Mushaf)
   - Tanzil Project (tanzil.net)
   - Quran.com

2. **Format the data** according to the JSON structure:
   ```json
   [
     {
       "surahNumber": 1,
       "ayahNumber": 1,
       "globalAyahNumber": 1,
       "arabicText": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
       "englishTranslation": "...",
       "banglaTranslation": "..."
     }
   ]
   ```

3. **Save as** `assets/data/surah_<number>.json`

### Verification

After fetching data:

1. **Verify Arabic text** against authoritative sources
2. **Check translations** for accuracy
3. **Test in the app** to ensure proper rendering
4. **Validate JSON** format

## Alternative: Manual Data Entry

For maximum authenticity, consider manually adding data from:

- **Arabic**: Madinah Mushaf (King Fahd Complex)
- **English**: Sahih International, Yusuf Ali
- **Bangla**: Mufti Taqi Usmani, Dr. Muhiuddin Khan

This ensures 100% accuracy and proper licensing.

## License Considerations

- Ensure you have proper rights to use translations
- Some translations may require attribution
- Check copyright status before using in production
