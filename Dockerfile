FROM registry.hub.docker.com/library/debian:buster

# Container build arguments
ARG user_name=bas
ENV CONTAINER_USER_NAME=$user_name

ARG user_id=1000
ENV CONTAINER_USER_ID=$user_id

ARG user_home=/home/$user_name
ENV CONTAINER_USER_HOME=$user_home

# Install build tools and plugin dependencies
RUN echo "deb http://deb.debian.org/debian buster-backports main" > /etc/apt/sources.list.d/backports.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
        cmake/buster-backports \
        curl \
        git \
        libncurses-dev \
        libncurses6 \
        python3 \
        python3-dev \
	sudo && \
   echo '%sudo	ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/root

# Install Vim
ENV VIM_TAG v8.2.2879
ENV VIM_VERSION 82
WORKDIR /root
RUN git clone https://github.com/vim/vim.git                   && \
    cd vim/src                                                 && \
    git checkout -b "release/${VIM_VERSION}" "tags/${VIM_TAG}" && \
    ./configure --enable-python3interp                         && \
    make install                                               && \
    ln -s /usr/local/bin/vim /usr/local/bin/vi
ENV EDITOR=vim

# Install Golang
ENV GOLANG_VERSION 1.16.4
ENV GOLANG_SHA 7154e88f5a8047aad4b80ebace58a059e36e7e2e4eb3b383127a28c711b4ff59
RUN curl -L https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz -o go.tar.gz && \
  echo "${GOLANG_SHA}  go.tar.gz" | sha256sum -c && \
  tar -C /usr/local -xzf go.tar.gz && \
  rm go.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install vim-go plugin (Go)
ENV VIM_GO_VERSION v1.25
RUN git clone https://github.com/fatih/vim-go.git                           \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go             && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go              && \
    git checkout -b "release/${VIM_GO_VERSION}" "tags/${VIM_GO_VERSION}" && \
    vim -esN +GoInstallBinaries +q

# Install YouCompleteMe plugin (Autocomplete)
ENV VIM_YCM_VERSION ab73ca25467625ea71f1ee9103fca55cc10ba27a
RUN git clone https://github.com/Valloric/YouCompleteMe.git              \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe   && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe    && \
    git checkout -b build "$VIM_YCM_VERSION"                          && \
    git submodule sync                                                && \
    git submodule update --init --recursive                           && \
    python3 ./install.py --go-completer

# Install vim-fugitive (Git)
ENV VIM_FUGITIVE_VERSION v3.3
RUN git clone https://github.com/tpope/vim-fugitive.git                                 \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive                   && \
    cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive                    && \
    git checkout -b "release/${VIM_FUGITIVE_VERSION}" "tags/${VIM_FUGITIVE_VERSION}"

# Install jellybeans (colorscheme)
RUN curl -o /usr/local/share/vim/vim${VIM_VERSION}/colors/jellybeans.vim \
        https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim

# Vimrc
COPY vimrc /usr/local/share/vim/vimrc

# Generate Vim help pages
RUN vim -esN +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go/doc        \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe/doc \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive/doc  \
             +q

# Create a local user matching the system user for toolbox style integration
RUN /usr/sbin/useradd -u "$CONTAINER_USER_ID"                       \
                      -U -Gsudo -d "$CONTAINER_USER_HOME"           \
                      -s /bin/bash "$CONTAINER_USER_NAME"        && \
    chown -R "${CONTAINER_USER_ID}:${CONTAINER_USER_ID}" /go
USER $CONTAINER_USER_NAME
