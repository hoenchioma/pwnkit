FROM kalilinux/kali-rolling:latest

# Software tools
RUN dpkg --add-architecture i386
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update

# This is some magic to prevent interactive prompts during installation in 'keyboard-configuration'
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get install -y -q

# make sure apt doesn't delete cache
RUN rm -f /etc/apt/apt.conf.d/docker-clean

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y \
        binwalk \
        cmake \
        libcurl4-openssl-dev \
        libgmp3-dev \
        libmpc-dev \
        libssl-dev \
        locales \
        metasploit-framework

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y \
        amass \
        crackmapexec \
        dirb \
        dnsrecon \
        dnsutils \
        enum4linux \
        exploitdb \
        fcrackzip \
        ffuf \
        ftp-ssl \
        gdb \
        git \
        gobuster \
        iputils-ping \
        john \
        joomscan \
        libimage-exiftool-perl \
        ltrace \
        man \
        masscan \
        nano \
        ncat \
        nfs-common \
        nikto \
        nishang \
        nmap \
        pcregrep \
        php \
        php-mysql \
        python2 \
        python2-dev \
        python3-dev \
        python3-pip \
        pngcheck \
        screen \
        smbmap \
        sqlmap \
        sqsh \
        sslscan \
        stegcracker \
        steghide \
        strace \
        telnet \
        tree \
        vim \
        wfuzz \
        wine \
        wine32 \
        winexe \
        wordlists \
        xxd \
        zsh \
        ranger \
        xclip

RUN apt-get autoremove -y

# Set the locale
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
RUN locale-gen "en_US.UTF-8"
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Ruby tools
RUN gem install zsteg

# Python tools
COPY get-pip.py /tmp/get-pip.py
RUN python2 /tmp/get-pip.py
RUN rm /tmp/get-pip.py
RUN pip2 install --upgrade pip
RUN pip2 install --upgrade PyCrypto

RUN alias python=python3
RUN alias pip=pip3
RUN pip3 install --upgrade --break-system-packages pip

RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    pip3 install --upgrade --break-system-packages \
        angr \
        GMPY2 \
        keystone-engine \
        Pillow \
        pwntools \
        pycryptodome \
        requests \
        ropper \
        six \
        tqdm \
        uncompyle6 \
        unicorn \
        urllib3 \
        wfuzz \
        z3-solver \
        gdown

# Other tools
RUN git clone https://github.com/hugsy/gef.git .gef && \
    echo "source $(pwd)/.gef/gef.py" >> ~/.gdbinit

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
RUN git clone --depth 1 https://github.com/marlonrichert/zsh-autocomplete.git /root/.oh-my-zsh/custom/plugins/zsh-autocomplete

# Create work directories
RUN mkdir /workdir
RUN mkdir /tools
WORKDIR /tools

# Clone Github tools
RUN git clone https://github.com/Ganapati/RsaCtfTool.git
RUN git clone https://github.com/volatilityfoundation/volatility.git
RUN alias volatility="python2 /tools/volatility/vol.py"

# Cleanup and config
RUN chsh -s $(which zsh)
RUN cp /usr/share/wordlists/rockyou.txt.gz /tools && gunzip /tools/rockyou.txt.gz
COPY ./files/launch-in-session.sh /tools/launch-in-session.sh
COPY ./files/.zshrc /root/.zshrc

WORKDIR /workdir
CMD ["/bin/zsh"]
