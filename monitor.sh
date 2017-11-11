DIR="sample_sensi/"

python3 metric/retrieval_monitor.py -dir $DIR -text word.embd -entity item.embd -context context.embd -split full.embd -omdb OMDB_dataset/OMDB.json -seeds OMDB_dataset/genre_seeds.json


