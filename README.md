# clusterblast
Scripts for running and parsing emabarrasingly parallel NCBI BLAST jobs

## Dependencies that may not already be installed on your system:

 - [BioPerl](http://bioperl.org/)
 - [Moose](http://moose.iinteractive.com)

## Summary

The clusterblast script includes a fairly good help message that covers command line options. To see the help message, run:

```
>clusterblast -h

This is a script that takes a FASTA-formatted file of nucleotide
or protein sequences and BLASTs them using the Slurm scheduler.
A summary of the command line options:

usage: clusterblast -f <folder name> -d <blast database name> -b <blast program>

-f      FASTA file name
-d      the BLAST database to search
-b      the type of BLAST program (ie, blastn, blastp)
-P      path to blast database, if not /dfs/databases/ (use '/' as last character)
-B      use the new family of NCBI BLAST binaries (not blastall)
-n      contig number cutoff (seq name must be in form Contig###)
-l      minimum sequence length to accept [1]
-L      maximum sequence length to accept [1000000]
-a      extra arguments to send to blastall (ie, -a '-b 500', or '-num_alignments 500')
-r      amount of RAM needed by blastall (default = 10G)
-E      BLAST E-value cut-off (defaults to 1e-06; enclose in quotes)
-H      generate HTML output
-M      use Megablast (only available for a blastn search)
-q      which Slurm partition to submit the jobs to [CLUSTER]
-p      number of processors to use per blast job [1]
-N      specific nodes to run jobs on; for example:
            -N 'chrom10-20'
            -N 'chrom10-20;chrom40-52'
            -N 'chrom10;chrom12;chrom15'
            -N 'chrom10;chrom12-15;chrom18'
-h      display this help message
-Q      quite mode
-W      after submitting jobs, don't wait for them to finish before exiting
-c #    throttle queue submission (pause after this number of job submissions)
-D      debug mode -- don't submit jobs to cluster

```

The bestblastparse.pl script parses the output of clusterblast and generates a spreadsheet-style summary file. It also has a help message:

```

>bestblastparse.pl -h

This script takes a collection of BLAST result files and parses
out all of the hits above a user-selected E-value.  It sends
the output to a tab-delimited file.

 usage:  bestblastparse -f <file name>

Option  Description
 -f     input folder name
 -M     use this flag if clusterblastmax was used
 -o     output file name (defaults to bestblast.tab)
 -e     E-value cutoff (defaults to 1e-06)
 -p     % identity cutoff (85 means 85%)
 -c     queue coverage cutoff (percentage; ie 85 means 85%)
 -C     subj coverage cutoff (percentage; ie 85 means 85%. Requires -d also)
 -t     output statistics for tiled hsps
 -E     print report for every hit < E-value (overrides -n)
 -l     generate output for every ORF (even with no hits)
 -b     type of blast search [defaults to blastn]
 -n     number of best hits to output for each report
 -d     print detailed information about best hit
 -a     print alignment for each hit
 -S     name of file to print summary information
 -q     quiet mode
 -h     display this help message
 
```
