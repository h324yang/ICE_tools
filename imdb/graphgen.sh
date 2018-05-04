###############################################################
# Generate pseudo embedding model for filtering
###############################################################
# python3 preprocess/gen_pseudo_embd.py pretrain/GoogleNews-vectors-negative300.bin pretrain/pseudo_pretrain.txt


###############################################################
# Generate tfidf json
###############################################################
# python3 preprocess/gen_tfidf_json.py -omdb OMDB_dataset/OMDB.json -save OMDB_dataset/omdb_keyword_tfidf.json -topM 20 -weighted 1 -w2v_filter pretrain/pseudo_pretrain.txt 


###############################################################
# Generate partial embedding
###############################################################
# python3 preprocess/gen_partial_embd.py pretrain/GoogleNews-vectors-negative300.bin OMDB_dataset/omdb_keyword_tfidf.json pretrain/partial_embd.txt


###############################################################
# Generate et/tt graphs
###############################################################
echo "Start generating ET and TT relation edge lists..."
INFO_PATH="OMDB_dataset/omdb_keyword_tfidf.json"
EMBD_PATH="pretrain/partial_embd.txt"
SAVE_PATH="data/"
GEN_LIB="../gen_ice_network/UPLOAD_ice_network"

for REPK in 10 # 5 10
do
    for WEIGHTED in 0 1
    do
        for MAX_REPK in 10
        do
            ET_PATH=$SAVE_PATH"et_top"$REPK"_w"$WEIGHTED".edge"
            echo "Generating "$ET_PATH
            python3 $GEN_LIB/gen_et.py -info $INFO_PATH -embd $EMBD_PATH -repk $REPK -max_repk $MAX_REPK -et $ET_PATH -w $WEIGHTED
        done

        for EXPK in 5 # 1 3 5 8 10
        do
            TT_PATH=$SAVE_PATH"tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            echo "Generating "$TT_PATH
            python3 $GEN_LIB/gen_tt.py -embd $EMBD_PATH -et $ET_PATH -expk $EXPK -tt $TT_PATH -w $WEIGHTED
        done
    done
done
echo "Finished generating ET and TT relation edge lists."


###############################################################
# Construct ICE network
###############################################################
SAVE_PATH="data/"
for REPK in 10 # 5 10
do
    for WEIGHTED in 0 1
    do
        ET_PATH=$SAVE_PATH"et_top"$REPK"_w"$WEIGHTED".edge"

        for EXPK in 5 # 1 3 5 8 10
        do
            TT_PATH=$SAVE_PATH"tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            ICE_FULL_PATH=$SAVE_PATH"ice_full_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            ICE_ET_PATH=$SAVE_PATH"ice_et_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            ICE_TT_PATH=$SAVE_PATH"ice_tt_top"$REPK"x"$EXPK"_w"$WEIGHTED".edge"
            python3 ../ICE/ICE/construct_graph.py -et $ET_PATH -tt $TT_PATH -ice_full $ICE_FULL_PATH -ice_et $ICE_ET_PATH -ice_tt $ICE_TT_PATH -w $WEIGHTED
        done
    done
done
echo "Finished generating ET and TT relation edge lists."

