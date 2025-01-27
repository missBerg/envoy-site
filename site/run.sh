#!/bin/bash

set -e  # Exit on error

ls -lrt 
pwd

pelican --autoreload --listen --bind 0.0.0.0 -vv
