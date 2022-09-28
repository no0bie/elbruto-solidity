#!/usr/bin/python

import json, os 

os.system("rm build/contracts/*.json")
os.system("truffle migrate")

count = 1
filesNames = []

for files in os.walk('build/contracts'):
    filesNames = files[2]
    for x in files[2]: 
        if (x != "Migrations.json"): 
            print(str(count) + "- " + x);count+=1


file = input("\n >> ")
jsonData = json.load(open("build/contracts/" + filesNames[int(file) - 1]))
abi = jsonData['abi']
address = jsonData['networks']['5777']['address']

file = open("../elbruto/src/config.js", "w")
file.write(f'export const CONTRACT_ADDRESS = "{address}";\nexport const CONTRACT_ABI = {str(abi).replace("False", "false").replace("True", "true")}')
file.close()