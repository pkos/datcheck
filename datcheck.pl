use strict;
use warnings;
use Term::ProgressBar;

#init
my $substringmiss = "-miss";
my $substringmatch = "-match";
my $substringboth = "-both";
my $logmissing = "FALSE";
my $logmatching = "FALSE";
my $logboth = "FALSE";
my $datfile = "";
my $system = "";
my $discdirectory = "";
my $substringh = "-h";
my @linesdat;
my @linesgames;
my @linesmatch;
my @linesmiss;

#check command line
foreach my $argument (@ARGV) {
  if ($argument =~ /\Q$substringh\E/) {
    print "datcheck v0.6 - Utility to compare No-Intro or Redump dat files to the disc collection\n";
    print "                and report the matching and missing discs in the collection, and extra files.\n";
	print "\n";
	print "with datcheck [ options ] [dat file ...] [directory ...] [system]\n";
	print "\n";
	print "Options (choose 1):\n";
	print "  -miss    write only missing files to log file\n";
	print "  -match   write only matching files to log file\n";
	print "  -both    write both missing and matching files to log file\n";
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
  if ($argument =~ /\Q$substringboth\E/) {
    $logboth = "TRUE";
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
} elsif ($logboth eq "TRUE") {
  $tempstr = "matching and missing files";
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

#open log file
open(LOG, ">", "$system.txt") or die "Could not open $system.txt\n";

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
my $length = 0;
my $i=0;
my $j=0;

#parse the game name and redump disc serial
OUTER: foreach my $datline (@linesdat) 
{
  if ($datline =~ m/<rom name=/ and not $datline =~ m/.bin/)
  {
    #parse rom name
	$resultromstart = index($datline, '<rom name="');
	$resultromend = index($datline, 'size="');
	my $length = ($resultromend)  - ($resultromstart + 12) ;
    $romname  = substr($datline, $resultromstart + 11, $length - 5);
	$romname =~ s/amp;//g; #clean & dat format
	$match = 0;
	
	foreach my $gameline (@linesgames)
	{
       $match = 0;
	   
	   #parse game name
       if (not $gameline =~ m/.m3u/)
       {
          my $length = length($gameline);
          $gamename  = substr($gameline, 0, $length - 4);
	
	      if ($romname eq $gamename)
	      {
		  #print "match: $romname    $gamename\n";
		  $match = 1;
		  push(@linesmatch, $romname);
		    
			if ($logmatching eq "TRUE" or $logboth eq "TRUE")
		    {
		     print LOG "matched dat entry to filename: $gamename\n";
		    }
			
		  $totalmatches++;
		  next OUTER;
          }
	   } 
    }
    
	push(@linesmiss, $romname);
	#print "miss: $romname\n";
	if ($logmissing eq "TRUE" or $logboth eq "TRUE")
	{
	   print LOG "missing file in collection from dat entry: $romname\n";
	}
	$totalmisses++;
  }
}

OUTER2: foreach my $gamematch (@linesgames)
{
	#parse game name
    $length = length($gamematch);
    my $gamematch2  = substr($gamematch, 0, $length - 4);
	
	foreach my $rommatch (@linesmatch)
	{
       $match = 0;

       #debug
	   #print "$rommatch   $gamematch2\n";
	
       if ($rommatch eq $gamematch2)
	   {
	      $match = 1;
	      next OUTER2;
	   }
	}
	   
	#didnt match the filename to a dat entry
	if (not $gamematch =~ m/.m3u/)
	{
	  print LOG "didnt match filename to a dat entry: $gamematch\n";
	  $totalextrafiles++;
	}
}

#print total have
print "total matches: $totalmatches\n";

#print total miss
print "total misses in dat: $totalmisses\n";

#print extra files
print "total extra files in collection: $totalextrafiles\n";

close (LOG);
print "log file: $system.txt\n";