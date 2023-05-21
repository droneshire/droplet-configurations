FROM ubuntu:latest

# LABEL about the custom image
LABEL maintainer="ryeager12@gmail.com"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for Liquor Tracker Backend."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt-get update
RUN apt install -y git wget systemd daemon openssh-client python3-pip python3-testresources python3-venv python3-gpg nginx nmap net-tools
RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

ARG KEYS_DIR_ARG=/keys

# Variables
ENV HOME_DIR /root
ENV KEYS_DIR ${KEYS_DIR_ARG}
ENV EMAIL test@gmail.com
ENV TMP_GITHUB_KEY "/tmp/githubKey"
ENV SSH_DIR ${HOME_DIR}/.ssh
ENV GITHUB_REPO_FILE=${HOME_DIR}/.github_repo
RUN mkdir -p ${SSH_DIR} && chmod 700 ${SSH_DIR}


COPY .github_repo ${GITHUB_REPO_FILE}
COPY ./config ${SSH_DIR}/config

RUN ssh-keyscan github.com >> $TMP_GITHUB_KEY
RUN ssh-keygen -lf $TMP_GITHUB_KEY
RUN echo $TMP_GITHUB_KEY >> ${SSH_DIR}/known_hosts

WORKDIR ${HOME_DIR}

VOLUME ${KEYS_DIR}

RUN python3 -m pip install --user virtualenv
RUN pip install wheel

ENV PATH="${PATH}:${HOME_DIR}/.local/bin:${HOME_DIR}"

WORKDIR ${HOME_DIR}

COPY ./setup.sh ${HOME_DIR}/setup.sh
RUN chmod +x ${HOME_DIR}/setup.sh

COPY ./wait_for_input.sh wait_for_input.sh
RUN chmod +x wait_for_input.sh

CMD ["sh", "-c", "${HOME_DIR}/setup.sh ${KEYS_DIR} ${REPO_NAME} `cat ${GITHUB_REPO_FILE}`"]
