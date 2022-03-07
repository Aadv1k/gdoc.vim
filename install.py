#!/usr/bin/env python3

import sys
from os import path
import subprocess

version = sys.version_info[ 0 : 3 ]
if version < ( 3, 6, 0 ):
  sys.exit('[ERROR] Gdoc requires Python >= 3.6.0 to run') 

req_path = path.normpath(path.join(path.realpath(__file__), '../', 'requirements.txt'))

if not path.exists(req_path):
  sys.exit("[ERROR] Couldn't find a requirements.txt file, running git pull might resolve the issue") 
else: 
   sub = subprocess.run(f'pip install -r {req_path}'.split())
   exit(0)

