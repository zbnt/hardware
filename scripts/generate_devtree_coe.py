#!/usr/bin/env python3
"""
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
"""

import sys
import subprocess

from zbnt_version import *

if len(sys.argv) != 4:
	print("Usage:", sys.argv[0], "[input] [output] [type]")
	exit(1)

input_path = sys.argv[1]
output_path = sys.argv[2]
dtb_type = sys.argv[3].upper()

if dtb_type not in ["ST", "RP"]:
	print("Invalid type, valid values: ST, RP")
	exit(1)

# Magic

raw_data = b"ZBNT\x00" + dtb_type.encode("UTF-8") + b"\x00"

# Version

version_text, version_int, version_prerel, version_commit, version_dirty = get_version()
raw_data += version_int.to_bytes(4, byteorder="little")
raw_data += version_prerel.encode("UTF-8") + b"\x00" * (16 - len(version_prerel))
raw_data += version_commit.encode("UTF-8") + b"\x00" * (16 - len(version_commit))
raw_data += version_dirty.to_bytes(2, byteorder="little")

# Check if we actually have to regenerate the output file

if os.path.exists(output_path) and os.path.getmtime(input_path) <= os.path.getmtime(output_path):
	with open(output_path) as file_handle:
		version_stored = file_handle.readline()[1:].strip()

		if version_stored == version_text:
			print("0")
			exit(0)

# Compile device tree

process = subprocess.Popen(["dtc", "-I", "dts", "-O", "dtb", "-@", input_path], stdout=subprocess.PIPE)
dtb_data, _ = process.communicate()

if process.returncode != 0:
	print("Error: dtc exited with code {0}".format(process.returncode))
	exit(1)

raw_data += len(dtb_data).to_bytes(2, byteorder="little")
raw_data += dtb_data

if len(raw_data) > 32768:
	print("Error: Compiled dts exceeds the limit of 32720 bytes".format(len(raw_data)))
	exit(1)

# Generate coe file

with open(output_path, "w") as file_handle:
	file_handle.write("; " + version_text + "\nmemory_initialization_radix=16;\nmemory_initialization_vector=\n")

	for i in range(0, len(raw_data), 8):
		if i != 0:
			file_handle.write(",\n")

		file_handle.write("{:016x}".format(int.from_bytes(raw_data[i:i+8], byteorder="little")))

	file_handle.write(";")

print("1")
