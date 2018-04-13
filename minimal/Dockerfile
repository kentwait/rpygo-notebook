# kentwait/rpygo-notebook
FROM kentwait/docker-openmpi:latest

# rpygo-notebook metadata
LABEL version="2.0"
LABEL maintainer="Kent Kawashima <kentkawashima@gmail.com>"

# Conda variables
ENV CONDA_PYTHON_VERSION=3 \
    CONDA_DIR=/opt/conda \
    CONDA_VERSION="latest" \
    CONDA_ARCH="Linux-x86_64" \
# Golang variables
    GOLANG_VERSION=1.10.1 \
    GOLANG_ARCH="linux-amd64" \
# Additional paths
    NOTEBOOK_DIR=/notebooks \
    PYTHON_LIB_PATH=/root/python \
    R_LIB_PATH=/root/r \
    GOLANG_LIB_PATH=/root/go/custom \
    GOLANG_INTERNAL_LIB_PATH=/root/go/internal \
    GOROOT=/usr/local/go
    
# Paths
ENV PYTHONPATH=${PYTHON_LIB_PATH} \
    GOPATH=${GOLANG_INTERNAL_LIB_PATH}:${GOLANG_LIB_PATH} \
# ENV R_LIBS_SITE=${R_LIB_PATH}
    PATH=${PYTHON_LIB_PATH}:${R_LIB_PATH}:${CONDA_DIR}/bin:${PATH}:${GOROOT}/bin:${GOLANG_INTERNAL_LIB_PATH}/bin:${GOLANG_LIB_PATH}/bin

USER root

WORKDIR /tmp
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
    apt-get update --quiet --fix-missing && \
    apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        wget \
        r-base \
        r-base-dev \
        libcurl4-openssl-dev \
        libssl-dev \        
        curl \
        libzmq3-dev && \
    # Install Miniconda
    wget -q "https://repo.continuum.io/miniconda/Miniconda${CONDA_PYTHON_VERSION}-${CONDA_VERSION}-${CONDA_ARCH}.sh" -O /tmp/installer.sh && \
    bash installer.sh -b -p ${CONDA_DIR} && \
    mkdir -p ${PYTHON_LIB_PATH} && \   
    mkdir -p ${R_LIB_PATH} && \   
    mkdir -p ${GOLANG_LIB_PATH} && \
    # Install Go
    curl -O "https://dl.google.com/go/go${GOLANG_VERSION}.${GOLANG_ARCH}.tar.gz" && \
    tar xvf go${GOLANG_VERSION}.${GOLANG_ARCH}.tar.gz && \
    chown -R root:root ./go && \
    mv go /usr/local && \
    mkdir -p ${GOLANG_LIB_PATH}/src && \
    mkdir -p ${GOLANG_LIB_PATH}/bin && \
    mkdir -p ${GOLANG_INTERNAL_LIB_PATH}/src && \
    mkdir -p ${GOLANG_INTERNAL_LIB_PATH}/bin && \
    # Install Jupyter
    conda update --yes -n base conda && \
    conda install --yes \
        ipython \
        jupyter && \
    mkdir -p ${NOTEBOOK_DIR} && \
    # Set token as empty string - also disables authenticating token for XSRF protection
    jupyter notebook --generate-config && \
    echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password_required = False" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_root = True" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py && \ 
    # Install IRKernel and gophernotes
    R -e "install.packages(c('crayon', 'pbdZMQ', 'devtools'))" && \
    R -e "devtools::install_github(paste0('IRkernel/', c('repr', 'IRdisplay', 'IRkernel')))" && \
    R -e "IRkernel::installspec(user = FALSE)" && \
    go get -u github.com/gopherdata/gophernotes && \
    mkdir -p /root/.local/share/jupyter/kernels/gophernotes && \
    cp ${GOLANG_INTERNAL_LIB_PATH}/src/github.com/gopherdata/gophernotes/kernel/* /root/.local/share/jupyter/kernels/gophernotes && \
    # remove packages and clean up 
    apt-get clean && \
 	rm -rf /var/lib/apt/lists/* && \
    find /opt -name __pycache__ | xargs rm -r && \
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