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

has batch ( is => 'rw' );


__PACKAGE__->meta->make_immutable;
