import os
import sys
from itertools import groupby

argv = sys.argv
infile = argv[1]
print infile.split(".fa")[0]
outfile = "%s.no_contigs.fa" % infile.split(".fa")[0]
print outfile

def write_60(line, oF, forceLast):
    """
    Fold a long line to multiple lines
    with width 60    
    """
    line = line.rstrip()
    start=0
    lineLen = len (line)
    while lineLen - start >= 60:
        print >> oF, line[start:start+60]
        start += 60
    if forceLast:
        print >> oF, line[start:]
        return ''
    # Return the remainder that didn't fill a line, so 
    # that we can use it to start the next bunch.
    return line[start:]

def fasta_iter(fasta_name):
    """
    given a fasta file. yield tuples of header, length of sequence
    """
    fh = open(fasta_name)
    # ditch the boolean (x[0]) and just keep the header or sequence since
    # we know they alternate.
    faiter = (x[1] for x in groupby(fh, lambda line: line[0] == ">"))
    for header in faiter:
        # drop the ">"
        header = header.next()[1:].strip()
        # join all sequence lines to one.
        seq = "".join(s.strip() for s in faiter.next())
        yield header, seq


chrs = map(lambda x: str(x), range(1,20))
chrs.append("X")
chrs.append("Y")
chrs.append("MT")

#infile = "genome_with_contigs.fa"
#outfile ="genome_without_contigs.fa"
ofh = open(outfile,"w")
sIter = fasta_iter(infile)
for id, seq in sIter:
     print id
     chr = id.split()[0]
     if chr in chrs:
        ofh.write(">"+id+"\n")
        line=write_60(seq,ofh,False)
        if line != "":
           ofh.write(line)
           ofh.write("\n")
ofh.close()
