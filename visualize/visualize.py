from collections import defaultdict
from operator import itemgetter
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
matplotlib.rcParams['text.usetex'] = True


def genre_check(line, genres):
    for g in genres:
        if line.startswith(g):
            cur_g, precision = line.strip().split()
            if precision: precision = float(precision)
            return cur_g, precision
    return None, None


def read_log(log_p, final=None):
    dd_list = lambda : defaultdict(list)
    log = defaultdict(dd_list)
    iter_trained = None
    cur_topk = None
    genres = ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi", "Average"]
    with open(log_p) as f:
        for line in f:
            if line.startswith("Evaluating"):
                iter_trained = line.strip().split()[-2]
                if final and iter_trained == 'final': iter_trained = final
            if line.startswith("Precision@"):
                cur_topk = line.strip().split("@")[-1][:-1]
            genre, prec = genre_check(line, genres)
            if genre:
                log[cur_topk][genre].append((int(iter_trained), prec))

    return log


def draw_log(log):
    pp = PdfPages('fig.pdf')
    r = 1
    for prec, genre_logs in log.items():
        for genre, logs in genre_logs.items():
            xs = []
            ys = []
            for x, y in sorted(logs, key=itemgetter(0)):
                xs.append(x)
                ys.append(y)
            plt.subplot(2, 1, r)
            plt.plot(xs, ys, label=genre+"@"+prec)
        r += 1
        lgd = plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))

    plt.savefig(pp, bbox_extra_artists=(lgd,), bbox_inches='tight', format='pdf')
    pp.close()


if __name__ == "__main__":
    log = read_log("20x10_80k_monitor_log_1.txt", 80000)
    draw_log(log)



