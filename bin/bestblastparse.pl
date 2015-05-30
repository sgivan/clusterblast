#!/usr/bin/env perl
# $Id: bestblastparse.pl,v 1.19 2007/03/01 19:51:47 givans Exp $
# Revision 1.6  2004/03/13 04:20:24  givans
# Added framework for accepting -S parameter
#
# Revision 1.5  2004/01/14 01:15:20  givans
# BLAST search defaults to BLASTN
#
# Revision 1.4  2004/01/14 00:47:20  givans
# Added Log line in header
#
#
# Script to parse BLAST reports and generate file of queries
# plus the queries' best BlAST hits
#
#

use warnings;
use strict;
use Carp;
#use Bio::Tools::BPlite;
use Bio::SearchIO;
use Bio::Search::SearchUtils;
use Getopt::Std;
#use lib '/home/cgrb/givans/bin';
#use FastBlastParse;
use vars qw/ $opt_f $opt_o $opt_e $opt_E $opt_q $opt_b $opt_h $opt_S $opt_n $opt_d $opt_a $opt_M $opt_l /;

getopts('f:o:e:Eqb:hS:n:daMl');
my $usage = "bestblastparse -f <file name>";

$| = 1;


if ($opt_h) {
  print <<HELP;

This script takes a collection of BLAST result files and parses
out all of the hits above a user-selected E-value.  It sends
the output to a tab-delimited file.

 usage:  $usage

Option		Description
 -f		input folder name
 -M		use this flag if clusterblastmax was used
 -o		output file name (defaults to bestblast.tab)
 -e		E-value cutoff (defaults to 1e-06)
 -E		print report for every hit < E-value (overrides -n)
 -l		generate output for every ORF (even with no hits)
 -b		type of blast search [defaults to blastn]
 -n		number of best hits to output for each report
 -d		print detailed information about best hit
 -a		print alignment for each hit
 -S		name of file to print summary information
 -q		quiet mode
 -h		display this help message

HELP
exit(0);
}


my($folder,$outfile,$evalue,$blast,$quiet,%hitlist,$reps) = ();

# Parse command line options, or ask user for necssary parameters
$quiet = $opt_q;#;
print "verbose mode\n" unless ( $quiet );

if ($opt_f) {
  $folder = $opt_f;
}
$folder = "." unless ($folder);


if (!$opt_o) {
#    print "Name of output file:  ";
#    $outfile = <STDIN>;
#    chomp($outfile);
  $outfile = 'bestblast.tab';
} else {
    $outfile = $opt_o;
}
die "you must enter a valid output file name" unless ($outfile =~ /\w/);

if (!$opt_e) {
#    print "What do you want the E-value cutoff to be (ie, 1e-10)?  ";
#    $evalue = <STDIN>;
#    chomp($evalue);
  $evalue = 1e-06;
} else {
    $evalue = $opt_e;
}
die "you must enter a valid E-value" unless ($evalue =~ /\d+e[-+]\d+/);

if (!$opt_b) {
	print "What type of BLAST search [blastn]? ";
	$blast = <STDIN>;
	chomp($blast);
} else {
	$blast = $opt_b;
}
$blast = 'blastn' unless ($blast =~ /blast/);

my @files;

opendir(DIR,$folder);
@files = readdir(DIR);
closedir(DIR);

if ($opt_M) {
  die "can't change into '$folder' directory: $!" if ( !chdir($folder) );
  my @maxdirs = @files;
  @files = ();

  foreach my $maxdir (@maxdirs) {
    next unless (-d $maxdir);
    opendir(MAX,$maxdir) or die "can't open '$folder/$maxdir' directory: $!";
    push(@files, map{ "$maxdir/$_" } readdir(MAX));
    closedir(MAX);
  }
  die "can't walk back from '$folder' directory: $!" if ( !chdir('..') );
}



open(OUT,">$outfile") or die "can't open '$outfile': $!";
print OUT "File\tQuery\tE-value\t%ID\tLength\tDescription";
print OUT "\tQuery ID\tSubj ID\tQuery start\tQuery stop\tQuery strand\tSubj start\tSubj stop\tSubj strand\tbits" if ($opt_d);
#print OUT "\tQuery ID\tSubj ID\tQuery start\tQuery stop\tSubj start\tSubj stop\tbits" if ($opt_d);
print OUT "\tQuery String\tHomolgy string\tHit String" if ($opt_a);
print OUT "\n";

