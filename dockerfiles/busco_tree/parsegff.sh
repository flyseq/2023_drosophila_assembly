#! /bin/bash

# args are reference species busco folder e.g. D.melanogaster.busco
# and busco list e.g. final_busco_ids.txt

species=$1
buscoList=$2

speciesFmt=$(echo ${species} | sed -E 's/([A-Z]\.[a-z]+).*/\1/' | \
             tr '.' '_' | tr '[:lower:]' '[:upper:]' )

gff_folder="busco_gffs"
mkdir -p ${gff_folder}

while read line; do
    busco_id=$(echo ${line} | awk '{print $1}')
    gff=./busco/${species}.busco/run_diptera_odb10/augustus_output/gff/${busco_id}.gff

    cat ${gff} | awk '{if ($3=="CDS"){print $0}}' |
    while read gffline; do
            gstart=$(echo ${gffline} | awk '{print $4}')
            gend=$(echo ${gffline} | awk '{print $5}')
            length=$(($gend - $gstart + 1))
        if [ -z ${firstline+x} ]; then
            newstart="1"
            newend=$(($newstart + $length - 1))
            prevend=${newend}
            firstline="FALSE"
        else
            newstart=$(($prevend + 1))
            newend=$(($newstart + $length - 1))
            prevend=${newend}
        fi
        echo $gffline | awk -v start="${newstart}" -v end="${newend}" \
                            -v id="${speciesFmt}" \
                            'BEGIN{OFS="\t";}
                            {print id,$2,$3,start,end,$6,"+",$8,$9}'
    done > ${gff_folder}/${busco_id}.gff
    unset firstline 
done < ${buscoList}
