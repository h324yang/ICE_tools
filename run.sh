# python3 utils/gen_et.py -omdb OMDB_dataset/OMDB.json -save data/omdb_et.txt -topM 20 -weighted 0 -w2v_filter pretrain/GoogleNews-vectors-negative300.bin 
# python3 utils/gen_tt.py -et data/omdb_et.txt -w2v_embd pretrain/GoogleNews-vectors-negative300.bin -output data/omdb_tt.txt -expk 5 -weighted 0
# python3 ICE/ICE/construct_graph.py -et data/omdb_et.txt -tt data/omdb_tt.txt -ice_full data/omdb_ice.txt -ice_et data/omdb_ice_et.txt -ice_tt data/omdb_ice_tt.txt -w 0

# reproducing SIGIR result
# mkdir reproduce
# for i in `seq 1 5`;
# do
    # ./ICE/ICE/ice -text data/omdb_ice_tt.txt -entity data/omdb_ice_et.txt -textrep reproduce/word${i}.embd -save reproduce/item${i}.txt -textcontext reproduce/context.txt -dim 300 -sample 200 -neg 2 -alpha 0.025 -thread 20 
# done

# doing sensitivity analysis
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

# evaluating retrieval task

