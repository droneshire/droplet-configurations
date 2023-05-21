FROM ubuntu:latest

RUN apt update
RUN apt-get -y install openssh-client

ARG KEY_SUFFIX_ARG
ARG KEY_DIR_ARG=/keys

ENV KEY_SUFFIX ${KEY_SUFFIX_ARG}
ENV KEY_DIR ${KEY_DIR_ARG}

RUN mkdir -p ${KEY_DIR}
RUN mkdir -p ~/.ssh

VOLUME ${KEY_DIR}

RUN echo "KEY_SUFFIX is ${KEY_SUFFIX}" >> ${KEY_DIR}/key_suffix.txt
RUN echo "KEY_DIR is ${KEY_DIR}" >> ${KEY_DIR}/key_dir.txt
RUN echo "TESTING" >> ${KEY_DIR}/testing.txt

CMD ssh-keygen -q -t ed25519 -N '' -f ${KEY_DIR}/id_ed25519_${KEY_SUFFIX}

RUN echo docker build -t keygen_container --build-arg KEY_SUFFIX=droplet .
