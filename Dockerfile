FROM ubuntu:16.04

ENV TERM=linux

#Update the systeam and install packages we need for Yocto
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y \
  build-essential chrpath curl diffstat     \
  gcc-multilib gawk git-core libsdl1.2-dev  \
  texinfo unzip wget python3 cpio nano tree \
  bzip2 dosfstools mtools parted syslinux

# Install Google's "repo" tool
RUN curl http://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo
RUN chmod +x /usr/local/bin/repo

# Create a non-root user. TODO: Automate in better way
RUN id worker 2>/dev/null || useradd --uid 1000 --create-home worker
RUN echo "worker ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
# TODO: Check why it's not working properly ....
RUN apt -y install locales   && \
  dpkg-reconfigure locales && \
  locale-gen en_US.UTF-8   && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

USER worker
WORKDIR /home/worker
CMD "/bin/bash"

# EOF


