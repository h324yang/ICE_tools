from sys import stdin, stdout
import re
import numpy as np

res = ""

t = stdin.read()
vals = re.findall('0.[0-9]+', t)
vals = np.array(vals).astype(np.float32)

ratio = 0.
micro = 0.
macro = 0.
n = len(vals)/3.
for i, v in enumerate(vals):
    if i % 3 == 0:
        ratio += v
    elif i % 3 == 1:
        micro += v
    else:
        macro += v

res += "Exact match ratio: %.3f\n"%(ratio/n)
res += "Microaverage F-measure: %.3f\n"%(micro/n)
res += "Macroaverage F-measure: %.3f\n"%(macro/n)

stdout.write(res)
