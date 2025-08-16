
FROM ubuntu:jammy
RUN apt-get update && \
	apt-get install -y \
	curl \
	wget \
	nano \
	sudo \
	apt-transport-https && \ 
	curl -fsSL https://get.docker.com/ | sh -s -

# Create 'coder' user with home directory and Docker group
RUN useradd -m -s /bin/bash -G docker coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder && \
    chown -R coder:coder /home/coder

USER coder

ENTRYPOINT ["bash"]