FROM registry.hub.docker.com/library/debian:bookworm

# Container build arguments
ARG user_name=bas
ENV CONTAINER_USER_NAME=$user_name

ARG user_id=1000
ENV CONTAINER_USER_ID=$user_id

ARG user_home=/home/$user_name
ENV CONTAINER_USER_HOME=$user_home

# Install build tools and plugin dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        bash-completion \
        build-essential \
        cmake \
        curl \
        git \
        jq \
        libncurses-dev \
        libncurses6 \
        python3 \
        python3-dev \
        sudo && \
   echo '%sudo	ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/root

# Install Vim
ENV VIM_TAG v9.1.1379
ENV VIM_VERSION 91
WORKDIR /root
RUN git clone https://github.com/vim/vim.git                   && \
    cd vim/src                                                 && \
    git checkout -b "release/${VIM_VERSION}" "tags/${VIM_TAG}" && \
    ./configure --enable-python3interp                         && \
    make install                                               && \
    ln -s /usr/local/bin/vim /usr/local/bin/vi
ENV EDITOR=vim

# Install Go
ENV GOLANG_VERSION 1.24.3
ENV GOLANG_SHA 3333f6ea53afa971e9078895eaa4ac7204a8c6b5c68c10e6bc9a33e8e391bdd8
RUN curl -L https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
  echo "${GOLANG_SHA}  go.tar.gz" | sha256sum -c && \
  tar -C /usr/local -xzf go.tar.gz && \
  rm go.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install vim-go plugin (Go)
# Version fom 2025-04-20
ENV VIM_GO_VERSION 59e208d5212b86c8afd69d8590f181594f859ddb
RUN git clone https://github.com/fatih/vim-go.git                           \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go             && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go              && \
    git checkout -b build "${VIM_GO_VERSION}" && \
    vim -esN +GoInstallBinaries +q

# Install vim-fugitive (Git)
# Version from 2025-02-19
ENV VIM_FUGITIVE_VERSION 4a745ea72fa93bb15dd077109afbb3d1809383f2
RUN git clone https://github.com/tpope/vim-fugitive.git                                 \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive                   && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive                    && \
    git checkout -b build "${VIM_FUGITIVE_VERSION}"

# Install vim-terraform (Terraform)
ENV VIM_TERRAFORM_VERSION 8912ca1be3025a1c9fab193618f3b99517e01973
RUN git clone https://github.com/hashivim/vim-terraform.git                        \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-terraform && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-terraform  && \
    git checkout -b build "$VIM_TERRAFORM_VERSION"

# Install jellybeans (colorscheme)
RUN curl -o /usr/local/share/vim/vim${VIM_VERSION}/colors/jellybeans.vim \
        https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim

# Create a local user matching the system user for toolbox style integration
RUN /usr/sbin/useradd -u "$CONTAINER_USER_ID"                       \
                      -U -Gsudo -d "$CONTAINER_USER_HOME" -m        \
                      -s /bin/bash "$CONTAINER_USER_NAME"        && \
    chown -R "${CONTAINER_USER_ID}:${CONTAINER_USER_ID}" /go /usr/local/share/vim
USER $CONTAINER_USER_NAME

# Install YouCompleteMe plugin (Autocomplete)
ENV VIM_YCM_VERSION 131b1827354871a4e984c1660b6af0fefca755c3
RUN git clone https://github.com/Valloric/YouCompleteMe.git              \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe   && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe    && \
    git checkout -b build "$VIM_YCM_VERSION"                          && \
    git submodule sync                                                && \
    git submodule update --init --remote --recursive                  && \
    python3 ./install.py --go-completer

# Vimrc
COPY vimrc /usr/local/share/vim/vimrc
COPY vim-shell.sh /etc/bashrc

# Generate Vim help pages
RUN vim -esN +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go/doc        \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe/doc \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive/doc  \
             +q

