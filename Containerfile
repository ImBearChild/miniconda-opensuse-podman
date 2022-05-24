FROM registry.opensuse.org/opensuse/leap:15.4
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN zypper --non-interactive up && \
    zypper --non-interactive in glibc-locale-base which sudo wget && \
    zypper --non-interactive cc --all
RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O /tmp/miniforge.sh && \
    bash /tmp/miniforge.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    rm /tmp/miniforge.sh && \
    /opt/conda/bin/conda install jupyterlab -y --quiet && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy  && \
    groupadd conda && \
    useradd -m --groups conda gecko && \
    echo "root:podconda-opensuse\ngecko:podconda-opensuse" | chpasswd && \
    chgrp -R conda /opt/conda && \
    chmod 770 -R /opt/conda
ADD container/usr_local_bin /usr/local/bin
ADD --chown=gecko:users container/home_gecko /home/gecko
USER gecko
ENTRYPOINT /usr/bin/bash /usr/local/bin/podconda_jupyterlab_start.sh
EXPOSE 8888/tcp
