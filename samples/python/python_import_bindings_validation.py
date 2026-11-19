"""Tracker_HUD Python import-binding validation sample.

Expected parser-backed binding behavior:
- plain imports bind the imported top-level module name;
- aliased imports bind the alias rather than the source module name;
- comma-separated imports expose every binding;
- from-imports expose imported names rather than the source module;
- aliased from-imports expose the alias.
"""

import math
import json as jsonlib
import os, sys
import xml.etree
from pathlib import Path
from collections import deque as Queue, Counter
