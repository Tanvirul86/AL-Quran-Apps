#!/usr/bin/env python3
"""
Data Verification Script
Verifies that all Quran data is properly populated
"""

import json
from pathlib import Path
from typing import Dict, List

def verify_surahs_file(data_dir: Path) -> bool:
    """Verify surahs.json exists and has 114 surahs"""
    surahs_file = data_dir / "surahs.json"
    
    if not surahs_file.exists():
        print("❌ surahs.json not found")
        return False
    
    try:
        with open(surahs_file, 'r', encoding='utf-8') as f:
            surahs = json.load(f)
        
        if len(surahs) != 114:
            print(f"❌ Expected 114 surahs, found {len(surahs)}")
            return False
        
        print(f"✅ surahs.json: {len(surahs)} surahs found")
        return True
    except Exception as e:
        print(f"❌ Error reading surahs.json: {e}")
        return False

def verify_surah_file(data_dir: Path, surah_num: int) -> Dict:
    """Verify a single surah file"""
    surah_file = data_dir / f"surah_{surah_num}.json"
    
    result = {
        "exists": False,
        "valid": False,
        "ayah_count": 0,
        "has_arabic": False,
        "has_english": False,
        "has_bangla": False,
        "errors": []
    }
    
    if not surah_file.exists():
        result["errors"].append("File not found")
        return result
    
    result["exists"] = True
    
    try:
        with open(surah_file, 'r', encoding='utf-8') as f:
            ayahs = json.load(f)
        
        if not isinstance(ayahs, list):
            result["errors"].append("Invalid format: not a list")
            return result
        
        result["ayah_count"] = len(ayahs)
        
        if len(ayahs) == 0:
            result["errors"].append("Empty file")
            return result
        
        # Check first ayah for required fields
        first_ayah = ayahs[0]
        required_fields = ["surahNumber", "ayahNumber", "arabicText"]
        
        for field in required_fields:
            if field not in first_ayah:
                result["errors"].append(f"Missing field: {field}")
        
        # Check for translations
        if "arabicText" in first_ayah and first_ayah["arabicText"].strip():
            result["has_arabic"] = True
        
        if "englishTranslation" in first_ayah and first_ayah["englishTranslation"].strip():
            result["has_english"] = True
        
        if "banglaTranslation" in first_ayah and first_ayah["banglaTranslation"].strip():
            result["has_bangla"] = True
        
        # Verify all ayahs
        for idx, ayah in enumerate(ayahs):
            if ayah.get("surahNumber") != surah_num:
                result["errors"].append(f"Ayah {idx+1}: Wrong surah number")
            if ayah.get("ayahNumber") != idx + 1:
                result["errors"].append(f"Ayah {idx+1}: Wrong ayah number")
            if not ayah.get("arabicText", "").strip():
                result["errors"].append(f"Ayah {idx+1}: Missing Arabic text")
        
        result["valid"] = len(result["errors"]) == 0
        
    except json.JSONDecodeError as e:
        result["errors"].append(f"Invalid JSON: {e}")
    except Exception as e:
        result["errors"].append(f"Error: {e}")
    
    return result

def verify_all_data(data_dir: str = "assets/data"):
    """Verify all Quran data"""
    data_path = Path(data_dir)
    
    if not data_path.exists():
        print(f"❌ Data directory not found: {data_dir}")
        return False
    
    print("=" * 60)
    print("Quran Data Verification")
    print("=" * 60)
    print()
    
    # Verify surahs.json
    if not verify_surahs_file(data_path):
        return False
    
    print()
    print("Verifying surah files...")
    print()
    
    missing_files = []
    invalid_files = []
    stats = {
        "total": 0,
        "valid": 0,
        "has_arabic": 0,
        "has_english": 0,
        "has_bangla": 0,
    }
    
    for surah_num in range(1, 115):
        result = verify_surah_file(data_path, surah_num)
        stats["total"] += 1
        
        if not result["exists"]:
            missing_files.append(surah_num)
            print(f"❌ Surah {surah_num:3d}: Missing")
        elif not result["valid"]:
            invalid_files.append(surah_num)
            print(f"⚠️  Surah {surah_num:3d}: Invalid - {', '.join(result['errors'][:2])}")
        else:
            stats["valid"] += 1
            if result["has_arabic"]:
                stats["has_arabic"] += 1
            if result["has_english"]:
                stats["has_english"] += 1
            if result["has_bangla"]:
                stats["has_bangla"] += 1
            
            status = "✅"
            if not result["has_bangla"]:
                status = "⚠️ "
            print(f"{status} Surah {surah_num:3d}: {result['ayah_count']:3d} ayahs | "
                  f"AR:{'✓' if result['has_arabic'] else '✗'} "
                  f"EN:{'✓' if result['has_english'] else '✗'} "
                  f"BN:{'✓' if result['has_bangla'] else '✗'}")
    
    print()
    print("=" * 60)
    print("Verification Summary")
    print("=" * 60)
    print(f"Total surahs: {stats['total']}")
    print(f"Valid files: {stats['valid']}")
    print(f"Missing files: {len(missing_files)}")
    print(f"Invalid files: {len(invalid_files)}")
    print()
    print(f"Arabic text: {stats['has_arabic']}/{stats['total']}")
    print(f"English translation: {stats['has_english']}/{stats['total']}")
    print(f"Bangla translation: {stats['has_bangla']}/{stats['total']}")
    print()
    
    if missing_files:
        print(f"Missing surahs: {', '.join(map(str, missing_files[:10]))}"
              + (f" ... and {len(missing_files)-10} more" if len(missing_files) > 10 else ""))
    
    if invalid_files:
        print(f"Invalid surahs: {', '.join(map(str, invalid_files[:10]))}"
              + (f" ... and {len(invalid_files)-10} more" if len(invalid_files) > 10 else ""))
    
    print()
    
    if stats["valid"] == 114 and stats["has_arabic"] == 114:
        print("✅ All data is ready!")
        return True
    else:
        print("⚠️  Some data is missing or incomplete")
        print("   Run the data population script to fix this.")
        return False

if __name__ == "__main__":
    import sys
    data_dir = sys.argv[1] if len(sys.argv) > 1 else "assets/data"
    verify_all_data(data_dir)
