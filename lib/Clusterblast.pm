package Clusterblast;
#
#===============================================================================
#
#         FILE:  Clusterblast.pm
#
#  DESCRIPTION:  Main module for Clusterblast
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  05/18/16 06:18:52
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use autodie;
use Moose;
use lib '/home/sgivan/projects/clusterblast/lib';
use Clusterblast::Batch;

has 'batch' => (
    is          => 'ro',
    builder     =>  '_build_batch',
);

sub _build_batch {
#    require Clusterblast::Batch;

    my $batch = Clusterblast::Batch->new();

    return $batch;
}


__PACKAGE__->meta->make_immutable;
