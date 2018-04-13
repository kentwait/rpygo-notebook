FROM kentwait/rpygo-notebook:latest

# rpygo-notebook metadata
LABEL version="1.0"
LABEL maintainer="Kent Kawashima <kentkawashima@gmail.com>"

ENV NOTEBOOK_DIR=/notebooks \
    CUSTOM_LIB_DIR=/root
ENV PYTHON_LIB_PATH=${CUSTOM_LIB_DIR}/python \
    R_LIB_PATH=${CUSTOM_LIB_DIR}/r \
    GOLANG_LIB_PATH=${CUSTOM_LIB_DIR}/go/custom \
    GOLANG_INTERNAL_LIB_PATH=${CUSTOM_LIB_DIR}/go/internal

USER root

# Install Python packages
RUN conda update --yes -n base conda && \
    conda install --yes \
        numpy \
        scipy \
        matplotlib \
        seaborn \
        pandas \
        numba \
        statsmodels \
        scikit-learn
    
RUN conda clean --all --yes && \
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