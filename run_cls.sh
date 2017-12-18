###############################################################
# Train for classification (other settings) W0 
###############################################################
# # baseline: BPT
# task=task/classification
# mkdir $task
# topk=10
# method=$task/BPT${topk}
# mkdir $method
# if [ -f "data/et_top${topk}_w0_bidir.edge" ]
# then
    # echo "find the file."
# else
    # echo "generating bi-directional graph"
    # awk '{print $2 " " $1 " " $3}' data/et_top${topk}_w0.edge | cat - data/et_top${topk}_w0.edge | sort | uniq > data/et_top${topk}_w0_bidir.edge
# fi
# for i in 1
# do
    # for SAMP in 2000 
    # do
        # LINE/linux/line -train data/et_top${topk}_w0_bidir.edge -output ${method}/_full.embd.${SAMP} -size 300 -samples $SAMP -negative 5 -rho 0.025 -threads 26
        # sed 1,1d ${method}/_full.embd.${SAMP} > ${method}/full.embd.${SAMP} # delete the header
        # python3 metric/retrieval_folder.py -dir ${method}/ -text word.embd -entity item.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds.json >> visualize/log/bpt${topk}_log_2k_${i}.txt 
    # done
# done


# # other ICEs
# task=task/classification
# mkdir $task
# for topk in 20x5 10x10 10x5 
# do
    # method=$task/ICE${topk}
    # mkdir $method
    # for i in 1
    # do
        # for SAMP in 2000 
        # do
            # ./ICE/ICE/ice -text data/ice_full_top${topk}_w0.edge -textrep ${method}/full.embd.${SAMP} -textcontext ${method}/context.embd.${SAMP} -dim 300 -sample $SAMP -neg 5 -alpha 0.025 -thread 26 
            # python3 metric/retrieval_folder.py -dir ${method}/ -text word.embd -entity item.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds.json >> visualize/log/ice${topk}_log_2k_${i}.txt 
        # done
    # done
# done


###############################################################
# Bipartite 20 
###############################################################
# topk=20
# embd_method=task/retrieval/bpt
# embd=item.embd.2000
# task=task/classification
# method=${task}/BPT${topk}
# mkdir $task
# mkdir $method

# # Preprocessing
# lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
# echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
# ./LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
# sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
# rm ${method}/_*
# python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# # Training SVM
# fold=5
# for i in `seq 1 $fold`;
# do
    # python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
# done    

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
# done

# wait

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
# done    

# wait

# mv tmp_* $method/ 

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
# done

# wait

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
# done    

# echo "Average Scores:"
# cat $method/res_* | python3 metric/avg_validation.py


###############################################################
# ICE 20x10 
###############################################################
# topk=20x10
# embd_method=sample_sensi/1
# embd=item.embd.2000
# task=task/classification
# method=${task}/ICE${topk}
# mkdir $task
# mkdir $method

# # Preprocessing
# lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
# echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
# ./LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
# sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
# rm ${method}/_*
# python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# # Training SVM
# fold=5
# for i in `seq 1 $fold`;
# do
    # python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
# done    

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
# done

# wait

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
# done    

# wait

# mv tmp_* $method/ 

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
# done

# wait

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
# done    

# echo "Average Scores:"
# cat $method/res_* | python3 metric/avg_validation.py


###############################################################
# BPT 10 
###############################################################
# topk=10
# embd_method=task/classification/BPT${topk}
# embd=item.embd.2000
# task=task/classification
# method=${task}/BPT${topk}
# mkdir $task
# mkdir $method

# # Preprocessing
# lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
# echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
# ./LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
# sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
# rm ${method}/_*
# python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# # Training SVM
# fold=5
# for i in `seq 1 $fold`;
# do
    # python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
# done    

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
# done

# wait

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
# done    

# wait

# mv tmp_* $method/ 

# for i in `seq 1 $fold`;
# do
    # ./libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
# done

# wait

# for i in `seq 1 $fold`;
# do
    # python2 ./libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
