#!/usr/bin/env python
from z3 import *

pis = []
vis = []

for line in open("input.txt").readlines():
    line = line.strip()
    pos, vel = line.split(" @ ")
    p = [int(i) for i in pos.split(",")]
    v = [int(i) for i in vel.split(",")]
    pis.append(p)
    vis.append(v)

idx1 = 0
idx2 = 1
idx3 = 2

p1 = pis[idx1]
p2 = pis[idx2]
p3 = pis[idx3]

v1 = vis[idx1]
v2 = vis[idx2]
v3 = vis[idx3]

px = Int('px')
py = Int('py')
pz = Int('pz')

vx = Int('vx')
vy = Int('vy')
vz = Int('vz')

t1 = Int('t1')
t2 = Int('t2')
t3 = Int('t3')

p1x = IntVal(p1[0])
p1y = IntVal(p1[1])
p1z = IntVal(p1[2])
v1x = IntVal(v1[0])
v1y = IntVal(v1[1])
v1z = IntVal(v1[2])

p2x = IntVal(p2[0])
p2y = IntVal(p2[1])
p2z = IntVal(p2[2])
v2x = IntVal(v2[0])
v2y = IntVal(v2[1])
v2z = IntVal(v2[2])

p3x = IntVal(p3[0])
p3y = IntVal(p3[1])
p3z = IntVal(p3[2])
v3x = IntVal(v3[0])
v3y = IntVal(v3[1])
v3z = IntVal(v3[2])

solve(px + t1 * vx == p1x + t1 * v1x,
      px + t2 * vx == p2x + t2 * v2x,
      px + t3 * vx == p3x + t3 * v3x,
      py + t1 * vy == p1y + t1 * v1y,
      py + t2 * vy == p2y + t2 * v2y,
      py + t3 * vy == p3y + t3 * v3y,
      pz + t1 * vz == p1z + t1 * v1z,
      pz + t2 * vz == p2z + t2 * v2z,
      pz + t3 * vz == p3z + t3 * v3z,
      t1 > 0,
      t2 > 0,
      t3 > 0,
      )
