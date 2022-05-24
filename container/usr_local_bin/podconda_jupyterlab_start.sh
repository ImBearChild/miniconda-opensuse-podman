#!/bin/bash
. /opt/conda/etc/profile.d/conda.sh
cd
conda activate base
export LANG=C.UTF-8 LC_ALL=C.UTF-8
export SHELL=/bin/bash
jupyter lab \
    --notebook-dir=$HOME --ip='*' --port=8888 \
    --no-browser