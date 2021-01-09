from topology import nodes
import os
import math
import sys
through_act = {}
through_lat = {}
loss = {}

for nodeA in nodes:
  for nodeB in nodes:
    if nodeA != nodeB:
      for port in range(10):
        thrsum = 0
        with open(f"results/{sys.argv[1]}/od_data/n{nodes.index(nodeA)}-n{nodes.index(nodeB)}-p{port+1}.thr", "r") as f:
          for i in range(41):
            l = f.readline()
            if int(l[:2]) >= 20:
              l_t = l.split(" ")
              thrsum += float(l_t[1].replace("\n",""))
      if nodeA+nodeB in through_act.keys():
        through_act[nodeA+nodeB] += thrsum/21/100000
      else:
        through_act[nodeA+nodeB] =  thrsum/21/100000
 

for nodeA in nodes:
  for nodeB in nodes:
    if nodeA != nodeB:
      losssum = 0
      for port in range(10):
        with open(f"results/{sys.argv[1]}/od_data/n{nodes.index(nodeA)}-n{nodes.index(nodeB)}-p{port+1}.loss", "r") as f:
          for i in range(41):
            l = f.readline()
            if int(l[:2]) >= 20:
              l_t = l.split(" ")
              losssum += float(l_t[1].replace("\n",""))
              
      if nodeA+nodeB in loss.keys():
        loss[nodeA+nodeB] += losssum/210
      else:
        loss[nodeA+nodeB] = losssum/210
          
for nodeA in nodes:
  for nodeB in nodes:
    if nodeA != nodeB:
      through_lat[nodeA+nodeB] = (1 / math.exp(-13.1 * loss[nodeA+nodeB])) * through_act[nodeA+nodeB]

print(f"actual = {repr(through_act)}")
print(f"latent = {repr(through_lat)}")
print(f"loss = {repr(loss)}")