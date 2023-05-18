# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="ryeager12@gmail.com"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for Liquor Tracker Backend."

WORKDIR /opt
COPY ./wait_for_input.sh wait_for_input.sh
RUN chmod +x wait_for_input.sh

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt-get update
RUN apt install -y git daemon openssh-client python3-pip python3-testresources python3-venv python3-gpg nginx nmap net-tools
RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

# Variables
ENV HOME_DIR=/home/droplet
ENV REPO_NAME=whiskey_inventory_alert_upwork
ENV REPO_DIR=${HOME_DIR}/${REPO_NAME}
ENV REPO_GITHUB=git@github.com:droneshire/whiskey_inventory_alert_upwork.git
ENV DROPBOX_DIR=~/Dropbox/droplet_bot
ENV EMAIL=test@gmail.com
ENV KEY_NAME=${HOME_DIR}/.ssh/id_ed25519_${REPO_NAME}
ENV TMP_GITHUB_KEY="/tmp/githubKey"
ENV KEYS_DIR=${HOME_DIR}/.ssh

VOLUME ${KEYS_DIR}
# RUN ssh-keygen -t ed25519 -C ${EMAIL} -f ${KEY_NAME} -q -N ""

RUN ssh-keyscan github.com >> ${TMP_GITHUB_KEY}
RUN ssh-keygen -lf ${TMP_GITHUB_KEY}
RUN echo ${TMP_GITHUB_KEY} >> ~/.ssh/known_hosts
RUN echo ${TMP_GITHUB_KEY}
RUN ssh-add ${KEY_NAME}

WORKDIR ${HOME_DIR}
RUN mkdir -p ${HOME_DIR}
RUN mkdir -p ${HOME_DIR}/logs
RUN mkdir -p ${HOME_DIR}/logs/bot
RUN mkdir -p ${HOME_DIR}/logs/server

# add deploy keys to github
RUN echo "Add the following deploy key to the github repo"
RUN cat ${KEY_NAME}.pub
RUN wait_for_input.sh

RUN git clone ${REPO_GITHUB} ${REPO_DIR}

RUN mkdir -p /tmp/dropbox
RUN mkdir -p /opt/dropbox
RUN wget -O /tmp/dropbox/dropbox.tar.gz "https://www.dropbox.com/download?plat=lnx.x86_64"
RUN tar xzfv /tmp/dropbox/dropbox.tar.gz --strip 1 -C /opt/dropbox
RUN /opt/dropbox/dropboxd&

RUN echo "Connect your Dropbox account"
RUN wait_for_input.sh


RUN curl -o /etc/init.d/dropbox https://gist.githubusercontent.com/thisismitch/6293d3f7f5fa37ca6eab/raw/2b326bf77368cbe5d01af21c623cd4dd75528c3d/dropbox
RUN curl -o /etc/systemd/system/dropbox.service https://gist.githubusercontent.com/thisismitch/6293d3f7f5fa37ca6eab/raw/99947e2ef986492fecbe1b7bfbaa303fefc42a62/dropbox.service
RUN chmod +x /etc/systemd/system/dropbox.service /etc/init.d/dropbox

RUN mkdir -p /etc/sysconfig
RUN echo "DROPBOX_USERS=\"`whoami`\"" > /etc/sysconfig/dropbox

## Create ubuntu version of /etc/systemd/system/dropbox:
COPY dropbox /etc/systemd/system/dropbox
RUN chmod +x /etc/systemd/system/dropbox

## Modify /etc/systemd/system/dropbox.service:
COPY dropbox.service /etc/systemd/system/dropbox.service

# enable systemd service
RUN systemctl daemon-reload
RUN systemctl start dropbox
RUN systemctl enable dropbox

# install dropbox cli
WORKDIR ${HOME_DIR}

RUN wget -P ~/ -O dropbox.py https://www.dropbox.com/download?dl=packages/dropbox.py
RUN chmod +x ~/dropbox.py
RUN ln -s /opt/dropbox ~/.dropbox-dist

# copy logs dir if needed (should be in dropbox)
# copy config and credentials files
RUN echo "Please copy the config and credentials files to your dropbox folder"
RUN wait_for_input.sh

RUN mkdir -p ${DROPBOX_DIR}/logs

COPY setup_env.sh setup_env.sh
RUN chmod +x setup_env.sh
RUN ./setup_env.sh

RUN ln -s ${DROPBOX_DIR}/logs ${REPO_DIR}/logs
RUN ln -s ${DROPBOX_DIR}/firebase_service_account.json ${REPO_DIR}/firebase_service_account.json

RUN ln -s ${DROPBOX_DIR}/.env ${REPO_DIR}/.env

RUN python3 -m pip install --user virtualenv
RUN pip install wheel

# alias the repo dir to .bashrc
RUN echo "alias inventory_bot_dir='cd $REPO_DIR'" >> ~/.bashrc
RUN source ~/.bashrc

RUN tmux new -s bot-session &

RUN echo "Exit this session using `Ctrl+B, D`, and then run 'tmux attach -t bot-session' to reattach"

RUN tmux split-window -t bot-session:0 -v
RUN tmux send-keys -t bot-session:0.0 "inventory_bot_dir; make init; make install; make inventory_bot_prod" C-m
RUN tmux send-keys -t bot-session:0.1 "inventory_bot_dir; make reset_server" C-m
