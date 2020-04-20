#!/usr/bin/env python3
"""
	This Source Code Form is subject to the terms of the Mozilla Public
	License, v. 2.0. If a copy of the MPL was not distributed with this
	file, You can obtain one at https://mozilla.org/MPL/2.0/.
"""

import os
import re
import subprocess

fallback_version = "2.0.0-beta.2"
version_regex = re.compile(r"^v?([0-9]+)\.([0-9]+)\.([0-9]+)(?:-(?P<prerel>[a-z]+\.[0-9]+))?(?:-(?P<commit>[0-9]+-g[a-f0-9]{7}))?(?P<dirty>-d)?$")

def get_version():
	process = subprocess.Popen(["git", "describe", "--tags", "--abbrev=7", "--dirty=-d"], stdout=subprocess.PIPE)
	raw_version, _ = process.communicate()

	if process.returncode == 0:
		raw_version = raw_version.decode().strip()
	else:
		raw_version = fallback_version

	match = re.fullmatch(version_regex, raw_version)

	if match == None:
		print("Error: Invalid version:", raw_version)
		exit(1)

	match_dict = match.groupdict(default="")

	version_major = int(match.group(1))
	version_minor = int(match.group(2))
	version_patch = int(match.group(3))
	version_prerel = match_dict["prerel"]
	version_commit = match_dict["commit"].replace("-g", ".")
	version_dirty = match_dict["dirty"][1:]

	version = "{0}.{1}.{2}".format(version_major, version_minor, version_patch)
	version_int = (version_major << 24) | (version_minor << 16) | version_patch

	if len(version_prerel):
		version += "-" + version_prerel

	if len(version_commit):
		version += "+" + version_commit

		if len(version_dirty):
			version += ".d"
	elif len(version_dirty):
		version += "+d"

	return (version, version_int, version_prerel, version_commit, not not len(version_dirty))

if __name__ == "__main__":
	print(get_version()[0])
