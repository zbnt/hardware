#
#	This Source Code Form is subject to the terms of the Mozilla Public
#	License, v. 2.0. If a copy of the MPL was not distributed with this
#	file, You can obtain one at https://mozilla.org/MPL/2.0/.
#

import os
import re
import sys
import json
import zipfile
import xml.etree.ElementTree as ET

if len(sys.argv) != 3:
	print("Usage:", sys.argv[0], "<input file> <output file>")
	exit(1)

if not os.path.exists(sys.argv[1]):
	print("[E] Source file doesn't exist")
	exit(1)

with zipfile.ZipFile(sys.argv[1]) as zipFile:
	for f in zipFile.infolist():
		if f.filename[-4:] == ".hwh":
			with zipFile.open(f.filename) as hwhFile:
				tree = ET.parse(hwhFile)
				root = tree.getroot()

modules = {}

for m in root.findall("MODULES/MODULE"):
	if ":zbnt_hw:" in m.attrib["VLNV"] or "xilinx.com:ip:tri_mode_ethernet_mac:" in m.attrib["VLNV"]:
		moduleInfo = {
			"type": m.attrib["MODTYPE"],
			"base": m.findall("PARAMETERS/PARAMETER[@NAME='C_BASEADDR']")[0].attrib["VALUE"],
			"connections": {}
		}

		if ":zbnt_hw:" in m.attrib["VLNV"]:
			for p in m.findall("./PORTS/PORT"):
				for c in p.findall("./CONNECTIONS/CONNECTION"):
					portName = p.attrib["NAME"]
					connModule = c.attrib["INSTANCE"][::-1].lower()
					connPort = c.attrib["PORT"]

					match = re.search("([0-4]hte)", connModule)

					if match != None:
						connModule = match.group(1)[::-1]
					else:
						connModule = "?"

					if connPort[0] in "tr" and connPort[1:] in ["x_axis_mac_tdata", "x_statistics_vector"]:
						moduleInfo["connections"][portName] = connModule

		modules[m.attrib["FULLNAME"]] = moduleInfo

with open(sys.argv[2], "w") as outFile:
	json.dump(modules, outFile, indent=8)
