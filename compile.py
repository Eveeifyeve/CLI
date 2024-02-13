import os
import py_compile
from pathlib import Path

# Get the directory containing compile.py
current_dir = Path(__file__).resolve().parent

# Construct the path to eve.py
eve_py_path = current_dir / 'src' / 'eve.py'

# Remove existing compiled files and scripts
os.remove(current_dir / "../dist/eve.pyc") if os.path.exists(current_dir / "../dist/eve.pyc") else None
os.remove(current_dir / "../dist/eve.sh") if os.path.exists(current_dir / "../dist/eve.sh") else None
os.remove(current_dir / "../dist/eve.ps1") if os.path.exists(current_dir / "../dist/eve.ps1") else None

# Compile eve.py to ../dist/eve.pyc
py_compile.compile(str(eve_py_path), optimize=0, cfile=str(current_dir / "dist/eve.pyc"))


# Generate .sh script
with open(current_dir / "dist/eve.sh", 'w') as f:
    f.write('#!/bin/bash')
    f.write('\npython3 eve.pyc\n')

# Generate .ps1 script
with open(current_dir / "dist/eve.ps1", 'w') as f:
    f.write('# Run the compiled Python bytecode file\n')
    f.write('python ..\\eve.pyc\n')