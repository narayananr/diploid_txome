#!/usr/bin/env python
import os
import sys

argv = sys.argv
outfile = argv[1]
infile = "%s.orig" % outfile
os.rename(outfile, infile)

chromosomes = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15' ,'16', '17', '18', '19', 'X', 'Y', 'MT']
chromosomes = dict.fromkeys(chromosomes, True)

fhin  = open(infile)
fhout = open(outfile, 'w')
for curline in fhin:
    item = curline.rstrip().split("\t")
    chrid = item[0]
    # chrid, hap = item[0].split("_")
    if chromosomes.has_key(chrid):
        fhout.write(curline)
fhout.close()
fhin.close()

