###############################################################
# Separate sensitivity analysis
###############################################################
for topk in 10x5
do
    for i in 1 2 3
    do
        CUR_DIR=sample_sensi/ice_${topk}_${i}/
        mkdir $CUR_DIR
        for SAMP in 10 20 40 # 80 160 320 640 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 12000 15000 
        do
            ../ICE/ICE/ice -text data/ice_full_top${topk}_w0.edge -textrep ${CUR_DIR}full.embd.${SAMP} -textcontext ${CUR_DIR}context.embd.${SAMP} -dim 300 -sample $SAMP -neg 5 -alpha 0.025 -thread 50 
        done
        REPORT=log/sample_sensi_log_${topk}_${SAMP}_ice_${i}.txt 
        python3 metric/retrieval_folder.py -dir $CUR_DIR -text word.embd -entity item.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json > $REPORT 
    done
done


###############################################################
# wICE
###############################################################
for topk in 10x5
do
    for i in 1 2 3
    do
        CUR_DIR=sample_sensi/wice_${topk}_${i}/
        PRE_DIR=sample_sensi/ice_${topk}_${i}/
        mkdir $CUR_DIR
        for SAMP in 10 20 40 # 80 160 320 640 1000 2000 3000 4000 5000 6000 7000 8000 9000 10000
        do
            grep ^w_ ${PRE_DIR}context.embd.${SAMP} > ${PRE_DIR}word_context.embd.${SAMP}
            ../ICE/ICE/ice -text data/ice_tt_top${topk}_w1.edge -textrep ${CUR_DIR}word.embd.${SAMP} -textcontext ${CUR_DIR}context.embd.${SAMP} -load_embd1 ${PRE_DIR}word_context.embd.${SAMP} -dim 300 -sample $SAMP -neg 5 -alpha 0.025 -thread 50 -entity data/ice_et_top${topk}_w1.edge -save ${CUR_DIR}item.embd.${SAMP}
        done
        REPORT=log/sample_sensi_log_${topk}_${SAMP}_wice_${i}.txt 
        python3 metric/retrieval_folder.py -dir $CUR_DIR -text word.embd -entity item.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json > $REPORT
    done
done


