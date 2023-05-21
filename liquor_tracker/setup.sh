#!/bin/bash

HOME_DIR=$HOME
KEY_DIR=$1
REPO_GITHUB=$2
REPO_NAME=$(echo $REPO_GITHUB | cut -d'/' -f2 | cut -d'.' -f1)

echo "Repo name: $REPO_NAME, from repo: $REPO_GITHUB"

if [ ! -d "$KEY_DIR" ]; then
    echo "Please mount your keys directory to $KEY_DIR"
    exit 1
fi

echo "alias repo_dir='cd $REPO_DIR'" >> ${HOME_DIR}.bashrc

echo "Using key directory: $KEY_DIR"
echo "Using key: $KEY_DIR/id_ed25519_$REPO_NAME"
cat $KEY_DIR/id_ed25519_$REPO_NAME.pub

eval "$(ssh-agent)"

cp $KEY_DIR/id_ed25519_$REPO_NAME $HOME_DIR/.ssh/id_ed25519_$REPO_NAME
cp $KEY_DIR/id_ed25519_$REPO_NAME.pub $HOME_DIR/.ssh/id_ed25519_$REPO_NAME.pub
chmod 600 $HOME_DIR/.ssh/id_ed25519_$REPO_NAME
chmod 600 $HOME_DIR/.ssh/id_ed25519_$REPO_NAME.pub

ssh-add $HOME_DIR/.ssh/id_ed25519_$REPO_NAME

echo "Cloning repo: $REPO_GITHUB to $REPO_DIR"

git clone $REPO_GITHUB $REPO_DIR

# alias the repo dir to .bashrc
echo "alias inventory_bot_dir='cd $REPO_DIR'" >> ~/.bashrc
source ~/.bashrc

tmux new -s bot-session &

tmux split-window -t bot-session:0 -v
tmux send-keys -t bot-session:0.0 "inventory_bot_dir; make init; make install; make inventory_bot_prod" C-m
tmux send-keys -t bot-session:0.1 "inventory_bot_dir; make reset_server" C-m

echo "Exit this session using `Ctrl+B, D`, and then run 'tmux attach -t bot-session' to reattach"
sleep 2
