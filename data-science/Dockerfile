FROM kentwait/rpygo-notebook:latest

# rpygo-notebook metadata
LABEL version="1.0"
LABEL maintainer="Kent Kawashima <kentkawashima@gmail.com>"

ENV NOTEBOOK_DIR=/notebooks \
    PYTHON_LIB_PATH=/root/python \
    R_LIB_PATH=/root/r \
    GOLANG_LIB_PATH=/root/go/custom

USER root

# Install Python packages
RUN conda update --yes -n base conda && \
    conda install --yes \
        numpy \
        scipy \
        matplotlib \
        seaborn \
        bokeh \
        pandas \
        numba \
        cython \
        statsmodels \
        scikit-learn \
        networkx && \
    rm -rf /tmp/* \
        /opt/conda/pkgs/* \
        /root/.wget-hsts \
        /root/.[acpw]*

EXPOSE 8888
VOLUME ${PYTHON_LIB_PATH} \
    ${R_LIB_PATH} \
    ${GOLANG_LIB_PATH} \
    ${NOTEBOOK_DIR}

WORKDIR ${NOTEBOOK_DIR}

ENTRYPOINT ["/sbin/my_init", "--"]
CMD ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--config=/root/.jupyter/jupyter_notebook_config.py"]