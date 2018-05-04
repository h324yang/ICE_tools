###############################################################
# Bipartite 5/10 
###############################################################
# SAMP=12000
# for topk in 5 10
SAMP=40
for topk in 10
do
embd=item.embd
task=task/classification
method=${task}/BPT${topk}
mkdir $task
mkdir $method
awk '{print $2 " " $1 " " $3}' data/et_top${topk}_w0.edge | cat - data/et_top${topk}_w0.edge | sort | uniq > data/et_top${topk}_w0_bidir.edge
../LINE/linux/line -train data/et_top${topk}_w0_bidir.edge -output ${method}/_full.embd -size 300 -samples $SAMP -negative 5 -rho 0.025 -threads 50
sed 1,1d ${method}/_full.embd > ${method}/full.embd # delete the header
python3 metric/retrieval_folder.py -dir ${method}/ -text word.embd -entity item.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds_graphrank_w.json 

# Preprocessing
lines="$(wc -l ${method}/${embd} | cut -d' ' -f1)"
echo "${lines} 300" | cat - ${method}/${embd} > ${method}/_${embd}
../LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
rm ${method}/_*
python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# Training SVM
fold=5
for i in `seq 1 $fold`;
do
    python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
done    

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
done

wait

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
done    

wait

mv tmp_* $method/ 

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
done

wait

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
done    

echo "Average Scores:"
cat $method/res_* | python3 metric/avg_validation.py

done


###############################################################
# ICE 10x5 5x5 
###############################################################
# SAMP=12000
# for topk in 5x5 10x5
SAMP=40
for topk in 10x5
do
embd_method=sample_sensi/ice_${topk}_1
embd=item.embd.${SAMP}
task=task/classification
method=${task}/ICE${topk}
mkdir $task
mkdir $method

# Preprocessing
lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
../LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
rm ${method}/_*
python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# Training SVM
fold=5
for i in `seq 1 $fold`;
do
    python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
done    

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
done

wait

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
done    

wait

mv tmp_* $method/ 

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
done

wait

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
done    

echo "Average Scores:"
cat $method/res_* | python3 metric/avg_validation.py
done


###############################################################
# wICE 10x5 5x5 
###############################################################
# SAMP=4000
# for topk in 5x5 10x5
SAMP=40
for topk in 10x5
do
embd_method=sample_sensi/wice_${topk}_1
embd=item.embd.${SAMP}
task=task/classification
method=${task}/wICE_${topk}
mkdir $task
mkdir $method

# Preprocessing
lines="$(wc -l ${embd_method}/${embd} | cut -d' ' -f1)"
echo "${lines} 300" | cat - ${embd_method}/${embd} > ${method}/_${embd}
../LINE/linux/normalize -input ${method}/_${embd} -output ${method}/_normalized_${embd} -binary 0
sed 1,1d ${method}/_normalized_${embd} > ${method}/normalized_${embd}
rm ${method}/_*
python3  preprocess/gen_libsvm_data.py ${method}/normalized_${embd} OMDB_dataset/id2genres.json ${method}/data

# Training SVM
fold=5
for i in `seq 1 $fold`;
do
    python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
done    

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
done

wait

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
done    

wait

mv tmp_* $method/ 

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
done

wait

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
done    

echo "Average Scores:"
cat $method/res_* | python3 metric/avg_validation.py
done


###############################################################
# AVGEMB 
###############################################################
# for topk in 5 10
for topk in 10
do
task=task/classification
method=${task}/avgemb${topk}
mkdir $task
mkdir $method
python3 AVGEMB/avgemb.py -entity ${method}/item.embd -text ${method}/word.embd -et data/et_top${topk}_w0.edge -w2v pretrain/partial_embd.txt
# Preprocessing
lines="$(wc -l ${method}/item.embd | cut -d' ' -f1)"
echo "${lines} 300" | cat - ${method}/item.embd > ${method}/_item.embd
../LINE/linux/normalize -input ${method}/_item.embd -output ${method}/_normalized_item.embd -binary 0
sed 1,1d ${method}/_normalized_item.embd > ${method}/normalized_item.embd
rm ${method}/_*
python3  preprocess/gen_libsvm_data.py ${method}/normalized_item.embd OMDB_dataset/id2genres.json ${method}/data

# Training SVM
fold=5
for i in `seq 1 $fold`;
do
    python2  preprocess/random_select.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/data $fold
done    

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/trans_class.py $method/train\_$fold\_$i $method/test\_$fold\_$i $method/tmp_train\_$i $method/tmp_class\_$i $method/tmp_test\_$i
done

wait

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-train -t 0 $method/tmp_train\_$i &
done    

wait

mv tmp_* $method/ 

for i in `seq 1 $fold`;
do
    ../libsvm-3.22/svm-predict $method/tmp_test\_$i $method/tmp_train\_$i.model $method/o\_$i &
done

wait

for i in `seq 1 $fold`;
do
    python2 ../libsvm-3.22/measure.py $method/test\_$fold\_$i $method/o\_$i $method/tmp_class\_$i > $method/res\_$i
done    

echo "Average Scores:"
cat $method/res_* | python3 metric/avg_validation.py
done


