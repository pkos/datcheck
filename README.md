datcheck v0.8 - Utility to compare No-Intro or Redump dat files to the disc collection
                and report the matching and missing discs in the collection and extra files.
                This includes exact matches, and fuzzy matching using |Levenshtein edit distance|.

with datcheck [ options ] [dat file ...] [directory ...] [system]

Options (choose 1):
  -miss    write only missing files to log file
  -match   write only matching files and fuzzing matching to log file
  -fuzzy   write only fuzzing matching files to log file
  -all     write missing, matching, and fuzzy matching files to log file

Example:
              datcheck -all "D:/Atari - 2600.dat" "D:/Atari - 2600/Games" "Atari - 2600"

Author:
   Discord - Romeo#3620
   
 SYSTEMS TO SUPPORT | SOURCE 
 ------------------ | -------------- 
 NEC - PC Engine CD - TurboGrafx-CD | Redump
 Nintendo - GameCube | Redump
 Panasonic - 3DO | Redump
 Philips - CDi | Redump
 Sega - Dreamcast | Redump
 Sega - Mega-CD - Sega CD | Redump
 Sega - Saturn | Redump
 SNK - Neo Geo CD | Redump 
 Sony - Playstation | Redump            
 Sony - PlayStation Portable | No-Intro
 
http://redump.org/
https://datomatic.no-intro.org/
