use strict;
use warnings;
use Term::ProgressBar;
use List::Util qw( min max );

#init
my $substringmiss = "-miss";
my $substringmatch = "-match";
my $substringfuzzy = "-fuzzy";
my $substringall = "-all";
my $logmissing = "FALSE";
my $logmatching = "FALSE";
my $logfuzzy = "FALSE";
my $logall = "FALSE";
my $datfile = "";
my $system = "";
my $discdirectory = "";
my $substringh = "-h";
my $bincue = "FALSE";
my $datbincue = "FALSE";
my @linesdat;
my @linesgames;
my @linesmatch;
my @linesmiss;
my @alllinesout;

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "datcheck v1.4 - Utility to compare No-Intro or Redump dat files to the rom or disc collection\n";
    print "                and report the matches and misses in the collection and extra files.\n";
    print "                This includes exact matches, and fuzzy matches using Levenshtein edit distance.\n";
  	print "\n";
	print "with datcheck [ options ] [dat file ...] [directory ...] [system]\n";
	print "\n";
	print "Options:\n";
	print "  -miss    write only missing files to log file\n";
	print "  -match   write only matching files and fuzzing matching to log file\n";
	print "  -fuzzy   write only fuzzing matching files to log file\n";
	print "  -all     write missing, matching, and fuzzy matching files to log file\n";
    print "\n";
	print "Example:\n";
	print '              datcheck -miss -match "D:/Atari - 2600.dat" "D:/Atari - 2600/Games" "Atari - 2600"' . "\n";
	print "\n";
	print "Author:\n";
	print "   Discord - Romeo#3620\n";
	print "\n";
    exit;
  }
  if ($argument =~ /\Q$substringmiss\E/) {
    $logmissing = "TRUE";
  }
  if ($argument =~ /\Q$substringmatch\E/) {
    $logmatching = "TRUE";
  }
  if ($argument =~ /\Q$substringfuzzy\E/) {
    $logfuzzy = "TRUE";
  }
  if ($argument =~ /\Q$substringall\E/) {
    $logall = "TRUE";
  }
}

#set paths and system variables
if (scalar(@ARGV) < 4 or scalar(@ARGV) > 7) {
  print "Invalid command line.. exit\n";
  print "use: datcheck -h\n";
  print "\n";
  exit;
}
$datfile = $ARGV[-3];
$system = $ARGV[-1];
$discdirectory = $ARGV[-2];

#debug
print "dat file: $datfile\n";
print "system: $system\n";
print "game directory: $discdirectory\n";
my $tempstr = "";
if ($logmissing eq "TRUE") {
  $tempstr = "missing ";
}
if ($logmatching eq "TRUE") {
  $tempstr = $tempstr . "matching ";
}
if ($logfuzzy eq "TRUE") {
  $tempstr = $tempstr . "fuzzy matching ";
}
if ($logall eq "TRUE") {
  $tempstr = "missing matching fuzzy matching ";
}
print "log format: " . $tempstr . "and extra files\n";

#exit no parameters
if ($datfile eq "" or $system eq "" or $discdirectory eq "") {
  print "Invalid command line.. exit\n";
  print "use: datcheck -h\n";
  print "\n";
  exit;
}

#read dat file
open(FILE, "<", $datfile) or die "Could not open $datfile\n";
while (my $readline = <FILE>) {
   push(@linesdat, $readline);
   if (index(lc $readline, ".cue") != -1)
   {
      $datbincue = "TRUE";
   }
}
my @sorteddatfile = sort @linesdat;
close (FILE);

#read games directory contents
my $dirname = $discdirectory;
opendir(DIR, $dirname) or die "Could not open $dirname\n";
while (my $filename = readdir(DIR)) {
  if (-d $dirname . "/" . $filename) {
    next;
  } else {
    push(@linesgames, $filename) unless $filename eq '.' or $filename eq '..';
	if (index(lc $filename, ".cue") != -1)
	{
       $bincue = "TRUE";
	}
  }
}
closedir(DIR);

my $romname = "";
my $gamename = "";
my $resultromstart;
my $resultromend;
my $resultgamestart;
my $resultgameend;
my $extpos;
my $extlen;
my $quotepos;
my $match = 0;
my $totalmatches = 0;
my $totalmisses = 0;
my $totalmissesfiles = 0;
my $totalextrafiles = 0;
my $totalfuzzymatches = 0;
my $any_matched;
my $length = 0;
my $i=0;
my $j=0;
my $p=0;
my $q=0;

