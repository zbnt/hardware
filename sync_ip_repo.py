#!/usr/bin/env python3

import os
import json
import shutil

g_modules = dict()

def scan_modules(path):
	global g_modules

	fixed_path = path[7:]

	for f in os.listdir(path):
		full_path = os.path.join(path, f)

		if os.path.isfile(full_path) and (f[-3:] == ".sv" or f[-2:] == ".v"):
			fixed_full_path = full_path[4:(-2 if f[-2] == "." else -3)]

			g_modules[fixed_full_path] = [full_path]

			if len(fixed_path):
				if fixed_path not in g_modules:
					g_modules[fixed_path] = []

				g_modules[fixed_path].append(full_path)

		if os.path.isdir(full_path):
			scan_modules(full_path)

scan_modules("hdl")

if not os.path.exists("ip_repo"):
	os.mkdir("ip_repo")

for p in sorted(os.listdir("cores")):
	p_dir = os.path.join("cores", p)

	if not os.path.exists(os.path.join(p_dir, "meta.json")):
		continue

	print(">", p)

	with open(os.path.join(p_dir, "meta.json")) as meta_file:
		p_meta = json.load(meta_file)

	ip_dir = os.path.join("ip_repo", p + "_" + p_meta.get("version", "1.0"))
	ip_src_dir = os.path.join(ip_dir, "src")

	sources = [(os.path.join(p_dir, f), os.path.join(ip_src_dir, f)) for f in os.listdir(p_dir) if f.split(".")[-1] in ["sv", "v"]]

	for d in p_meta.get("imports", []):
		if d not in g_modules:
			print("\t[E] Peripheral", p, "requires dependency", d, "but it wasn't found.")
			exit(1)

		for df in g_modules[d]:
			sources.append( (df, os.path.join(ip_src_dir, os.path.basename(df))) )

	if not os.path.exists(ip_dir):
		os.mkdir(ip_dir)

	if not os.path.exists(ip_src_dir):
		os.mkdir(ip_src_dir)

	for p_file, ip_file in sources:
		needs_update = False

		if os.path.exists(ip_file):
			p_mod_time = os.path.getmtime(p_file)
			ip_mod_time = os.path.getmtime(ip_file)

			if p_mod_time > ip_mod_time:
				needs_update = True
		else:
			needs_update = True

		if needs_update:
			print("\t-", p_file, "=>", ip_file)
			shutil.copy(p_file, ip_file)

	ip_gui_file = os.path.join(ip_dir, os.path.join("xgui", p + "_v" + p_meta.get("version", "1.0")))
	p_gui_file = os.path.join(p_dir, "xgui.tcl")

	if os.path.exists(p_gui_file) or os.path.exists(ip_gui_file):
		p_time = os.path.getmtime(p_gui_file) if os.path.exists(p_gui_file) else 0
		ip_time = os.path.getmtime(ip_gui_file) if os.path.exists(ip_gui_file) else 0

		if not os.path.exists(os.path.join(ip_dir, "xgui")):
			os.mkdir(os.path.join(ip_dir, "xgui"))

		if p_time > ip_time:
			print("\t-", p_gui_file, "=>", ip_gui_file)
			shutil.copy2(p_gui_file, ip_gui_file)
		elif ptime < ip_time:
			print("\t-", ip_gui_file, "=>", p_gui_file)
			shutil.copy2(ip_gui_file, p_gui_file)

	ip_xml_file = os.path.join(ip_dir, "component.xml")
	p_xml_file = os.path.join(p_dir, "component.xml")

	if os.path.exists(p_xml_file) or os.path.exists(ip_xml_file):
		p_time = os.path.getmtime(p_xml_file) if os.path.exists(p_xml_file) else 0
		ip_time = os.path.getmtime(ip_xml_file) if os.path.exists(ip_xml_file) else 0

		if p_time > ip_time:
			print("\t-", p_xml_file, "=>", ip_xml_file)
			shutil.copy2(p_xml_file, ip_xml_file)
		elif p_time < ip_time:
			print("\t-", ip_xml_file, "=>", p_xml_file)

			with open(p_xml_file, "w") as dst_file:
				with open(ip_xml_file) as src_file:
					enableCopy = True

					for l in src_file:
						if enableCopy:
							if l.strip() == "<xilinx:tags>":
								enableCopy = False
								continue

							dst_file.write(l)
						elif l.strip() == "</xilinx:tags>":
							enableCopy = True

			shutil.copystat(ip_xml_file, p_xml_file)
	else:
		print("\t[W] File component.xml not found, create it using Vivado.")

	print("\t- Done\n")
