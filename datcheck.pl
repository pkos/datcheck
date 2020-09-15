use strict;
use warnings;
use Term::ProgressBar;
use String::Approx 'amatch';
use String::Approx 'adistr';

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
my @linesdat;
my @linesgames;
my @linesmatch;
my @linesmiss;
my @alllinesout;

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "datcheck v1.0 - Utility to compare No-Intro or Redump dat files to the disc collection\n";
    print "                and report the matching and missing discs in the collection and extra files.\n";
    print "                This includes exact matches, and fuzzy matching using |Levenshtein edit distance|.\n";
  	print "\n";
	print "with datcheck [ options ] [dat file ...] [directory ...] [system]\n";
	print "\n";
	print "Options (choose 1):\n";
	print "  -miss    write only missing files to log file\n";
	print "  -match   write only matching files and fuzzing matching to log file\n";
	print "  -fuzzy   write only fuzzing matching files to log file\n";
	print "  -all     write missing, matching, and fuzzy matching files to log file\n";
    print "\n";
	print "Example:\n";
	print '              datcheck -miss "D:/Atari - 2600.dat" "D:/Atari - 2600/Games" "Atari - 2600"' . "\n";
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
if (scalar(@ARGV) < 4 or scalar(@ARGV) > 4) {
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
print "disc directory: $discdirectory\n";
my $tempstr;
if ($logmissing eq "TRUE") {
  $tempstr = "missing files";
} elsif ($logmatching eq "TRUE") {
  $tempstr = "matching files";
} elsif ($logfuzzy eq "TRUE") {
  $tempstr = "fuzzy matching files";
} elsif ($logall eq "TRUE") {
  $tempstr = "matching and missing files, extra files, and fuzzy matching";
}
print "log format: " . $tempstr . "\n";

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
  #print "$readline\n";
}
my @sorteddatfile = sort @linesdat;
close (FILE);

#read games directory contents
my $dirname = $discdirectory;
opendir(DIR, $dirname) or die "Could not open $dirname\n";
while (my $filename = readdir(DIR)) {
  if (-d $filename) {
    next;
  } else {
    push(@linesgames, $filename) unless $filename eq '.' or $filename eq '..';
    #print "$filename\n";    
  }
}
closedir(DIR);

my $romname = "";
my $gamename = "";
my $resultromstart;
my $resultromend;
my $resultgamestart;
my $resultgameend;
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
my @matches;
my @extrafiles;
my @sortedromenames;
my $max = scalar(@sorteddatfile);
my $progress = Term::ProgressBar->new({name => 'matching & missing', count => $max});

#loop though each dat entry
OUTER: foreach my $datline (@sorteddatfile) 
{
  $progress->update($_);
  if ($datline =~ m/<rom name=/ and not $datline =~ m/.bin/)
  {
    #parse rom name
	$resultromstart = index($datline, '<rom name="');
	$resultromend = index($datline, 'size="');
	my $length = ($resultromend)  - ($resultromstart + 12) ;
    $romname  = substr($datline, $resultromstart + 11, $length - 5);
	$romname =~ s/amp;//g; #clean & dat format
	push (@sortedromenames, $romname);
	$match = 0;
	
	foreach my $gameline (@linesgames)
	{
       $match = 0;
	   
	   #parse game name
       if (not $gameline =~ m/.m3u/)
       {
          my $length = length($gameline);
		  my $rightdot = rindex($gameline, ".");
		  my $suffixlength = $length - $rightdot;
          $gamename  = substr($gameline, 0, $length - $suffixlength);
	
	      #check for exact match between dat name and filename
          if ($romname eq $gamename)
	      {
		  #print "match: $romname    $gamename\n";
		  $match = 1;
		  push(@linesmatch, $romname);
		    
			if ($logmatching eq "TRUE" or $logall eq "TRUE")
		    {
			   push(@alllinesout, ["MATCHED:", $gamename]);
		    }
			
		  $totalmatches++;
		  next OUTER;
          } 
	   }
    }
	
    #default if no match report missing
	push(@linesmiss, $romname);
	#print "miss: $romname\n";
	if ($logmissing eq "TRUE" or $logall eq "TRUE")
	{
	   push(@alllinesout, ["MISSING:", $romname]);
	}
	$totalmisses++;
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
	if (not $gamematch =~ m/.m3u/ and not $gamematch =~ m/.bin/)
	{
	  push (@alllinesout, ["EXTRA FILE:", $gamematch]);
	  push (@extrafiles, $gamematch2);
	  $totalextrafiles++;
	}
}

my $max3 = scalar(@extrafiles);
my $progress3 = Term::ProgressBar->new({name => 'fuzzy matching', count => $max3});

#loop through each extra file
OUTER3: foreach my $extrafileentry (@extrafiles)
{
   $progress3->update($_);
	
   #check fuzzy match between extra filename and dat name
   my $any_matched2 = 0;
   $any_matched2 = amatch($extrafileentry, @sortedromenames);
   if ($any_matched2 == 1)
   {
      my @fuzzymatches = amatch($extrafileentry, @sortedromenames);
	   	   
	  #distance
	  my @fuzzydist = adistr($extrafileentry, @sortedromenames);

	  if (($logfuzzy eq "TRUE" or $logall eq "TRUE") and not $fuzzymatches[0] =~ m/.bin/)
	  {
         push(@alllinesout, ["FUZZY MATCH:", "$extrafileentry to: $fuzzymatches[0] distance: $fuzzydist[0]"]);
	     $totalfuzzymatches++;
		 next OUTER3;
	  }
   }
}




=for comment

#loop through each sorted dat name entry
OUTER3: foreach my $datentry (@sorteddatfile)
{
   $progress->update($_);
   
   my $extracount = @extrafiles;
   if ($datentry =~ m/<rom name=/ and not $datentry =~ m/.bin/ and $extracount > 0)
   {
      #parse rom name
	  $resultromstart = index($datentry, '<rom name="');
	  $resultromend = index($datentry, 'size="');
	  my $length = ($resultromend)  - ($resultromstart + 12) ;
      my $datentry2  = substr($datentry, $resultromstart + 11, $length - 5);
	  $datentry2 =~ s/amp;//g; #clean & dat format
	  
	  #check fuzzy match between dat name and extra filename 
	  my $any_matched2 = 0;
	  $any_matched2 = amatch($datentry2, @extrafiles);
	  if ($any_matched2 == 1)
	  {
	     my @fuzzymatches = amatch($datentry2, @extrafiles);
	   	   
	     #distance
	     my @fuzzydist = adistr($datentry2, @extrafiles);

	     if (($logfuzzy eq "TRUE" or $logall eq "TRUE") and not $fuzzymatches[0] =~ m/.bin/)
	     {
			push(@alllinesout, ["FUZZY MATCH:", "$fuzzymatches[0] to: $datentry2 distance: $fuzzydist[0]"]);
	        $totalfuzzymatches++;
			next OUTER3;
	     }
	  }
	}
}
=cut

#print total have
print "\ntotal matches: $totalmatches\n";

#print total miss
print "total misses in dat: $totalmisses\n";

#print extra files
print "total extra files in collection: $totalextrafiles\n";

#print total fuzzy have
print "total fuzzy matches to extra files: $totalfuzzymatches\n";

#open log file and print all sorted output
open(LOG, ">", "$system.txt") or die "Could not open $system.txt\n";
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
