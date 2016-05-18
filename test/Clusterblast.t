#!/usr/bin/env perl
#
#===============================================================================
#
#         FILE:  Clusterblast.t
#
#  DESCRIPTION:  Test script for Clusterblast class
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  05/18/16 10:27:05
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use strict;
use warnings;
use lib '/home/sgivan/projects/clusterblast/lib';

# declare number of tests to run
use Test::More tests => 3;

use_ok('Clusterblast');

my $cb = Clusterblast->new();

isa_ok($cb,'Clusterblast');

my $batch = $cb->batch();

isa_ok($batch,'Clusterblast::Batch');
