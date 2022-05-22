. /opt/conda/etc/profile.d/conda.sh
conda activate base
export LANG=C.UTF-8 LC_ALL=C.UTF-8
jupyter lab \
    --notebook-dir=/home/gecko --ip='*' --port=8888 \
    --no-browser
