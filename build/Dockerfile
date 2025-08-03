FROM mcr.microsoft.com/devcontainers/python:1-3.12
RUN apt-get update && apt-get install -y curl wget sudo

RUN curl -fsSL https://get.docker.com/ | sh -s -

RUN useradd -m -s /bin/bash -G sudo coder
# Let's add a fancy prompt!
RUN echo "PS1='🐳 \[\033[1;36m\]\h \[\033[1;34m\]\W\[\033[0;35m\] \[\033[1;36m\]# \[\033[0m\]'" > /home/coder/.bashrc && \
    chown coder:coder /home/coder/.bashrc

# Add our onCreateCommand script.
ADD on-create.sh /on-create.sh

USER coder

RUN pip3 install pyyaml crewai
