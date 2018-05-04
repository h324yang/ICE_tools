###############################################################
# Training Baselines
###############################################################
mkdir task/
DIR=task/retrieval/
mkdir $DIR

for topk in 10 
do
    echo "generating bi-directional graph"
    awk '{print $2 " " $1 " " $3}' data/et_top${topk}_w0.edge | cat - data/et_top${topk}_w0.edge | sort | uniq > data/et_top${topk}_w0_bidir.edge
    for i in 1 2 3
    do
        # baseline1: BPT
        CUR_DIR=${DIR}bpt_top${topk}_${i}/
        mkdir $CUR_DIR
        for SAMP in 40 # 12000 
        do
            ../LINE/linux/line -train data/et_top10_w0_bidir.edge -output ${CUR_DIR}_full.embd.${SAMP} -size 300 -samples $SAMP -negative 5 -rho 0.025 -threads 54
            sed 1,1d ${CUR_DIR}_full.embd.${SAMP} > ${CUR_DIR}full.embd.${SAMP} # delete the header
            python3 metric/retrieval_folder.py -dir ${CUR_DIR} -text word.embd -entity item.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json 
        done
    done
    # baseline2: AVGEMB
    CUR_DIR=${DIR}avgemb_top${topk}/
    mkdir ${CUR_DIR}
    python3 AVGEMB/avgemb.py -entity ${CUR_DIR}item.embd -text ${CUR_DIR}word.embd -et data/et_top${topk}_w0.edge -w2v pretrain/partial_embd.txt
done


###############################################################
# Evaluating Genre Retrieval
###############################################################
REPORT=log/genre_retrieval_report_graphrank_baselines.txt
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

# SAMP=12000
SAMP=40
for topW in 10 50 100
do
    for i in `seq 1 3`
    do
    # BPT
    CUR_DIR=${DIR}bpt_top10_${i}/
    evaluate $CUR_DIR $SAMP $topW $i "bpt" $REPORT
    done
    # AVGEMB
    CUR_DIR=${DIR}avgemb_top10/
    evaluate $CUR_DIR 0 $topW 1 "avgemb" $REPORT
done


###############################################################
# KBR
###############################################################
for topW in 10 50 100
do
    echo KBR topW@${topW}
    python3 KBR/kbr.py -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json -topW ${topW} > log/kbr_${topW}.txt
done