my @matches;
my @extrafiles;
my @sortedromenames;
my $max = scalar(@sorteddatfile);
my $progress = Term::ProgressBar->new({name => 'matching & missing', count => $max});

#loop though each dat entry
OUTER: foreach my $datline (@sorteddatfile) 
{
   $progress->update($_);
   if (index(lc $datline, "<rom name=") != -1)
   {
	  if (($datbincue eq "TRUE" and index(lc $datline, ".bin") == -1) or $datbincue eq "FALSE")
      {
         $p++;		  
		 #parse rom name
         $resultromstart = index($datline, '<rom name="');
         $resultromend = index($datline, 'size="');
         $extpos = rindex $datline, ".";  
         $quotepos = rindex $datline, '"', $resultromend;
         my $length = ($resultromend)  - ($resultromstart + 12);
         $romname  = substr($datline, $resultromstart + 11, $length - ($quotepos - $extpos + 1));
         $romname =~ s/amp;//g; #clean '&' in the dat file
         push (@sortedromenames, $romname);
	   	   
         foreach my $gameline (@linesgames)
         {
	        #parse game name
            if (index(lc $gameline, ".m3u") == -1)
            {
               $match = 0;
               my $length = length($gameline);
               my $rightdot = rindex($gameline, ".");
               my $suffixlength = $length - $rightdot;
               $gamename  = substr($gameline, 0, $length - $suffixlength);
	
               #check for exact match between dat name and filename
               if ($romname eq $gamename)
               {
                  $match = 1;
                  $totalmatches++;
                  push(@linesmatch, $romname);
		    
                  if ($logmatching eq "TRUE" or $logall eq "TRUE")
                  {
                     push(@alllinesout, ["MATCHED:", $gamename]);
                  }
                  next OUTER;
               }
            }
         }
      }

      #default if no match report missing
      if ($match == 0 and (($datbincue eq "TRUE" and index(lc $datline, ".bin") == -1) or $datbincue eq "FALSE"))
      {
         push(@linesmiss, $romname);
         if ($logmissing eq "TRUE" or $logall eq "TRUE")
         {
            push(@alllinesout, ["MISSING:", $romname]);
         }
         $totalmisses++;
      }
   }
}

my $max2 = scalar(@linesgames);
my $progress2 = Term::ProgressBar->new({name => 'extra files', count => $max2});

#loop through each filename
OUTER2: foreach my $gamematch (@linesgames)
{
	$progress2->update($_);

	#parse game name
	my $length = length($gamematch);
	my $rightdot = rindex($gamematch, ".");
	my $suffixlength = $length - $rightdot;
    my $gamematch2  = substr($gamematch, 0, $length - $suffixlength);
	
	#loop through each matched dat name
	foreach my $rommatch (@linesmatch)
	{
       $match = 0;

       #check for exact match between dat name and filename
	   if ($rommatch eq $gamematch2)
	   {
	      $match = 1;
	      next OUTER2;
	   }
	}
	
	#default if no match report extra file
	if ($match == 0)
	{
	   if ((($bincue eq "TRUE" and index(lc $gamematch, ".m3u") == -1) and index(lc $gamematch, ".bin") == -1) or $bincue eq "FALSE")
	   {
	     push (@alllinesout, ["EXTRA FILE:", $gamematch]);
	     push (@extrafiles, $gamematch2);
	     $totalextrafiles++;
	   }
    }
}

my $max3 = scalar(@extrafiles);
my $progress3 = Term::ProgressBar->new({name => 'fuzzy matching', count => $max3});
	
#loop through each extra file
OUTER3: foreach my $extrafileentry (@extrafiles)
{
   $progress3->update($_);

   if ($logfuzzy eq "TRUE" or $logall eq "TRUE")
   {
	  if (($bincue eq "TRUE" and not index(lc $extrafileentry, ".bin")) or $bincue eq "FALSE")
      {
         #Special case to remove (v1.0) and (no EDC)
	     my $entry = $extrafileentry;
	     $entry =~ s/\(v1.0\)//g;
	     $entry =~ s/\(no EDC\)//g;
		 
	     my $bestmatch = find_most_similar_fuzzy_match($entry, scalar(@sortedromenames), 0, @sortedromenames);
	  
         push(@alllinesout, ["FUZZY MATCH:", "$extrafileentry to: $bestmatch"]);
         $totalfuzzymatches++;
         next OUTER3;
      }      
   }
}

