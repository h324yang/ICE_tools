###############################################################
# Generate pseudo embedding model for filtering
###############################################################
# python3 preprocess/gen_pseudo_embd.py pretrain/GoogleNews-vectors-negative300.bin pretrain/pseudo_pretrain.txt


###############################################################
# Generate tfidf json
###############################################################
# python3 preprocess/gen_tfidf_json.py -omdb OMDB_dataset/OMDB.json -save data/omdb_keyword_tfidf.json -topM 20 -weighted 1 -w2v_filter pretrain/pseudo_pretrain.txt 


###############################################################
# Generate partial embedding
###############################################################
# python3 preprocess/gen_partial_embd.py pretrain/GoogleNews-vectors-negative300.bin data/omdb_keyword_tfidf.json pretrain/partial_embd.txt


###############################################################
# Generate et/tt graphs
###############################################################
# echo "Start generating ET and TT relation edge lists..."
# INFO_PATH="data/omdb_keyword_tfidf.json"
# EMBD_PATH="pretrain/partial_embd.txt"
# SAVE_PATH="data/"

# for REPK in 5 10 15 20
# do
    # for WEIGHTED in 0 1
    # do
        # for MAX_REPK in 20
        # do
            # ET_PATH=$SAVE_PATH"et_top"$REPK"_w"$WEIGHTED".edge"
            # echo "Generating "$ET_PATH
            # python3 ice_relation_generator/1_gen_relation/gen_et.py -load_info $INFO_PATH -load_embd $EMBD_PATH -repk $REPK -max_repk $MAX_REPK -save_et $ET_PATH -weighted $WEIGHTED
        # done

        # for EXPK in 3 5
        # do
            # TT_PATH=$SAVE_PATH"tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            # echo "Generating "$TT_PATH
            # python3 ice_relation_generator/1_gen_relation/gen_tt.py -load_embd $EMBD_PATH -load_et $ET_PATH -expk $EXPK -save_tt $TT_PATH -weighted $WEIGHTED
        # done
    # done
# done
# echo "Finished generating ET and TT relation edge lists."


###############################################################
# Construct ICE network
###############################################################
# SAVE_PATH="data/"
# for REPK in 5 10 15 20
# do
    # for WEIGHTED in 0 1
    # do
        # ET_PATH=$SAVE_PATH"et_top"$REPK"_w"$WEIGHTED".edge"

        # for EXPK in 3 5
        # do
            # TT_PATH=$SAVE_PATH"tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            # ICE_FULL_PATH=$SAVE_PATH"ice_full_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            # ICE_ET_PATH=$SAVE_PATH"ice_et_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            # ICE_TT_PATH=$SAVE_PATH"ice_tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            # python3 ICE/ICE/construct_graph.py -et $ET_PATH -tt $TT_PATH -ice_full $ICE_FULL_PATH -ice_et $ICE_ET_PATH -ice_tt $ICE_TT_PATH -w $WEIGHTED
        # done
    # done
# done
# echo "Finished generating ET and TT relation edge lists."


###############################################################
# Reproduce SIGIR result
###############################################################
# mkdir reproduce
# REPK=20
# EXPK=5
# WEIGHTED=0
# SAVE_PATH="data/"
# for i in `seq 1 5`;
# do
    # ./ICE/ICE/ice -text $SAVE_PATH"ice_tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge" -entity $SAVE_PATH"ice_et_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge" -textrep reproduce/word${i}.embd -save reproduce/item${i}.embd -textcontext reproduce/context${i}.embd -dim 300 -sample 200 -neg 2 -alpha 0.025 -thread 20 
# done


###############################################################
# Evaluate reproduced retrieval task
###############################################################
REPK=20
EXPK=5
WEIGHTED=0
SAVE_PATH="data/"
for i in `seq 1 5`;
do
    echo "Evaluating top"$REPK"x"$EXPK"_w"$WEIGHTED": Round"${i}
    python3 metric/retrieval_eval.py -text reproduce/word${i}.embd -entity reproduce/item${i}.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds.json
done


###############################################################
# Sensitivity analysis
###############################################################
# mkdir sensi_test
# for i in `seq 1 3`
# do
    # for dim in 64 128 300 
    # do
        # for samp in 50 100 200 300
        # do
            # ./ICE/ICE/ice -text data/omdb_ice_tt.txt -entity data/omdb_ice_et.txt -textrep sensi_test/dim${dim}_samp${samp}_word${i}.embd -textcontext sensi_test/context.embd -save sensi_test/dim${dim}_samp${samp}_item${i}.embd -dim ${dim} -sample ${samp} -neg 2 -alpha 0.025 -thread 20 
        # done
    # done
# done


