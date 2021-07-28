FROM ubuntu:18.04

RUN bash -c 'echo $(whoami)'
RUN apt-get update
RUN apt-get install python3.8 python3-pip curl -y

RUN python3.8 --version
RUN which python3.8
RUN python3 --version

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get install -y nodejs
RUN bash -c 'node --version'
RUN npm install -g npm@7.20.0
RUN bash -c 'npm --version'

# install docker
RUN apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \ 
    software-properties-common \
    lsb-release -y

RUN echo $(uname -m)
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

RUN apt-get update
RUN apt-get install docker-ce docker-ce-cli containerd.io -y
RUN service docker start

# add a mercury user and give it permission for source code
RUN useradd -ms /bin/bash mercury
WORKDIR /home/mercury

RUN mkdir src/

# Set up supervisor
RUN apt-get install supervisor -y

USER mercury

# Setting up orchestration
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python3.8 -
ENV PATH="${PATH}:/home/mercury/.poetry/bin"
RUN poetry --version

COPY --chown=mercury:mercury orchestration /home/mercury/src/orchestration
WORKDIR /home/mercury/src/orchestration
ENV PYTHONIOENCODING=utf8
RUN poetry install
WORKDIR /home/mercury

# Setting up workspace
COPY --chown=mercury:mercury gateway /home/mercury/src/workspace
WORKDIR /home/mercury/src/workspace
RUN npm install
WORKDIR /home/mercury

# Setting up gateway
COPY --chown=mercury:mercury gateway /home/mercury/src/gateway
WORKDIR /home/mercury/src/gateway
RUN npm install
WORKDIR /home/mercury

# Setting up mercury
COPY --chown=mercury:mercury mercury /home/mercury/src/mercury
WORKDIR /home/mercury/src/mercury
RUN npm --version
RUN npm install
WORKDIR /home/mercury

ADD supervisord.conf /etc/supervisor/supervisord.conf 
# We will run entrypoint sh as root to allow root of container to give permission of 
# docker socket to user mercury, the entrypoint file then runs supervisor as user mercury
USER root
RUN chown -R mercury:mercury /var/log/supervisor
COPY entrypoint.sh /home/mercury/entrypoint.sh

# for mercury frontend
EXPOSE 5000
# for gateway cors
EXPOSE 3000
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
