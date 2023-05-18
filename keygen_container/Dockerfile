FROM ubuntu:latest
RUN apt update
RUN apt-get -y install openssh-client
CMD ssh-keygen -q -t rsa -N '' -f /keys/id_rsa