#print total have
my $totalnames = 0;
$totalnames = $p;
print "\ntotal matches: $totalmatches of $totalnames\n";

#print total miss
print "total misses in dat: $totalmisses\n";

#print extra files
print "total extra files in collection: $totalextrafiles\n";

#print total fuzzy have
print "total fuzzy matches to extra files: $totalfuzzymatches\n";

#open log file and print all sorted output
open(LOG, ">", "$system.txt") or die "Could not open $system.txt\n";
print LOG "log format: " . $tempstr . "and extra files\n";
print LOG "total matches: $totalmatches of $totalnames\n";
print LOG "total misses in dat: $totalmisses\n";
print LOG "total extra files in collection: $totalextrafiles\n";
print LOG "total fuzzy matches to extra files: $totalfuzzymatches\n";
print LOG "---------------------------------------\n";
my @sortedalllinesout = sort{$a->[1] cmp $b->[1]} @alllinesout;
for($i=0; $i<=$#sortedalllinesout; $i++)
{
  for($j=0; $j<2; $j++)
  {
    print LOG "$sortedalllinesout[$i][$j] ";
  }
  print LOG "\n";
}
close (LOG);

#print log filename
print "log file: $system.txt\n";
exit;

sub find_most_similar_fuzzy_match
{
   my ($strinput, $lengtharray, $caseSensetive, @strcomparedto) = @_;
   
   my $i;
   my $distance;
   my $mindistance = 1000;
   my $bestfuzzystring;
   
   for ($i = 0; $i < $lengtharray; $i++)
   {
       $distance = levenshtein_distance($strinput, $strcomparedto[$i], $caseSensetive);
       if ($distance < $mindistance)
       {
          $mindistance = $distance;
          $bestfuzzystring = $strcomparedto[$i];
       }
   }
   return $bestfuzzystring;
}


sub levenshtein_distance
{
   my ($strinput, $strcomparedto, $caseSensitive) = @_;
   my $i;
   my $j;
   my $lengthinput = length($strinput);
   my $lengthcompared = length($strcomparedto);
   my $distance;
   my @matrix;
   
   if ($lengthinput == 0 || $lengthcompared == 0)
   {
      $distance = -1;
      return $distance;
   }

   my $input = $strinput;
   my $compared = $strcomparedto;
   if (!$caseSensitive)
   {
      $input = lc($strinput);
      $compared = lc($strcomparedto);
   }

   for ($i = 0; $i < $lengthinput + 1; $i++)
   {
      $matrix[$i][0] = $i;
   }
   
   for ($i = 0; $i < $lengthcompared + 1; $i++)
   {
      $matrix[0][$i] = $i;
   }

   for ($i = 1; $i < $lengthinput + 1; $i++)
   {
      my $si = substr $input, $i - 1, 1;
      for ($j = 1; $j < $lengthcompared + 1; $j++)
      {
         my $tj = substr $compared, $j - 1, 1;
         my $cost = ($si eq $tj) ? 0 : 1;
         my $above = $matrix[$i - 1][$j];
         my $left = $matrix[$i][$j - 1];
         my $diag = $matrix[$i - 1][$j - 1];

         my @array =  ($above + 1, $left + 1, $diag + $cost);
         my $cell = min @array;
         
         if ($i > 1 && $j > 1)
         {
            my $trans = $matrix[$i - 2][$j - 2] + 1;
            if (substr $input, $i - 2, 1 ne substr $compared, $j - 1, 1)
			{
				$trans++;
			}
			
            if (substr $input, $i - 1, 1 ne substr $compared, $j - 2, 1)
			{
               $trans++;
			}
			
            if ($cell > $trans)
			{
               $cell = $trans;
			}
         }
         $matrix[$i][$j] = $cell;
      }
   }
   $distance = $matrix[$lengthinput][$lengthcompared];

   return $distance;
}
