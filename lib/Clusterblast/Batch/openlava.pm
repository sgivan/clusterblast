package Clusterblast::Batch::openlava;
#
#===============================================================================
#
#         FILE:  openlava.pm
#
#  DESCRIPTION:  Package to submit jobs to LSF/Openlava
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  1.0
#      CREATED:  05/18/16 06:15:38
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use autodie;
use Moose;
use FileHandle;

1;

has 'batchfile' =>  ( is => 'rw' );
has 'cfile' => ( is => 'rw' );
has 'jobname' => ( is => 'rw' );
has 'stdout'    =>  ( is => 'rw' );
has 'jobid'     =>  ( is => 'rw' );

sub make_batch_file {
    my $self = shift;
    my $params = shift; # should be hash array
    my $id = $params->{id} || 'id';
    my $jobid = $params->{jobid} || 'jobid';
    my $cluster_dir = $params->{cluster_dir} ||  "~/cluster";
    my $queue = $params->{queue} || 'normal';
    my $cpath = $params->{cpath} || "/opt/bio/ncbi/bin";
    # $cpath changes if $opt_B != 0, see below
    my $dpath = $params->{dpath} || '/ircf/dbase/BLASTDB';
    my $memory = $params->{memory} || 1000;
    my $processors = $params->{processors} || 1;
    my $opt_B = $params->{opt_B} || 0;
    $cpath = "/ircf/ircfapps/bin" if ($opt_B);
    my $blast = $params->{blast} || 'blastn';
    my $task = $params->{task} || 'blastn';
    my $wd_cluster = $params->{wd_cluster} || '/path/to/wd';
    my $blastfile = $params->{blastfile} || 'blastfile';
    my $Evalue = $params->{Evalue} || 1e-6;
    my $html = $params->{html} || '';
    my $extraArgs = $params->{extraArgs} || '';
    my $db = $params->{db} || 'nr';
    my $mega = $params->{mega} || '';

    my $outfile = "$id.cluster";
    $self->batchfile($outfile);
    my $cfile = new FileHandle "> $outfile";
    $self->cfile($cfile);
    my $jobname = "BLAST" . "$jobid";
    $self->jobname($jobname);

    print $cfile "#BSUB -L /bin/bash\n";
    print $cfile "#BSUB -J $id\n";
    print $cfile "#BSUB -o $cluster_dir\n";
    print $cfile "#BSUB -e $cluster_dir\n";
    print $cfile "#BSUB -q $queue\n";
    print $cfile "#BSUB -n $processors\n";
    print $cfile "#BSUB -R \"rusage[mem=$memory], span[hosts=1]\"\n";
    print $cfile "export BLASTMAT=$cpath/../data/\n";
    print $cfile "export BLASTDB=$dpath\n";
    print $cfile "export BLASTDIR=$cpath\n";
    if ($opt_B) {
        # the following four lines were commented and caused problems when 
        # not using blastn or megablast
        # uncomment and test
        if ($blast =~ /blastn/ || $blast =~ /mega/) {
            $blast = "blastn -task $task";
        }
        print $cfile "$cpath/$blast -num_threads $processors -db $db -query $wd_cluster/$id.nfa -out $wd_cluster/$blastfile -evalue '$Evalue' $html $extraArgs\n";
    } else {
        print $cfile "$cpath/bin/blastall -a $processors -d $db -p $blast -i $wd_cluster/$id.nfa -o $wd_cluster/$blastfile -e '$Evalue' $html -n $mega $extraArgs\n";
    }

    $cfile->close;
}

sub check_batch_file {
    my $self = shift;
    my $filename = $self->batchfile();

    if (-e $filename) {
        return 1;
    } else {
        return -1;
    }
}

sub submit_batch {
    my $self = shift;

    my $bsub = 'bsub';
    my $batchfile = $self->batchfile();

    open(BSUB,"-|","$bsub < $batchfile");
    my @stdout = <BSUB>;
    close(BSUB);
    $self->stdout(@stdout);
    $self->parse_jobid();
}

sub parse_jobid {
    my $self = shift;

    my @stdout = $self->stdout();
    my $jobid;
    
    if (@stdout) {
        if ($stdout[0] =~ /Job\s<(\d+)>\s/) {
            $jobid = $1;
        }
        #    print @stdout unless ($quiet);
    }
    $self->jobid($jobid);
}

sub jobstate {
    my $self = shift;
    my $jobid = $self->jobid();

    my $bin = "bjobs";

    my @resp = ();
    eval {
        open(CHK, "-|", "$bin $jobid");
        @resp = <CHK>;
        close(CHK);
    };

#    given ($@) {# like switch:
#        default { say "\$\@ = '$@'" }
#    }

    if (@resp && ($resp[1] =~ /RUN/ || $resp[1] =~ /PEND/)) {
        return 1;
    } else {
        return 0;
    }

}

__PACKAGE__->meta->make_immutable;
