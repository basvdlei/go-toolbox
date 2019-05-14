FROM registry.hub.docker.com/library/debian:buster

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        cmake \
        curl \
        git \
        libncurses-dev \
        libncurses6 \
        python3 \
        python3-dev

WORKDIR /root
RUN git clone https://github.com/vim/vim.git && \
    cd vim/src                               && \
    ./configure --enable-python3interp       && \
    make install

ENV GOLANG_VERSION 1.12.5
RUN curl -L https://golang.org/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz | \
        tar -C /usr/local -xzf -
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

ENV VIM_GO_VERSION v1.20
RUN git clone https://github.com/fatih/vim-go.git                           \
        /usr/local/share/vim/vim81/pack/plugins/start/vim-go             && \
    cd /usr/local/share/vim/vim81/pack/plugins/start/vim-go              && \
    git checkout -b "release/${VIM_GO_VERSION}" "tags/${VIM_GO_VERSION}" && \
    vim -esN +GoInstallBinaries +q

RUN git clone https://github.com/Valloric/YouCompleteMe.git              \
        /usr/local/share/vim/vim81/pack/plugins/start/YouCompleteMe   && \
    cd /usr/local/share/vim/vim81/pack/plugins/start/YouCompleteMe    && \
    git config --file=.gitmodules submodule."third_party/ycmd".url       \
                                  https://github.com/bstaletic/ycmd   && \
    git config --file=.gitmodules submodule."third_party/ycmd".branch    \
                                  gopls                               && \
    git submodule sync                                                && \
    git submodule update --init --recursive                           && \
    ( cd third_party/ycmd && git checkout gopls && git submodule update --init --recursive )  && \
    python3 ./install.py --go-completer

RUN git clone https://github.com/tpope/vim-fugitive.git \
        /usr/local/share/vim/vim81/pack/plugins/start/vim-fugitive

RUN curl -o /usr/local/share/vim/vim81/colors/jellybeans.vim \
        https://raw.githubusercontent.com/nanotech/jellybeans.vim/master/colors/jellybeans.vim

COPY vimrc /usr/local/share/vim/vimrc

RUN vim -esN +helptags\ /usr/local/share/vim/vim81/pack/plugins/start/vim-go/doc        \
             +helptags\ /usr/local/share/vim/vim81/pack/plugins/start/YouCompleteMe/doc \
             +helptags\ /usr/local/share/vim/vim81/pack/plugins/start/vim-fugitive/doc  \
             +q

RUN /usr/sbin/useradd -u 1000 -U -d /home/bas -s /bin/bash bas && \
	chown -R bas:bas /go
USER bas

ENV TERM xterm-256color
