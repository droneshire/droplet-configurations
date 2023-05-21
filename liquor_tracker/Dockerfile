FROM ubuntu:latest

# LABEL about the custom image
LABEL maintainer="ryeager12@gmail.com"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for Liquor Tracker Backend."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt-get update
RUN apt install -y tmux git wget openssh-client python3-pip python3-testresources python3-venv python3-gpg net-tools
RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

ARG KEYS_DIR_ARG=/keys
ARG CONFIG_DIR_ARG=/config

# Variables
ENV HOME_DIR /root
ENV KEYS_DIR ${KEYS_DIR_ARG}
ENV CONFIG_DIR ${CONFIG_DIR_ARG}
ENV EMAIL test@gmail.com
ENV TMP_GITHUB_KEY "/tmp/githubKey"
ENV SSH_DIR ${HOME_DIR}/.ssh
ENV GITHUB_REPO_FILE=${HOME_DIR}/.github_repo

VOLUME ${KEYS_DIR}
VOLUME ${CONFIG_DIR}

RUN mkdir -p ${SSH_DIR} && chmod 700 ${SSH_DIR}

RUN ssh-keyscan github.com >> $TMP_GITHUB_KEY
RUN ssh-keygen -lf $TMP_GITHUB_KEY
RUN echo $TMP_GITHUB_KEY >> ${SSH_DIR}/known_hosts

RUN python3 -m pip install --user virtualenv
RUN pip install wheel

ENV PATH="${PATH}:${HOME_DIR}/.local/bin:${HOME_DIR}"

COPY ./.github_repo ${GITHUB_REPO_FILE}
RUN chmod +r ${GITHUB_REPO_FILE}
COPY ./config ${SSH_DIR}/config
RUN chmod +r ${SSH_DIR}/config

COPY ./setup.sh ${HOME_DIR}/setup.sh
RUN chmod +x ${HOME_DIR}/setup.sh

COPY ./wait_for_input.sh wait_for_input.sh
RUN chmod +x wait_for_input.sh

CMD ["sh", "-c", "${HOME_DIR}/setup.sh ${KEYS_DIR} ${CONFIG_DIR}"]

# generate keys in /path/to/host/keys dir
# add configs to /path/to/host/config dir
# docker build  --build-arg KEYS_DIR_ARG="/keys" --build-arg CONFIG_DIR_ARG="/config" -t droplet .
# docker run  -d  -v /path/to/host/keys:/keys -v /path/to/host/config:/config  droplet
# docker ps -a -> find container id
# docker exec -it <CONTAINER ID> /bin/bash
# tmux attach-session -t bot-session
