###############################################################
# Evaluating Genre Retrieval
###############################################################
REPORT=log/genre_retrieval_report_graphrank_icn.txt
echo "Genre Retrieval Task Report" > $REPORT
DIR=task/retrieval/

evaluate(){
    echo ${5}_${4}_topW_${3} >> $6
    if [ $2 -eq 0 ]
    then
        python3 metric/retrieval_eval.py -text ${1}word.embd -entity ${1}item.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json -topW ${3} >> $6
    else
        python3 metric/retrieval_eval.py -text ${1}word.embd.${2} -entity ${1}item.embd.${2} -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json -topW ${3} >> $6
    fi
}

topk=10x5
# SAMP=12000
# SP=4000
SAMP=40
SP=40
for topW in 10 50 100
do
    for i in `seq 1 3`
    do
    # ICE
    CUR_DIR=sample_sensi/ice_${topk}_${i}/
    evaluate $CUR_DIR $SAMP $topW $i "ICE" $REPORT

    # wICE
    CUR_DIR=sample_sensi/wice_${topk}_${i}/
    evaluate $CUR_DIR $SP $topW $i "wICE" $REPORT
    done
done


