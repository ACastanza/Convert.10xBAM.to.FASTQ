#! /bin/bash
# Using getopt
set -e

abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred. Exiting..." >&2
    exit 1
}

while getopts ":a:l:o:m:r:j:" opt; do
    case $opt in
        a)
            bamfile=`realpath $OPTARG`
            echo "BAM File = $bamfile"
            ;;
        l)
            libdir="$OPTARG"
            echo "-l = $libdir"
            bam2fastq=`realpath ${libdir}bamtofastq_linux`
            ;;
        o)
            outfolder="$OPTARG"
            ;;
        m)
            mode="$OPTARG"
            ;;
        r)
            readsperfastq="$OPTARG"
            ;;
        j)
            threads="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            abort
            ;;
    esac
done

params=()
[[ $mode == "gemcode" ]] && params+=(--gemcode)
[[ $mode == "lr20" ]] && params+=(--lr20)
[[ $mode == "cr11" ]] && params+=(--cr11)

$bam2fastq \
      --nthreads=$threads \
      "${params[@]}" \
      --reads-per-fastq=$readsperfastq \
      $bamfile \
      $outfolder ;

find  $outfolder -type f -name *.fastq.gz |\
awk -v targetF="$(dirname "$outfolder")" 'BEGIN{FS="/"; OFS="_"}{printf $0" "; print targetF"/"$(NF-2),$(NF-1),$NF}' |\
xargs -n2 mv;

rm -rf $bamfile $outfolder
