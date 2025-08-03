
FROM ubuntu:jammy
RUN apt-get update && \
	apt-get install -y \
	curl \
	wget \
	nano \
	sudo \
	apt-transport-https && \ 
	curl -fsSL https://get.docker.com/ | sh -s -

RUN sudo useradd -G docker coder   
RUN echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

# Add our onCreateCommand script.
ADD on-create.sh /on-create.sh
RUN chmod 755 /on-create.sh
USER coder

ENTRYPOINT ["bash"]
