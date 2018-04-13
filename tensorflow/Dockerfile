FROM kentwait/rpygo-datascience-notebook:latest

# rpygo-notebook metadata
LABEL version="1.0"
LABEL maintainer="Kent Kawashima <kentkawashima@gmail.com>"

ENV NOTEBOOK_DIR=/notebooks \
    CUSTOM_LIB_DIR=/root \
    TF_BINARY=tensorflow \
    TF_TYPE=cpu \
    TF_VERSION=1.7.0 \
    TF_ARCH=linux_x86_64
ENV PYTHON_LIB_PATH=${CUSTOM_LIB_DIR}/python \
    R_LIB_PATH=${CUSTOM_LIB_DIR}/r \
    GOLANG_LIB_PATH=${CUSTOM_LIB_DIR}/go/custom \
    GOLANG_INTERNAL_LIB_PATH=${CUSTOM_LIB_DIR}/go/internal \
    TF_PYTHON_BINARY_URL="https://storage.googleapis.com/tensorflow/linux/cpu/${TF_BINARY}-${TF_VERSION}-cp36-cp36m-${TF_ARCH}.whl"
USER root

WORKDIR /tmp
RUN pip install --ignore-installed --upgrade ${TF_PYTHON_BINARY_URL} && \
    curl -L "https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-${TF_TYPE}-$(go env GOOS)-x86_64-${TF_VERSION}.tar.gz" | \
    tar -C /usr/local -xz && \
    ldconfig && \
    conda update --yes -n base conda && \
    conda install --yes \
        scikit-image \
        pillow && \
    conda install --yes -c conda-forge \
        opencv \
        dlib
RUN go get github.com/tensorflow/tensorflow/tensorflow/go && \
    go test github.com/tensorflow/tensorflow/tensorflow/go && \
    conda clean --all --yes && \
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