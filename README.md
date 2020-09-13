datcheck v0.6 - Utility to compare No-Intro or Redump dat files to the disc collection
                and report the matching and missing discs in the collection, and extra files.

with datcheck [ options ] [dat file ...] [directory ...] [system]

Options (choose 1):
  -miss    write only missing files to log file
  -match   write only matching files to log file
  -both    write both missing and matching files to log file

Example:
              datcheck -miss "D:/Atari - 2600.dat" "D:/Atari - 2600/Games" "Atari - 2600"

Author:
   Discord - Romeo#3620