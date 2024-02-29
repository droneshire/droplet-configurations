#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo "Error: REPO_NAME argument is required."
    exit 1
fi


wait_for_input() {
    echo "Press any key to continue"
    set +e
    while [ true ] ; do
        read -t 3 -n 1
        if [ $? = 0 ] ; then
            break
        else
            echo "waiting for the keypress"
        fi
    done
    set -e
}

THIS_DIR=`pwd`
HOME_DIR=$HOME/droplet


REPO_NAME=$1
REPO_DIR=$HOME_DIR/$REPO_NAME
ROOT_DIR=/root

REPO_GITHUB=git@github.com:droneshire/$REPO_NAME.git

echo -e "${GREEN}Setting up the droplet${NC}"

PACKAGES="\
git \
daemon \
python3-pip \
python3-testresources \
python3-venv \
python3-gpg \
nginx \
nmap \
net-tools \
ca-certificates \
curl \
gnupg \
lsb-release \
tmux \
build-essential \
make \
protobuf-compiler \
"


echo -e "${GREEN}Installing packages${NC}"
echo -e "${BLUE}Packages: $PACKAGES${NC}"
apt -y update
apt -y install $PACKAGES

echo -e "${GREEN}Setting up SSH${NC}"
SSH_KEY=~/.ssh/id_ed25519
KEYADD_WAIT=false
if [ ! -f $SSH_KEY ]; then
    ssh-keygen -t ed25519 -C $REPO_NAME -f $SSH_KEY -q -N ""
    KEYADD_WAIT=true
fi
TMP_GITHUB_KEY=/tmp/githubKey
ssh-keyscan github.com >> $TMP_GITHUB_KEY
ssh-keygen -lf $TMP_GITHUB_KEY
echo $TMP_GITHUB_KEY >> ~/.ssh/known_hosts

# Clear all old keys
ssh-add -D || eval "$(ssh-agent -s)" > /dev/null
# Add the new key
ssh-add $SSH_KEY



mkdir $HOME_DIR || true
cd $HOME_DIR

ssh-add -L

# Add the ssh key to read only Deploy Key on Github
echo -e "${GREEN}Add the ssh key to github${NC}"

if [ "$KEYADD_WAIT" = true ]; then
    wait_for_input
else
    echo -e "${BLUE}Key already in github${NC}"
fi


echo -e "${GREEN}Cloning the repo${NC}"
rm -rf $REPO_DIR || true
git clone $REPO_GITHUB $REPO_DIR

cd $REPO_DIR
mkdir -p ./logs || true

git clean -df
git reset --hard
git checkout main
git pull

echo -e "${GREEN}Setting up the repo${NC}"
make clean || true
make init
source ./venv/bin/activate
make install
deactivate

echo -e "${GREEN}Setting up tmux${NC}"

TMUX_SESSION_NAME=$REPO_NAME-session
tmux kill-session -t $TMUX_SESSION_NAME || true
tmux new -d -s $TMUX_SESSION_NAME
tmux split-window -t $TMUX_SESSION_NAME:0 -v
tmux send-keys -t $TMUX_SESSION_NAME:0.0 "cd $REPO_DIR; echo 'New terminal'; source ./venv/bin/activate" C-m
tmux send-keys -t $TMUX_SESSION_NAME:0.1 "cd $REPO_DIR; echo 'New terminal'; source ./venv/bin/activate" C-m

echo -e "${GREEN}Run 'tmux attach -t $TMUX_SESSION_NAME' to reattach${NC}"
echo -e "${BLUE}To exit a tmux session use `Ctrl+B, D`${NC}"

echo -e "${GREEN}SETUP COMPLETE! Exiting...${NC}"
