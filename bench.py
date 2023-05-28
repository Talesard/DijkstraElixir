import sys
import time
import os

def par(n):
    t0 = time.time()
    os.system(f'elixir parallel.exs {n}')
    return time.time() - t0

def seq(n):
    t0 = time.time()
    os.system(f'elixir serial.exs {n}')
    return time.time() - t0


n = int(sys.argv[1])

seq_t = seq(n)
par_t = par(n)

print('Seq:', seq_t, 'Par:', par_t)