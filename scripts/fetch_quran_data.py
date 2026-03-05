#!/usr/bin/env python3
"""
Quran Data Fetcher Script

This script helps fetch Quran data from public APIs and format it for the app.
Supports multiple sources and formats the data according to the app's structure.

Usage:
    python scripts/fetch_quran_data.py --surah 1 --output assets/data/
    python scripts/fetch_quran_data.py --all --output assets/data/
"""

import json
import requests
import argparse
from pathlib import Path
from typing import List, Dict, Optional

# API Endpoints (public, free-to-use)
QURAN_API_BASE = "https://api.alquran.cloud/v1"
TANZIL_API_BASE = "https://api.tanzil.net/v1"

class QuranDataFetcher:
    """Fetches Quran data from various APIs"""
    
    def __init__(self, output_dir: str = "assets/data"):
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
    
    def fetch_surah(self, surah_number: int, 
                   include_translations: bool = True) -> Optional[Dict]:
        """
        Fetch a single surah with translations
        
        Args:
            surah_number: Surah number (1-114)
            include_translations: Whether to include English and Bangla translations
        
        Returns:
            Dictionary with surah data or None if error
        """
        try:
            # Fetch Arabic text
            arabic_url = f"{QURAN_API_BASE}/surah/{surah_number}"
            response = requests.get(arabic_url, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            if not data.get('data'):
                return None
            
            surah_data = data['data']
            ayahs = []
            
            for idx, ayah_data in enumerate(surah_data.get('ayahs', []), 1):
                ayah = {
                    "surahNumber": surah_number,
                    "ayahNumber": idx,
                    "globalAyahNumber": ayah_data.get('number', 0),
                    "arabicText": ayah_data.get('text', ''),
                }
                
                # Add translations if requested
                if include_translations:
                    # English translation (Sahih International)
                    english_url = f"{QURAN_API_BASE}/surah/{surah_number}/en.asad"
                    try:
                        eng_response = requests.get(english_url, timeout=10)
                        if eng_response.status_code == 200:
                            eng_data = eng_response.json()
                            if eng_data.get('data') and eng_data['data'].get('ayahs'):
                                eng_ayahs = eng_data['data']['ayahs']
                                if idx <= len(eng_ayahs):
                                    ayah["englishTranslation"] = eng_ayahs[idx-1].get('text', '')
                    except:
                        ayah["englishTranslation"] = ""
                    
                    # Bangla translation (placeholder - you may need a different API)
                    # Note: You'll need to find a reliable Bangla translation API
                    ayah["banglaTranslation"] = ""  # TODO: Add Bangla translation source
                
                ayahs.append(ayah)
            
            return {
                "surah": surah_data,
                "ayahs": ayahs
            }
            
        except Exception as e:
            print(f"Error fetching surah {surah_number}: {e}")
            return None
    
    def save_surah(self, surah_number: int, data: Dict):
        """Save surah data to JSON file"""
        output_file = self.output_dir / f"surah_{surah_number}.json"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(data['ayahs'], f, ensure_ascii=False, indent=2)
        
        print(f"Saved surah {surah_number} to {output_file}")
    
    def fetch_all_surahs(self, include_translations: bool = True):
        """Fetch all 114 surahs"""
        print("Fetching all surahs... This may take a while.")
        
        for surah_num in range(1, 115):
            print(f"Fetching surah {surah_num}...")
            data = self.fetch_surah(surah_num, include_translations)
            if data:
                self.save_surah(surah_num, data)
            else:
                print(f"Failed to fetch surah {surah_num}")
            
            # Be respectful to the API - add delay
            import time
            time.sleep(0.5)

def main():
    parser = argparse.ArgumentParser(description='Fetch Quran data for the app')
    parser.add_argument('--surah', type=int, help='Surah number to fetch (1-114)')
    parser.add_argument('--all', action='store_true', help='Fetch all surahs')
    parser.add_argument('--output', type=str, default='assets/data', 
                       help='Output directory for JSON files')
    parser.add_argument('--no-translations', action='store_true',
                       help='Skip fetching translations')
    
    args = parser.parse_args()
    
    fetcher = QuranDataFetcher(args.output)
    
    if args.all:
        fetcher.fetch_all_surahs(not args.no_translations)
    elif args.surah:
        if 1 <= args.surah <= 114:
            data = fetcher.fetch_surah(args.surah, not args.no_translations)
            if data:
                fetcher.save_surah(args.surah, data)
            else:
                print(f"Failed to fetch surah {args.surah}")
        else:
            print("Surah number must be between 1 and 114")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
