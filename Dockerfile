# kentwait/rpygo-notebook
FROM kentwait/docker-openmpi:latest

# rpygo-notebook metadata
LABEL version="0.1"
LABEL maintainer="Kent Kawashima <kentkawashima@gmail.com>"

# Conda variables
ENV CONDA_PYTHON_VERSION=3
ENV CONDA_DIR=/opt/conda
ENV CONDA_VERSION=latest
ENV CONDA_ARCH=Linux-x86_64

# Golang variables
ENV GOLANG_VERSION=1.10.1
ENV GOLANG_ARCH=linux-amd64

# Additional paths
ENV NOTEBOOK_DIR=/notebooks
ENV CUSTOM_LIB_DIR=/root
ENV PYTHON_LIB_PATH=${CUSTOM_LIB_DIR}/python
ENV R_LIB_PATH=${CUSTOM_LIB_DIR}/r
ENV GOLANG_LIB_PATH=${CUSTOM_LIB_DIR}/go/custom
ENV GOLANG_INTERNAL_LIB_PATH=${CUSTOM_LIB_DIR}/go/internal

# Language-specific paths
ENV PYTHONPATH=${PYTHON_LIB_PATH}
ENV GOROOT=/usr/local/go
ENV GOPATH=${GOLANG_INTERNAL_LIB_PATH}:${GOLANG_LIB_PATH}
# ENV R_LIBS_SITE=${R_LIB_PATH}

# Path
ENV PATH=${PYTHON_LIB_PATH}:${R_LIB_PATH}:${CONDA_DIR}/bin:${PATH}:${GOROOT}/bin:${GOLANG_INTERNAL_LIB_PATH}/bin:${GOLANG_LIB_PATH}/bin

USER root

WORKDIR /tmp
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/' && \
    apt-get update --quiet --fix-missing && \
    apt-get install -y \
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
    mkdir -p ${CUSTOM_LIB_DIR} && \   
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
    mkdir -p ${GOLANG_INTERNAL_LIB_PATH}/bin

# Install Jupyter
RUN conda update --yes -n base conda && \
    conda install --yes \
        ipython \
        jupyter && \
    conda clean --all --yes && \
    mkdir -p ${NOTEBOOK_DIR} 

# Set token as empty string - also disables authenticating token for XSRF protection
RUN jupyter notebook --generate-config && \
    echo "c.NotebookApp.token = ''" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.password_required = False" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.allow_root = True" >> /root/.jupyter/jupyter_notebook_config.py && \
    echo "c.NotebookApp.open_browser = False" >> /root/.jupyter/jupyter_notebook_config.py    

# Install IRKernel and gophernotes
WORKDIR /tmp
RUN R -e "install.packages(c('crayon', 'pbdZMQ', 'devtools'))" && \
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
VOLUME ${PYTHON_LIB_PATH}
VOLUME ${R_LIB_PATH}
VOLUME ${GOLANG_LIB_PATH}
VOLUME ${NOTEBOOK_DIR}

WORKDIR ${NOTEBOOK_DIR}

ENTRYPOINT ["/sbin/my_init", "--"]
CMD ["jupyter", "notebook", "--port=8888", "--ip=0.0.0.0", "--config=/root/.jupyter/jupyter_notebook_config.py"]