if ($opt_S) {
  open(SUM,">$opt_S") or croak("can't open '$opt_S': $!");
}

if ($opt_n) {
  $reps = $opt_n;
} else {
  $reps = 1;
}

my $cnt = 0;
foreach my $file (@files) {

  if ($file =~ /.+\.$blast$/) {
    ++$cnt;

      my $searchio = Bio::SearchIO->new(
  				      -file	=>	"$folder/$file",
  				      -format	=>	'blast',
  				     );
#      my $searchio = FastBlastParse->new(
#  				      -file	=>	"$folder/$file",
#  				      -format	=>	'blast',
#  				      );
    my $result = $searchio->next_result();
    my($name,$score,$qname,$length,$percent) = ("non-conserved protein","N/A");

    eval { $qname = $result->query_name() . " " . $result->query_description(); };
    if ($@) {
      print "\n\nproblem with '$file'.  This usually means the BLAST search failed for this sequence.\n";
      print "ERROR:  $@ \n\n";
      print "continue? [y/n] (default = y):  ";
      my $ans = <STDIN>;
      chomp($ans);
      if ($ans && $ans eq 'n') {
	exit();
      } else {
	next;
      }
    }


    if ($qname) {
      $qname =~ s/^\d{1,4}\s//;
    } else {
      $qname = 'N/A';
    }
    print "$cnt\t$qname\n" unless ($quiet);
    my $reps_local = 0;

    while (my $hit = $result->next_hit()) {
      my $algorithm = $hit->algorithm();
      if ($algorithm ne 'TBLASTX') {
	if (!$hit->tiled_hsps()) {
	  Bio::Search::SearchUtils::tile_hsps($hit);
	}
      }

      if ($hit->significance <= $evalue) {
	  if ($reps_local >= $reps) {
	    last unless ($opt_E);
	  }# else {
	    ++$reps_local;
	  #}

	my $hsp = $hit->hsp();
	$name = $hit->name . " " . $hit->description();
	$score = $hit->significance();
	$length = $hsp->length();
	$percent = sprintf "%4.2f", $hsp->percent_identity();
	$file =~ s/\.$blast//;
	$file = "$file";

	print OUT "$file\t$qname\t$score\t$percent\t$length\t$name";
	++$hitlist{$name} if ($opt_S);

	if ($opt_d) {
	  my $q_accession = $result->query_accession() || 'unknown';
	  my $hit_accession = $hit->accession() || 'unknown';
	  my ($q_start,$hit_start) = ($hsp->start('query'),$hsp->start('hit'));
	  my ($q_stop,$hit_stop) = ($hsp->end('query') || 'n/a',$hsp->end('hit') || 'n/a');
	  my $bits = $hit->bits() || 'n/a';
	  my $q_strand = $hsp->strand('query') || '0';
	  my $h_strand = $hsp->strand('sbjct') || '0';

	  print OUT "\t$q_accession\t$hit_accession\t$q_start\t$q_stop\t$q_strand\t$hit_start\t$hit_stop\t$h_strand\t$bits";
	}

 	if ($opt_a) {
 	  my $qSeq = $hsp->query_string();
 	  my $hSeq = $hsp->homology_string();
 	  my $sSeq = $hsp->hit_string();

 	  print OUT "\t$qSeq\t$hSeq\t$sSeq";

 	}

	print OUT "\n";
      } else {
	last;
      }

    } ## end of while loop
    if ($opt_l && !$reps_local) {
      print OUT "$file\t$qname\n";
    }
  }

#  last if ($cnt == 20);
}
close(OUT);
close(SUM) if ($opt_S);
print "finished\n" unless ($quiet);


if ($opt_S) {
  open(SUMMARY,">$opt_S") or die "can't open '$opt_S': $!";

  my @sorted_by_frequency = sort {$hitlist{$b} <=> $hitlist{$a}} keys %hitlist;

  foreach my $freq (@sorted_by_frequency) {
    print SUMMARY "$freq\t$hitlist{$freq}\n";
  }
}

sub getSbjct {
  my $obj = shift;
  my ($sbjct,$eval);

  $eval = eval {
    $sbjct = $obj->nextSbjct();
    };

  if (! $eval) {
#    print "something went wrong\n";
    return 0;
  } else {
    return $sbjct;
  }

#   if ($@) {
#     print "warning produced: '$@'\n";
#     return 0;
#   } else {
#     return $sbjct;
#   }
}
