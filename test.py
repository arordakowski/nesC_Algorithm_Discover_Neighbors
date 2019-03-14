#! /usr/bin/python
from TOSSIM import *

t = Tossim([])
r = t.radio()
saida = open("log.txt", "w")
f = open("simulador/topologia.txt", "r")

for line in f:
  s = line.split()
  if s:
    r.add(int(s[0]), int(s[1]), float(s[2]))

t.addChannel("Boot", saida)

noise = open("simulador/meyer-heavy.txt", "r")
for line in noise:
  str1 = line.strip()
  if str1:
    val = int(str1)
    for i in range(1, 13):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(1, 13):
  t.getNode(i).createNoiseModel()

t.getNode(1).bootAtTime(180001);
t.getNode(2).bootAtTime(180008);
t.getNode(3).bootAtTime(180000);
t.getNode(4).bootAtTime(180007);
t.getNode(5).bootAtTime(180001);
t.getNode(6).bootAtTime(180008);
t.getNode(7).bootAtTime(180000);
t.getNode(8).bootAtTime(180007);
t.getNode(9).bootAtTime(180001);
t.getNode(10).bootAtTime(180008);
t.getNode(11).bootAtTime(180000);
t.getNode(12).bootAtTime(180007);

for i in range(1000):
  t.runNextEvent()
