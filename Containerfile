FROM registry.opensuse.org/opensuse/leap:15.4
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
RUN zypper --non-interactive in glibc-locale-base busybox-static sudo && \
    zypper --non-interactive cc --all
RUN busybox-static wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda install jupyterlab -y --quiet && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy  && \
    echo "root:anaconda-opensuse" | chpasswd && \
    groupadd conda && \
    useradd -m --groups conda gecko && \
    chgrp -R conda /opt/conda && \
    chmod 770 -R /opt/conda
RUN touch /home/gecko/.bash_profile && \
    echo ". /opt/conda/etc/profile.d/conda.sh && cd" >> /home/gecko/.bash_profile && \
    mkdir /home/gecko/.jupyter/ && \
    touch /home/gecko/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.terminado_settings = { \"shell_command\": [\"/usr/bin/bash\"] }" && \
    chmod 755 /home/gecko/.bash_profile && \
    chown gecko:users /home/gecko/.bash_profile && \
    chown gecko:users -R /home/gecko/.jupyter && \
    chmod 755 -R /home/gecko/.jupyter
ADD --chown=gecko:users conda_jupyter_lab.sh /home/gecko/bin
ADD --chown=gecko:users README*.md /home/gecko
USER gecko
ENTRYPOINT /usr/bin/bash /home/gecko/bin/conda_jupyter_lab.sh
EXPOSE 8888/tcp