# done    

# echo "Average Scores:"
# cat $method/res_* | python3 metric/avg_validation.py


###############################################################
# Other ICEs 
###############################################################
# for topk in 20x5 10x10 10x5
# do
    # embd_method=task/classification/ICE${topk}
    # embd=item.embd.2000
    # task=task/classification
    # method=${task}/ICE${topk}
    # mkdir $task
    # mkdir $method

    # # Preprocessing
    # lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
    # echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
    # ./LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
    # sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
    # rm ${method}/_*
    # python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

    # # Training SVM
    # fold=5
    # for i in `seq 1 $fold`;
    # do
        # python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
    # done    

    # for i in `seq 1 $fold`;
    # do
        # python2 ./libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
    # done

    # wait

    # for i in `seq 1 $fold`;
    # do
        # ./libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
    # done    

    # wait

    # mv tmp_* $method/ 

    # for i in `seq 1 $fold`;
    # do
        # ./libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
    # done

    # wait

    # for i in `seq 1 $fold`;
    # do
        # python2 ./libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
    # done    

    # echo "Average Scores:"
    # cat $method/res_* | python3 metric/avg_validation.py

# done


###############################################################
# Train for classification (other settings) W1
###############################################################
# task=task/classification
# SAMP=512
# mkdir $task
# for topk in 20x1 20x3 20x5 20x8 20x10 10x1 10x3 10x5 10x8 10x10
# do
    # CUR_DIR=${task}/wICE${topk}/
    # mkdir $CUR_DIR
    # ./ICE/ICE/ice -text data/ice_full_top${topk}_w0.edge -textrep ${CUR_DIR}full.embd.${SAMP} -textcontext ${CUR_DIR}context.embd.${SAMP} -dim 300 -sample $SAMP -neg 5 -alpha 0.025 -thread 50 
# done

# for topk in 20x1 20x3 20x5 20x8 20x10 10x1 10x3 10x5 10x8 10x10
# do
    # CUR_DIR=${task}/wICE${topk}/
    # grep ^w_ ${CUR_DIR}context.embd.${SAMP} > ${CUR_DIR}word_context.embd.${SAMP}
    # ./ICE/ICE/ice -text data/ice_tt_top${topk}_w1.edge -textrep ${CUR_DIR}word.embd.${SAMP} -textcontext ${CUR_DIR}word_context_post.embd.${SAMP} -load_embd1 ${CUR_DIR}word_context.embd.${SAMP} -dim 300 -sample $SAMP -neg 5 -alpha 0.025 -thread 50 -entity data/ice_et_top${topk}_w1.edge -save ${CUR_DIR}item.embd.${SAMP}
# done

# for topk in 20x1 20x3 20x5 20x8 20x10 10x1 10x3 10x5 10x8 10x10
# do
    # embd_method=task/classification/wICE${topk}
    # embd=item.embd.512
    # task=task/classification
    # method=${embd_method}
    # # Preprocessing
    # lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
    # echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
    # ./LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
    # sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
    # rm ${method}/_*
    # python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

    # # Training SVM
    # fold=5
    # for i in `seq 1 $fold`;
    # do
        # python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
    # done    

    # for i in `seq 1 $fold`;
    # do
        # python2 ./libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
    # done

    # wait

    # for i in `seq 1 $fold`;
    # do
        # ./libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
    # done    

    # wait

    # mv tmp_* $method/ 

    # for i in `seq 1 $fold`;
    # do
        # ./libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
    # done

    # wait

    # for i in `seq 1 $fold`;
    # do
        # python2 ./libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
    # done    
# done

for topk in 20x1 20x3 20x5 20x8 20x10 10x1 10x3 10x5 10x8 10x10
do
    
    method=task/classification/wICE${topk}
    echo ${topk}": Average Scores:" >> visualize/log/cls_sensi_report.txt
    cat $method/res_* | python3 metric/avg_validation.py >> visualize/log/cls_sensi_report.txt
done

