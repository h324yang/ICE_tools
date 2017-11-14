import retrieval_monitor
import retrieval_eval
import argparse
from os import listdir

def get_args():
    PARSER = argparse.ArgumentParser(description='Evaluating retrival task.')
    PARSER.add_argument('-dir', default=None, help='Path of directory being monitored')
    PARSER.add_argument('-entity', default=None, help='Path of item embeddings')
    PARSER.add_argument('-text', default=None, help='Path of word embeddings')
    PARSER.add_argument('-split', default=None, help='Path of embeddings being splited')
    PARSER.add_argument('-omdb', default=None, help='OMDB dataset')
    PARSER.add_argument('-seeds', default=None, help='Seed words of genres')
    parser.add_argument("-header", type=int, choices=[0,1], default=0, help="(Default: 0) header of embdding files (doesn't exist:0 / exists:1).")
    CONFIG = PARSER.parse_args()
    return CONFIG.dir, CONFIG.entity, CONFIG.text, CONFIG.split, CONFIG.omdb, CONFIG.seeds, bool(CONFIG.header)


class FolderEvaluator(retrieval_monitor.Monitor):
    def __init__(self, DIR, item_p, word_p, split_p, data_p, seed_p, skip_header):
        self.DIR = DIR
        self.item_p = item_p
        self.word_p = word_p
        self.data_p = data_p
        self.seed_p = seed_p
        self.split_p = split_p
        self.splitted = []
        self.skip_header = skip_header


    def run(self):
        id2genres = retrieval_eval.extract_genres(retrieval_eval.load_json(data_p))
        seed_dict = retrieval_eval.load_json(seed_p)
        eval_genres = retrieval_eval.get_eval_genres()
        files = listdir(self.DIR)
        checked = self.check(split_p=self.split_p, wait=0)
        for iter_trained, n_files in checked.items():
            if n_files == 2:
                print("Evaluating %s and %s, trained by %s iterations."%(self.item_p, self.word_p, iter_trained))
                iter_trained = "" if iter_trained == "final" else "."+iter_trained
                cur_item_p = self.DIR + self.item_p + iter_trained
                cur_word_p = self.DIR + self.word_p + iter_trained
                item_embd = retrieval_eval.read_w2v_from_file(cur_item_p, skip_header=self.skip_header)
                word_embd = retrieval_eval.read_w2v_from_file(cur_word_p, skip_header=self.skip_header)
                retrieval_eval.evaluate(eval_genres, id2genres, seed_dict, word_embd, item_embd)


if __name__ == "__main__":
    DIR, item_p, word_p, split_p, data_p, seed_p, skip_header = get_args()
    folder_evaluator = FolderEvaluator(DIR, item_p, word_p, split_p, data_p, seed_p, skip_header)
    folder_evaluator.run()

