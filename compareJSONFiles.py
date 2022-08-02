import json
import argparse


parser = argparse.ArgumentParser(description='Pass the 1 json to find diff')
parser.add_argument('-j','--json', help='get the json name', required=True)
args = vars(parser.parse_args())

fileToWrite = "repos_to_update.txt"

reponame = args["json"]

f1 = open("jsonsourcefilespackage/"+reponame+".json")
f2 = open("jsontargetfilespackage/"+reponame+".json")

json_dict1 = json.loads(f1.read())
json_dict2 = json.loads(f2.read())

companreResult = sorted(json_dict1.items()) == sorted(json_dict2.items())
print("Comparing for " + str(reponame) + " and its ==> " + str(companreResult))

if companreResult:
    print("Skipping " + reponame + " as there is not config change")
else:
    print("Adding " + reponame + " for update repo config")
    f = open(fileToWrite, "a")
    f.write("+ "+reponame+"\n")
    f.close()
    

