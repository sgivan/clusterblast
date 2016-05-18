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

1;

sub make_batch_file {

    my $cfile = new FileHandle "> $outfile";

    #  print $cfile "#!/bin/bash\n\n#\$ -S /bin/sh\n#\$ -N $jobname\n";
    #  print $cfile "export BLASTMAT=$cpath/share/blastdata\n";
    print $cfile "#BSUB -L /bin/bash\n";
    print $cfile "#BSUB -J $id\n";
    #   print $cfile "#\$ -o $cluster_dir\n";
    print $cfile "#BSUB -o $cluster_dir\n";
    #   print $cfile "#\$ -e $cluster_dir\n";
    print $cfile "#BSUB -e $cluster_dir\n";
    print $cfile "#BSUB -q $queue\n";
    print $cfile "#BSUB -n $processors\n";
    print $cfile "#BSUB -R \"rusage[mem=$memory], span[hosts=1]\"\n";
    #   print $cfile "#\$ -p -10\n";
    #print $cfile "export BLASTMAT=$cpath/data/\n";
    #print $cfile "export BLASTMAT=/evbio/NCBI/ncbitools/ncbi/data/\n";
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
        #print $cfile "$cpath/$blast -task $task -num_threads $processors -db $db -query $wd_cluster/$id.nfa -out $wd_cluster/$blastfile -evalue '$Evalue' $html $extraArgs\n";
    } else {
        print $cfile "$cpath/bin/blastall -a $processors -d $db -p $blast -i $wd_cluster/$id.nfa -o $wd_cluster/$blastfile -e '$Evalue' $html -n $mega $extraArgs\n";
    }

    $cfile->close;
}
