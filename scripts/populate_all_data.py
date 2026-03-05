#!/usr/bin/env python3
"""
Complete Quran Data Population Script
Fetches all 114 surahs with Arabic, English, and Bangla translations
Ready for Play Store publishing
"""

import json
import requests
import time
from pathlib import Path
from typing import Dict, Optional, List

class CompleteQuranDataFetcher:
    """Fetches complete Quran data with all translations"""
    
    def __init__(self, output_dir: str = "assets/data"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'QuranApp/1.0 (Educational Purpose)'
        })
    
    def fetch_arabic_text(self, surah_number: int) -> Optional[List[Dict]]:
        """Fetch Arabic text from Al-Quran Cloud API"""
        try:
            url = f"https://api.alquran.cloud/v1/surah/{surah_number}"
            response = self.session.get(url, timeout=15)
            response.raise_for_status()
            data = response.json()
            
            if data.get('code') == 200 and data.get('data'):
                ayahs = []
                for ayah in data['data'].get('ayahs', []):
                    ayahs.append({
                        "number": ayah.get('number', 0),
                        "text": ayah.get('text', '')
                    })
                return ayahs
        except Exception as e:
            print(f"Error fetching Arabic for surah {surah_number}: {e}")
        return None
    
    def fetch_english_translation(self, surah_number: int) -> Optional[List[Dict]]:
        """Fetch English translation (Sahih International)"""
        translations = [
            ('en.sahih', 'Sahih International'),
            ('en.asad', 'Asad'),
            ('en.yusufali', 'Yusuf Ali'),
        ]
        
        for trans_code, name in translations:
            try:
                url = f"https://api.alquran.cloud/v1/surah/{surah_number}/{trans_code}"
                response = self.session.get(url, timeout=15)
                if response.status_code == 200:
                    data = response.json()
                    if data.get('code') == 200 and data.get('data'):
                        ayahs = []
                        for ayah in data['data'].get('ayahs', []):
                            ayahs.append({
                                "number": ayah.get('number', 0),
                                "text": ayah.get('text', '')
                            })
                        print(f"  ✓ English ({name})")
                        return ayahs
            except Exception as e:
                continue
        
        return None
    
    def fetch_bangla_translation(self, surah_number: int) -> Optional[List[Dict]]:
        """Fetch Bangla translation"""
        # Try multiple sources for Bangla translation
        sources = [
            f"https://api.alquran.cloud/v1/surah/{surah_number}/bn.bengali",
            f"https://raw.githubusercontent.com/quran/data/main/translations/bn/bengali/{surah_number}.json",
        ]
        
        for url in sources:
            try:
                response = self.session.get(url, timeout=15)
                if response.status_code == 200:
                    data = response.json()
                    
                    # Handle different response formats
                    if isinstance(data, dict) and data.get('data'):
                        ayahs = []
                        for ayah in data['data'].get('ayahs', []):
                            ayahs.append({
                                "number": ayah.get('number', 0),
                                "text": ayah.get('text', '')
                            })
                        print(f"  ✓ Bangla")
                        return ayahs
                    elif isinstance(data, list):
                        # Direct list format
                        print(f"  ✓ Bangla")
                        return data
            except Exception as e:
                continue
        
        # If API fails, return empty strings (to be filled manually)
        print(f"  ⚠ Bangla translation not available from API")
        return None
    
    def fetch_complete_surah(self, surah_number: int) -> Optional[List[Dict]]:
        """Fetch complete surah with all translations"""
        print(f"Fetching surah {surah_number}...")
        
        # Fetch Arabic text
        arabic_ayahs = self.fetch_arabic_text(surah_number)
        if not arabic_ayahs:
            print(f"  ✗ Failed to fetch Arabic text")
            return None
        
        print(f"  ✓ Arabic ({len(arabic_ayahs)} ayahs)")
        
        # Fetch English translation
        english_ayahs = self.fetch_english_translation(surah_number)
        
        # Fetch Bangla translation
        bangla_ayahs = self.fetch_bangla_translation(surah_number)
        
        # Combine data
        result = []
        global_ayah_num = arabic_ayahs[0].get('number', 0) if arabic_ayahs else 0
        
        for idx, arabic_ayah in enumerate(arabic_ayahs, 1):
            ayah_data = {
                "surahNumber": surah_number,
                "ayahNumber": idx,
                "globalAyahNumber": arabic_ayah.get('number', global_ayah_num + idx - 1),
                "arabicText": arabic_ayah.get('text', '').strip(),
            }
            
            # Add English translation
            if english_ayahs and idx <= len(english_ayahs):
                ayah_data["englishTranslation"] = english_ayahs[idx-1].get('text', '').strip()
            else:
                ayah_data["englishTranslation"] = ""
            
            # Add Bangla translation
            if bangla_ayahs and idx <= len(bangla_ayahs):
                if isinstance(bangla_ayahs[idx-1], dict):
                    ayah_data["banglaTranslation"] = bangla_ayahs[idx-1].get('text', '').strip()
                else:
                    ayah_data["banglaTranslation"] = str(bangla_ayahs[idx-1]).strip()
            else:
                ayah_data["banglaTranslation"] = ""
            
            result.append(ayah_data)
        
        return result
    
    def save_surah(self, surah_number: int, ayahs: List[Dict]):
        """Save surah data to JSON file"""
        output_file = self.output_dir / f"surah_{surah_number}.json"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(ayahs, f, ensure_ascii=False, indent=2)
        
        print(f"  ✓ Saved to {output_file.name}")
    
    def fetch_all_surahs(self):
        """Fetch all 114 surahs"""
        print("=" * 60)
        print("Quran Data Population Script")
        print("Fetching all 114 surahs with translations...")
        print("=" * 60)
        print()
        
        success_count = 0
        failed_surahs = []
        
        for surah_num in range(1, 115):
            try:
                ayahs = self.fetch_complete_surah(surah_num)
                if ayahs:
                    self.save_surah(surah_num, ayahs)
                    success_count += 1
                else:
                    failed_surahs.append(surah_num)
                    print(f"  ✗ Failed to fetch surah {surah_num}")
                
                # Be respectful to API - add delay
                time.sleep(0.8)
                
            except Exception as e:
                print(f"  ✗ Error: {e}")
                failed_surahs.append(surah_num)
                time.sleep(1)
        
        print()
        print("=" * 60)
        print(f"Completed: {success_count}/114 surahs fetched successfully")
        if failed_surahs:
            print(f"Failed surahs: {failed_surahs}")
            print("You may need to fetch these manually or retry later.")
        print("=" * 60)

def main():
    import argparse
    
    parser = argparse.ArgumentParser(
        description='Fetch complete Quran data for Play Store publishing'
    )
    parser.add_argument(
        '--output', 
        type=str, 
        default='assets/data',
        help='Output directory for JSON files'
    )
    parser.add_argument(
        '--surah',
        type=int,
        help='Fetch single surah (1-114)'
    )
    
    args = parser.parse_args()
    
    fetcher = CompleteQuranDataFetcher(args.output)
    
    if args.surah:
        if 1 <= args.surah <= 114:
            ayahs = fetcher.fetch_complete_surah(args.surah)
            if ayahs:
                fetcher.save_surah(args.surah, ayahs)
            else:
                print(f"Failed to fetch surah {args.surah}")
        else:
            print("Surah number must be between 1 and 114")
    else:
        fetcher.fetch_all_surahs()

if __name__ == "__main__":
    main()
