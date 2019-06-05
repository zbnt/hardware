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

def sync_files(file_a, file_b, bidir=True):
	time_a = os.path.getmtime(file_a) if os.path.exists(file_a) else -1
	time_b = os.path.getmtime(file_b) if os.path.exists(file_b) else -1

	if time_a == -1 and time_b == -1:
		return -1

	if time_a > time_b:
		print("\t-", file_a, "=>", file_b)
		shutil.copy2(file_a, file_b)
		return 1
	elif time_a < time_b and bidir:
		print("\t-", file_b, "=>", file_a)
		shutil.copy2(file_b, file_a)
		return 2

	return 0

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
	ip_xci_dir = os.path.join(ip_dir, "ip")
	ip_ui_dir = os.path.join(ip_dir, "ui")

	os.makedirs(ip_src_dir, exist_ok=True)
	os.makedirs(ip_xci_dir, exist_ok=True)
	os.makedirs(ip_ui_dir, exist_ok=True)

	sources = []
	cores = []

	for f in os.listdir(p_dir):
		ext = f.split(".")[-1]

		if ext in ["sv", "v"]:
			sync_files( os.path.join(p_dir, f), os.path.join(ip_src_dir, f), False )
		elif ext == "xci":
			dst_dir = os.path.join(ip_xci_dir, f[:-4])
			os.makedirs(dst_dir, exist_ok=True)
			sync_files( os.path.join(p_dir, f), os.path.join(dst_dir, f) )

	for d in p_meta.get("imports", []):
		if d not in g_modules:
			print("\t[E] Peripheral", p, "requires dependency", d, "but it wasn't found.")
			exit(1)

		for df in g_modules[d]:
			sync_files( df, os.path.join(ip_src_dir, os.path.basename(df)), False )

	ip_gui_file = os.path.join(ip_ui_dir, p + "_v" + p_meta.get("version", "1_0").replace(".", "_") + ".tcl")
	p_gui_file = os.path.join(p_dir, "xgui.tcl")

	sync_files(ip_gui_file, p_gui_file)

	ip_xml_file = os.path.join(ip_dir, "component.xml")
	p_xml_file = os.path.join(p_dir, "component.xml")

	if sync_files(ip_xml_file, p_xml_file) == 1:
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

	print("\t- Done\n")
