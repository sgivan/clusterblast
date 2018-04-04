#!/usr/bin/env perl
#
#===============================================================================
#
#         FILE:  ClusterblastBatch.t
#
#  DESCRIPTION:  Test script for Clusterblast::Batch class.
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  05/18/16 08:03:41
#     REVISION:  ---
#===============================================================================

use 5.010;      # Require at least Perl version 5.10
use autodie;
use strict;
use warnings;
use lib '/home/sgivan/projects/clusterblast/lib';

# declare number of tests to run
use Test::More tests => 6;

use_ok('Clusterblast::Batch');

my $cb = Clusterblast::Batch->new();

isa_ok($cb,'Clusterblast::Batch');

my $openlava = $cb->openlava();

isa_ok($openlava,'Clusterblast::Batch::openlava');

my $batch = $cb->batch();

isa_ok($batch,'Clusterblast::Batch::openlava');

my $slurm = $cb->slurm();

isa_ok($slurm, 'Clusterblast::Batch::slurm');

my $params = {
    id          =>  'test',
#    jobid       =>  'jobid',
#    wd_cluster  =>  '/path/to/wd',
#    db          =>  'nr',
#    blastfile   =>  'job.blastfile',
#    html        =>  '',
#    extraArgs   =>  '',
#    mega        =>  '',
#    opt_B       =>  1,
};

$batch->make_batch_file($params);

my $outfile = $batch->batchfile();

is($outfile,'test.bsub','batchfile name set');

is($batch->check_batch_file(), 1, 'batch file created');

#unlink('test.cluster');

$slurm->make_batch_file($params);

my $sbatchfile = $slurm->batchfile();

is($sbatchfile, 'test.sbatch', 'slurm batchfile name set');

is($slurm->check_batch_file(), 1, 'slurm batchfile created');

#unlink('slurm.sbatch');


