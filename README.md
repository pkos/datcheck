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