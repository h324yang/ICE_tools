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
for topk in 20x5 10x10 10x5
do
    embd_method=task/classification/ICE${topk}
    embd=item.embd.2000
    task=task/classification
    method=${task}/ICE${topk}
    mkdir $task
    mkdir $method

#     # Preprocessing
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

#     echo "Average Scores:"
    cat $method/res_* | python3 metric/avg_validation.py

done
