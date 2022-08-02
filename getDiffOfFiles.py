import argparse
from difflib import Differ
import difflib
import re

parser = argparse.ArgumentParser(description='Pass the 2 txt files to find diff')
parser.add_argument('-f1','--file1', help='get the file 1 name', required=True)
parser.add_argument('-f2','--file2', help='get the file 2 name', required=True)
args = vars(parser.parse_args())

file1name = args["file1"]
file2name = args["file2"]

before, mk1, before = file1name.partition("_")
subStrfile1, mk2, after = before.partition(".")
before, mk1, before = file2name.partition("_")
subStrfile2, mk2, after = before.partition(".")
fileToWrite = subStrfile1 + subStrfile2 + ".txt"

with open(file1name) as file_1, open(file2name) as file_2:
    differ = Differ()
    print("Adding Diff to File ==> " + fileToWrite)
  
    for line in differ.compare(file_2.readlines(), file_1.readlines()):
        for prefix in ('- ', '+ '):
            if line.startswith(prefix):
                print(line, end ="")
                f = open(fileToWrite, "a")
                f.write(line)
                f.close()
            else:
                pass

