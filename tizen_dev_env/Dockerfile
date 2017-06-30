FROM ubuntu:16.04
MAINTAINER Sung-Jin Park <input.hacker@gmail.com>

ARG USER_NAME
ARG USER_ID
ARG USER_SHELL
ARG USER_HOME
ARG GIT_USER_NAME
ARG GIT_EMAIL
ARG TIZEN_SSH_USER_ID
ARG TIZEN_SSH_EMAIL

ENV USER_NAME ${USER_NAME}
ENV USER_ID ${USER_ID}
ENV USER_SHELL ${USER_SHELL}
ENV GIT_USER_NAME ${GIT_USER_NAME}
ENV GIT_EMAIL ${GIT_EMAIL}
ENV TIZEN_SSH_USER_ID ${TIZEN_SSH_USER_ID}
ENV TIZEN_SSH_EMAIL ${TIZEN_SSH_EMAIL}
ENV USER_HOME ${USER_HOME}

RUN echo "git_user_name=${GIT_USER_NAME}"
RUN echo "git_email=${GIT_EMAIL}"
RUN echo "tizen_ssh_user_id=${TIZEN_SSH_USER_ID}"
RUN echo "tizen_ssh_email=${TIZEN_SSH_EMAIL}"
RUN echo "user home dir=${USER_HOME}"

RUN useradd -m -s ${USER_SHELL} ${USER_NAME} -u ${USER_ID} -G sudo
RUN echo "${USER_NAME}:${USER_NAME}" | chpasswd
RUN echo "user=${USER_NAME}, uid=${USER_ID}, shell=${USER_SHELL}"

RUN mkdir -p /workspace/scripts
RUN mkdir -p /workspace/gbs_config
RUN mkdir -p /workspace/gits/tizen.org
COPY ./gbs.conf.* /workspace/gbs_config/
COPY Svace_Tizen_Build_Latest.sh /workspace/infra/svace/Svace_Tizen_Build_Latest.sh
RUN chmod +x /workspace/infra/svace/Svace_Tizen_Build_Latest.sh
RUN chown -R ${USER_NAME}.${USER_NAME} /workspace

# COPY or Create ssh key inside docker image
#RUN mkdir -p /home/${USER}/.ssh
#RUN ssh-keygen -trsa -C ${TIZEN_SSH_EMAIL} -f /home/${USER}/.ssh/id_rsa -P ""

#Needed to fix
RUN mkdir -p /home/${USER_NAME}/.ssh
#WORKDIR $HOME
ADD .ssh/id_rsa* /home/${USER_NAME}/.ssh/
RUN chown -R ${USER_NAME}.${USER_NAME} /home/${USER_NAME}/.ssh

# Set http/https proxy information
#ENV http_proxy="http://10.112.1.184:8080/"
#ENV https_proxy="https://10.112.1.184:8080/"
#ENV no_proxy '127.0.0.1, localhost, 10.113.63.32, 165.213.149.170, 10.113.138.35, 10.252.249.230, 165.213.149.200'
ENV HTTP_PROXY $http_proxy
ENV HTTPS_PROXY $https_proxy
ENV NO_PROXY $no_proxy
ENV http_proxy $http_proxy
ENV https_proxy $https_proxy
ENV no_proxy $no_proxy
RUN echo "export http_proxy=$http_proxy" >> /etc/profile
RUN echo "export https_proxy=$https_proxy" >> /etc/profile
RUN echo "export no_proxy='$no_proxy'" >> /etc/profile
RUN echo "export http_proxy=$http_proxy" >> /root/.bashrc
RUN echo "export https_proxy=$https_proxy" >> /root/.bashrc
RUN echo "export no_proxy='$no_proxy'" >> /root/.bashrc
RUN echo "export http_proxy=$http_proxy" >> /home/${USER_NAME}/.bashrc
RUN echo "export https_proxy=$https_proxy" >> /home/${USER_NAME}/.bashrc
RUN echo "export no_proxy='$no_proxy'" >> /home/${USER_NAME}/.bashrc

# date setting
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# Java
COPY jdk-8u131-linux-x64.tar.gz /usr/lib/jvm/jdk-8u131-linux-x64.tar.gz
RUN tar -zxf /usr/lib/jvm/jdk-8u131-linux-x64.tar.gz -C /usr/lib/jvm/
RUN echo "JAVA_HOME=/usr/lib/jvm/jdk1.8.0_131/" >> /etc/environment
RUN echo "CLASSPATH=JAVA_HOME=/usr/lib/jvm/jdk1.8.0_131/lib" >> /etc/environment
RUN echo "PATH=$PATH:/usr/lib/jvm/jdk1.8.0_131/bin" >> /etc/environment
RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_131/bin/java" 1
RUN update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/jdk1.8.0_131/bin/javac" 1
RUN update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/lib/jvm/jdk1.8.0_131/bin/javaws" 1
RUN /bin/bash -c 'source /etc/environment'
RUN update-alternatives --set java /usr/lib/jvm/jdk1.8.0_131/bin/java
RUN update-alternatives --set javac /usr/lib/jvm/jdk1.8.0_131/bin/javac
RUN update-alternatives --set javaws /usr/lib/jvm/jdk1.8.0_131/bin/javaws

CMD java -XX:+PrintFlagsFinal -XX:+PrintGCDetails $JAVA_OPTIONS -jar java-container.jar

# Add tizen development tools repo into apt information
RUN echo "deb http://download.tizen.org/tools/latest-release/Ubuntu_16.04/ /" >> /etc/apt/sources.list
RUN apt-get update

# Install basic package
RUN apt-get -qq -y install git vim build-essential software-properties-common tree unzip
RUN apt-get -qq -y --allow-unauthenticated install gbs sdb cpio git git-core sshpass wget

#RUN mkdir -p /etc/resolvconf/resolv.conf.d/
#RUN echo "nameserver 10.32.192.11" >> /etc/resolvconf/resolv.conf.d/base

RUN git config --global user.name ${GIT_USER_NAME}
RUN git config --global user.email ${GIT_EMAIL}
RUN echo "git user nam=${GIT_USER_NAME}, git email=${GIT_EMAIL}"

RUN echo "scp -p -P 29418 ${TIZEN_SSH_USER_ID}@review.tizen.org:hooks/commit-msg .git/hooks" >> /workspace/scripts/gerrit_hook_install.sh
RUN chmod +x /workspace/scripts/gerrit_hook_install.sh
RUN chown -R ${USER_NAME}.${USER_NAME} /workspace

# Add a user into sudoers
RUN echo "Defaults        env_keep += \"http_proxy https_proxy ftp_proxy no_proxy\"" >> /etc/sudoers
RUN echo "${USER_NAME} ALL=NOPASSWD: ALL" >> /etc/sudoers

# Update nameserver information
RUN echo "echo 'nameserver 10.32.192.11' > /etc/resolv.conf" > /usr/bin/add_ns.sh
RUN chmod +x /usr/bin/add_ns.sh
RUN /usr/bin/add_ns.sh
RUN echo "sudo /usr/bin/add_ns.sh" >> /home/${USER_NAME}/.bashrc
RUN echo "/usr/bin/add_ns.sh" >> /root/.bashrc

USER ${USER_NAME}
WORKDIR ~
CMD ["/bin/bash"]
