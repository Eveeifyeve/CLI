import os
from pathlib import Path
import shutil
import subprocess
import platform

# Get the directory containing compile.py
current_dir = Path(__file__).resolve().parent

# Construct the path to eve.py
eve_py_path = current_dir / 'src' / 'eve.py'

# Dist
dist_dir = current_dir / "dist"
dist_dir.mkdir(parents=True, exist_ok=True)

# Remove existing compiled files and scripts
os.remove(current_dir / "../dist/eve.py") if os.path.exists(current_dir / "../dist/eve.py") else None
os.remove(current_dir / "../dist/eve") if os.path.exists(current_dir / "../dist/eve") else None
os.remove(current_dir / "../dist/eve.exe") if os.path.exists(current_dir / "../dist/eve.exe") else None
os.mkdir(current_dir / "build") if os.path.exists(current_dir / "build") else None

# Check if the current operating system is Windows
if platform.system() == 'Windows':
    subprocess.run(["pyinstaller", "--noconfirm", "--onefile", "--console", "--strip", "./build", str(eve_py_path)], check=True)
else:
    print("PyInstaller is only supported on Windows.")


# Generate .sh script
with open(current_dir / "dist/eve", 'w') as f:
    f.write('#!/bin/bash\n')
    f.write('\n# Generated By Eveeifyeve/CLI\n')
    f.write('python3 ~/.cli/eve.py "$@"\n')

shutil.copy(eve_py_path, current_dir / "dist/eve.py")


# Generate test sh script
with open(current_dir / "dist/test.sh", 'w') as f:
    f.write('#!/bin/bash\n')
    f.write('\n# Define the target directory\n')
    f.write('TARGET_DIR="/usr/local/bin/"\n')
    f.write('\n# Remove existing eve.pyc and eve from the target directory if they exist\n')
    f.write('rm -f "${TARGET_DIR}eve.pyc"\n')
    f.write('rm -f "${TARGET_DIR}eve"\n')
    f.write('\n# Move files to the target directory\n')
    f.write('cp eve.pyc "$TARGET_DIR"\n')
    f.write('cp eve "$TARGET_DIR"\n')
    f.write('\n# Change permissions of files if necessary\n')
    f.write('chmod +x "${TARGET_DIR}eve.pyc"\n')
    f.write('chmod +x "${TARGET_DIR}eve"\n')
    
    shutil.rmtree("build", ignore_errors=True)
    os.remove("eve.spec") if os.path.exists("eve.spec") else None