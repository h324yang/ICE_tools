REPK=20
EXPK=1
DIR="sample_sensi/"

python3 metric/retrieval_monitor.py -dir $DIR -text word${REPK}x${EXPK}.embd -entity item${REPK}x${EXPK}.embd -context context${REPK}x${EXPK}.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds.json


