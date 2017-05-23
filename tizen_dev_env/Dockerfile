FROM ubuntu:16.04
MAINTAINER Sung-Jin Park <input.hacker@gmail.com>

ARG USER
ARG UID
ARG SHELL
ARG GIT_USER_NAME
ARG GIT_EMAIL
ARG TIZEN_SSH_USER_ID
ARG TIZEN_SSH_EMAIL

ENV USER $USER
ENV UID $UID
ENV SHELL $SHELL
ENV GIT_USER_NAME ${GIT_USER_NAME}
ENV GIT_EMAIL ${GIT_EMAIL}
ENV TIZEN_SSH_USER_ID ${TIZEN_SSH_USER_ID}
ENV TIZEN_SSH_EMAIL ${TIZEN_SSH_EMAIL}

RUN useradd -m -s $SHELL $USER -u $UID -G sudo
RUN echo "user=$USER, uid=$UID, shell=$SHELL"

# Set http/https proxy information
#ENV http_proxy="http://10.112.1.184:8080/"
#ENV https_proxy="https://10.112.1.184:8080/"
ENV HTTP_PROXY $http_proxy
ENV HTTPS_PROXY $https_proxy
RUN echo "export http_proxy=$http_proxy" >> /etc/profile
RUN echo "export https_proxy=$https_proxy" >> /etc/profile

# Add tizen development tools repo into apt information
RUN echo "deb http://download.tizen.org/tools/latest-release/Ubuntu_16.04/ /" >> /etc/apt/sources.list
RUN apt-get update

# Install basic package
RUN apt-get -qq -y install git vim build-essential
RUN apt-get -qq -y --allow-unauthenticated install gbs sdb

RUN mkdir -p /workspace/scripts
RUN mkdir -p /workspace/gbs_config
RUN mkdir -p /workspace/gits/tizen.org
COPY ./gbs.conf.* /workspace/gbs_config/

RUN echo "scp -p -P 29418 ${TIZEN_SSH_USER_ID}@review.tizen.org:hooks/commit-msg .git/hooks" >> /workspace/gits/gerrit_hook_install.sh
RUN chmod +x /workspace/gits/gerrit_hook_install.sh

RUN chown -R ${USER}.${USER} /workspace

RUN git config --global user.name ${GIT_USER_NAME}
RUN git config --global user.email ${GIT_EMAIL}
RUN echo "git user nam=${GIT_USER_NAME}, git email=${GIT_EMAIL}"

RUN echo "nameserver 10.32.192.11" > /etc/resolv.conf

# COPY or Create ssh key inside docker image
RUN ssh-keygen -trsa -C ${TIZEN_SSH_EMAIL} -f /home/${USER}/.ssh/id_rsa -P ""

#Needed to fix
#COPY /home/$USER/.ssh/id_rsa* /home/$USER/.ssh/

CMD ["/bin/bash"]
