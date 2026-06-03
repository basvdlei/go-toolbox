FROM registry.hub.docker.com/library/debian:trixie

# Container build arguments
ARG user_name=bas
ENV CONTAINER_USER_NAME=$user_name

ARG user_id=1000
ENV CONTAINER_USER_ID=$user_id

ARG user_home=/home/$user_name
ENV CONTAINER_USER_HOME=$user_home

# Install build tools and plugin dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
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
        sudo \
   && echo '%sudo	ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/root

# Install Vim
ENV VIM_TAG v9.2.0588
ENV VIM_VERSION 92
WORKDIR /root
RUN git clone https://github.com/vim/vim.git \
    && cd vim/src \
    && git checkout -b "release/${VIM_VERSION}" "tags/${VIM_TAG}" \
    && ./configure --enable-python3interp \
    && make install \
    && ln -s /usr/local/bin/vim /usr/local/bin/vi
ENV EDITOR=vim

# Install Go
ENV GOLANG_VERSION 1.26.3
ENV GOLANG_SHA 2b2cfc7148493da5e73981bffbf3353af381d5f93e789c82c79aff64962eb556
ENV GOLANG_URL https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz

RUN curl -L "${GOLANG_URL}" -o go.tar.gz \
    && echo "${GOLANG_SHA}  go.tar.gz" | sha256sum -c \
    && tar -C /usr/local -xzf go.tar.gz \
    && rm go.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

# Install vim-go plugin (Go)
# Version fom 2026-03-28
ENV VIM_GO_VERSION f4b4ba17035aebcd222df90375c1cbb1dc4d8c5b
RUN git clone https://github.com/fatih/vim-go.git \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go \
    && cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go \
    && git checkout -b build "${VIM_GO_VERSION}" \
    && vim -esN +GoInstallBinaries +q

# Install vim-fugitive (Git)
# Version from 2026-03-07
ENV VIM_FUGITIVE_VERSION 3b753cf8c6a4dcde6edee8827d464ba9b8c4a6f0
RUN git clone https://github.com/tpope/vim-fugitive.git \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive \
    && cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive \
    && git checkout -b build "${VIM_FUGITIVE_VERSION}"

# Install vim-terraform (Terraform)
# Version from 2025-05-24
ENV VIM_TERRAFORM_VERSION 520498fab16a3a11f2ae1b8cb65e0a1684bc317a
RUN git clone https://github.com/hashivim/vim-terraform.git \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-terraform \
    && cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-terraform \
    && git checkout -b build "$VIM_TERRAFORM_VERSION"

# Install jellybeans (colorscheme)
RUN curl -o /usr/local/share/vim/vim${VIM_VERSION}/colors/jellybeans.vim \
        https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim

# Create a local user matching the system user for toolbox style integration
RUN /usr/sbin/useradd -u "$CONTAINER_USER_ID" \
                      -U -Gsudo -d "$CONTAINER_USER_HOME" -m \
                      -s /bin/bash "$CONTAINER_USER_NAME" \
    && chown -R "${CONTAINER_USER_ID}:${CONTAINER_USER_ID}" /go /usr/local/share/vim
USER $CONTAINER_USER_NAME

# Install YouCompleteMe plugin (Autocomplete)
# Version from 2026-01-30
ENV VIM_YCM_VERSION 6a52780a22dfd4ddafbe23c0d2c2a2107ceeb397
RUN git clone https://github.com/Valloric/YouCompleteMe.git \
        /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe \
    && cd /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe \
    && git checkout -b build "$VIM_YCM_VERSION" \
    && git submodule sync \
    && git submodule update --init --remote --recursive \
    && python3 ./install.py --go-completer

# Vimrc
COPY vimrc /usr/local/share/vim/vimrc
COPY vim-shell.sh /etc/bashrc

# Generate Vim help pages
RUN vim -esN +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-go/doc \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/YouCompleteMe/doc \
             +helptags\ /usr/local/share/vim/vim${VIM_VERSION}/pack/plugins/start/vim-fugitive/doc \
             +q

