Program
-------

datcheck v1.4 - Utility to compare No-Intro or Redump dat files to the rom or disc collection
                and report the matches and misses in the collection and extra files.
                This includes exact matches, and fuzzy matches using Levenshtein edit distance.

with datcheck [ options ] [dat file ...] [directory ...] [system]

Options:
  -miss    write only missing files to log file
  -match   write only matching files and fuzzing matching to log file
  -fuzzy   write only fuzzing matching files to log file
  -all     write missing, matching, and fuzzy matching files to log file

Example:
              datcheck -miss -match "D:/Atari - 2600.dat" "D:/Atari - 2600/Games" "Atari - 2600"

Author:
   Discord - Romeo#3620

Systems
-------

 DISC SYSTEMS TO SUPPORT | SOURCE 
 ----------------------- | -------------- 
 NEC - PC Engine CD - TurboGrafx-CD | Redump
 Nintendo - GameCube | Redump
 Panasonic - 3DO | Redump
 Philips - CDi | Redump
 Sega - Dreamcast | Redump
 Sega - Mega-CD - Sega CD | Redump
 Sega - Saturn | Redump
 SNK - Neo Geo CD | Redump 
 Sony - Playstation | Redump            
 Sony - PlayStation Portable | Redump, No-Intro

 ROM SYSTEMS TO SUPPORT | SOURCE
 ---------------------- | --------------
 Atari - 2600 | No-Intro
 Atari - 5200 | No-Intro
 Atari - 7800 | No-Intro
 Atari - Jaguar | No-Intro
 Atari - Lynx | No-Intro
 Atari - ST | No-Intro
 Bandai - WonderSwan | No-Intro
 Bandai - WonderSwan Color | No-Intro
 Coleco - ColecoVision | No-Intro
 Commodore - 64 | No-Intro
 Commodore - Amiga | No-Intro
 Commodore - PLUS4 | No-Intro
 Commodore - VIC-20 | No-Intro
 Fairchild - Channel F | No-Intro
 GCE - Vectrex | No-Intro
 Magnavox - Odyssey2 | No-Intro
 Mattel - Intellivision | No-Intro
 Microsoft - MSX | No-Intro
 Microsoft - MSX2 | No-Intro
 NEC - PC Engine - TurboGrafx 16 | No-Intro
 NEC - PC Engine SuperGrafx | No-Intro
 Nintendo - Game Boy | No-Intro
 Nintendo - Game Boy Advance | No-Intro
 Nintendo - Game Boy Color | No-Intro
 Nintendo - Nintendo 3DS | No-Intro
 Nintendo - Nintendo 64 | No-Intro
 Nintendo - Nintendo DS | No-Intro
 Nintendo - Nintendo DSi | No-Intro
 Nintendo - Nintendo Entertainment System | No-Intro
 Nintendo - Pokemon Mini | No-Intro
 Nintendo - Satellaview | No-Intro
 Nintendo - Sufami Turbo | No-Intro
 Nintendo - Super Nintendo Entertainment System | No-Intro
 Nintendo - Virtual Boy | No-Intro
 Philips - Videopac+ | No-Intro
 Sega - 32X | No-Intro
 Sega - Game Gear | No-Intro
 Sega - Master System - Mark III | No-Intro
 Sega - Mega Drive - Genesis | No-Intro
 Sega - PICO | No-Intro
 Sega - SG-1000 | No-Intro
 SNK - Neo Geo Pocket | No-Intro
 SNK - Neo Geo Pocket Color | No-Intro
 
Dats
----
http://redump.org/

https://datomatic.no-intro.org/

Change log
----------
v1.1 to v1.2 - The Levenshtein distance function was changed from the faster
               perl module String::Approx to the more acurately modeled, but
               slower built-in Levenshtein distance function.

v1.2 to v1.3 - Expanded to roms as well as discs.
			   
