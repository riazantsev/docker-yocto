FROM ubuntu:16.04

ENV TERM=linux
ENV LC_ALL=en_US.utf-8
ENV DOCKER_USER_NAME=worker
ENV DOCKER_WORK_DIR=/home/${USER_NAME}/work
ENV DOCKER_BUILD_DIR=build
ENV DOCKER_UID=1000

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
RUN id ${DOCKER_USER_NAME} 2>/dev/null || useradd --uid ${DOCKER_UID} --create-home ${DOCKER_USER_NAME}
RUN echo "${DOCKER_USER_NAME} ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# Fix error "Please use a locale setting which supports utf-8."
# See https://wiki.yoctoproject.org/wiki/TipsAndTricks/ResolvingLocaleIssues
# TODO: Check why it's not working properly ....
RUN apt -y install locales   && \
  dpkg-reconfigure locales && \
  locale-gen en_US.UTF-8   && \
  update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

USER ${DOCKER_USER_NAME}
WORKDIR /home/${DOCKER_USER_NAME}

#Do initial git configuration in order to prevent repo fails
RUN git config --global user.name "John Doe" && \
    git config --global user.email "jd@umbrellacorp.com"

COPY ./docker_build_helper.sh /usr/bin/build_helper.sh

CMD "/bin/bash"

# EOF

