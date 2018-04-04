package Clusterblast::Batch::slurm;
#
#===============================================================================
#
#         FILE:  slurm.pm
#
#  DESCRIPTION:  Package to submit jobs to Slurm
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr. Scott A. Givan (sag), givans@missouri.edu
#      COMPANY:  University of Missouri, USA
#      VERSION:  ---
#      CREATED:  04/04/2018
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
    my $queue = $params->{queue} || 'CLUSTER';# this is the slurm partition
    my $cpath = $params->{cpath} || "/opt/bio/ncbi/bin";
    # $cpath changes if $opt_B != 0, see below
    my $dpath = $params->{dpath} || '/share/ircf/dbase/BLASTDB';
    my $memory = $params->{memory} || '1G';
    my $processors = $params->{processors} || 1;
    my $opt_B = $params->{opt_B} || 0;
    $cpath = "/share/ircf/ircfapps/bin" if ($opt_B);
    my $blast = $params->{blast} || 'blastn';
    my $task = $params->{task} || 'blastn';
    my $wd_cluster = $params->{wd_cluster} || '/path/to/wd';
    my $blastfile = $params->{blastfile} || 'blastfile';
    my $Evalue = $params->{Evalue} || 1e-6;
    my $html = $params->{html} || '';
    my $extraArgs = $params->{extraArgs} || '';
    my $db = $params->{db} || 'nr';
    my $mega = $params->{mega} || '';

    my $outfile = "$id.sbatch";
    $self->batchfile($outfile);
    my $cfile = new FileHandle "> $outfile";
    $self->cfile($cfile);
    my $jobname = "BLAST" . "$jobid";
    $self->jobname($jobname);

    print $cfile "#! /bin/bash\n";
    print $cfile "#SBATCH -J $id\n";
    print $cfile "#SBATCH -o $cluster_dir/\%J.o\n";
    print $cfile "#SBATCH -e $cluster_dir/\%J.e\n";
    print $cfile "#SBATCH --partition $queue\n";
    print $cfile "#SBATCH --ntasks=1\n";
    print $cfile "#SBATCH --cpus-per-task $processors\n";
    print $cfile "#SBATCH --mem=$memory\n\n";
    print $cfile "export BLASTMAT=$cpath/../data/\n";
    print $cfile "export BLASTDB=$dpath\n";
    print $cfile "export BLASTDIR=$cpath\n\n";
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

    my $sbatch = 'sbatch';
    my $batchfile = $self->batchfile();

    open(SBATCH,"-|","$sbatch < $batchfile");
    my @stdout = <SBATCH>;
    close(SBATCH);
    $self->stdout(@stdout);
    $self->parse_jobid();
}

sub parse_jobid {
    my $self = shift;

    my @stdout = $self->stdout();
    my $jobid;

    # lines are assumed to look like
    # Submitted batch job 636
    
    if (@stdout) {
        if ($stdout[0] =~ /Submitted\sbatch\sjob\s(\d+)/) {
            $jobid = $1;
        }
        #print "stdout: '@stdout'\n";
        #print "jobid: '$jobid'\n";
    }
    $self->jobid($jobid);
}

sub jobstate {
    my $self = shift;
    my $jobid = $self->jobid();

    my $bin = "scontrol -o show job ";
    # there should be a line similar to:
    # JobState=RUNNING Reason=None Dependency=(null)
    # the -o option puts evertyhing on one line
    # I want the JobState value

    my @resp = ();
    eval {
        open(CHK, "-|", "$bin $jobid");
        @resp = <CHK>;
        close(CHK);
    };
    #print "\@resp: '@resp'\n";

#    given ($@) {# like switch:
#        default { say "\$\@ = '$@'" }
#    }

    my $retval = 0;

    if (@resp && ($resp[0] =~ /\sJobState\=(\w+)\s/)) {
        if ($1 eq 'RUNNING' || $1 eq 'PENDING') {
            $retval = 1;
        }
    }
    return $retval;
}

__PACKAGE__->meta->make_immutable;
