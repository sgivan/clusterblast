#!/usr/bin/env perl 
#===============================================================================
#
#         FILE:  query_to_EnsemblAnnotGene.pl
#
#        USAGE:  ./query_to_EnsemblAnnotGene.pl  
#
#  DESCRIPTION:  Takes output of bestblastparse.pl to assign annotated gene name
#                    to an unnanotated gene.
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  06/17/16 14:27:38
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use Getopt::Long; # use GetOptions function to for CL args
use warnings;
use strict;

my ($debug,$verbose,$help,$infile,$outfile,$matchfile);

my $result = GetOptions(
    "debug"         =>  \$debug,
    "verbose"       =>  \$verbose,
    "help"          =>  \$help,
    "infile:s"      =>  \$infile,
    "outfile:s"     =>  \$outfile,
    "matchfile:s"   =>  \$matchfile,
);

if ($help) {
    help();
    exit(0);
}

sub help {

    say <<HELP;
    "debug"         =>  \$debug,
    "verbose"       =>  \$verbose,
    "help"          =>  \$help,
    "infile:s"      =>  \$infile,
    "outfile:s"     =>  \$outfile,
    "matchfile:s"   =>  \$matchfile,

HELP

}

$infile = $infile || 'infile';
$outfile = $outfile || 'outfile';
$matchfile = $matchfile || 'matchfile';
my $matchedfile = $matchfile . ".matched";

open(my $IN, "<", $infile);
open(my $OUT, ">", $outfile);

my ($MATCH,$MATCHED);
if ($matchfile) {
    open($MATCH,"<",$matchfile);
    open($MATCHED,">",$matchedfile);
}

my $cnt = 0;
my %matching = ();
while (<$IN>) {
    ++$cnt;
    chomp(my $inline = $_);

    my @lineval = split /\t/, $inline;
    my ($qID,$hDesc) = ($lineval[1],$lineval[7]);
    next if ($qID eq 'Query');

    if ($qID =~ /gene=(.+)\b/) {
        $qID = $1;
    }

    my $newGeneName = '';
    if ($hDesc =~ /gene_symbol:(.+?)\s/) {
        $newGeneName = $1;
    }

    $matching{$qID} = $newGeneName;

    say "qID: '$qID', hDesc: '$hDesc', newGeneName: '$newGeneName'" if ($debug);

    say $OUT "$qID\t$newGeneName\t$hDesc";

    last if ($debug && $cnt == 10);

}

if ($matchfile) {

    while (<$MATCH>) {
        chomp(my $line = $_);
        my @vals = split /\t/, $line;

        if ($vals[0]) {
            say $MATCHED "$vals[0]\t" . $matching{$vals[0]} if (defined($matching{$vals[0]}));
        }
    }
}

close($IN);
close($OUT);


