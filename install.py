#!/usr/bin/env python3

import sys
import os

version = sys.version_info[ 0 : 3 ]
if version < ( 3, 6, 0 ):
  sys.exit('[ERROR] Gdoc requires Python >= 3.6.0 to run') 

if not os.path.exists('./requirements.txt'):
  sys.exit("[ERROR] Couldn't find a requirements.txt file, running git pull \
          might resolve the issue") 

os.system('pip install -r requirements.txt')
