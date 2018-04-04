package Clusterblast::Batch;
#
#===============================================================================
#
#         FILE:  Batch.pm
#
#  DESCRIPTION:  Class to create object to interact with batch submission protocol
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  05/18/16 06:54:55
#     REVISION:  ---
#===============================================================================

use 5.10.0;
use strict;
use warnings;
use autodie;
use Moose;
use Clusterblast::Batch::openlava;
use Clusterblast::Batch::slurm;

1;

has 'openlava' => (
    is          =>  'ro',
    builder     =>  '_build_openlava',
    lazy        =>  1,
);

has 'slurm' => (
    is          =>  'ro',
    builder     =>  '_build_slurm',
    lazy        =>  1,
);

has 'batch' =>  (
    is      =>  'rw',
);


sub _build_openlava {
    my $self = shift;

    my $batch = Clusterblast::Batch::openlava->new();
    $self->batch($batch);

    return $batch;
}

sub _build_slurm {
    my $self = shift;

    my $batch = Clusterblast::Batch::slurm->new();
    $self->batch($batch);

    return $batch;
}

sub make_batch_file {
    my $self = shift;
    my $params = shift;

    $self->make_batch_file($params);

}

__PACKAGE__->meta->make_immutable;
