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

# add a mercury user and give it permission for source code
RUN useradd -ms /bin/bash mercury

# switch user from root
USER mercury
WORKDIR /home/mercury
RUN mkdir src/

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
COPY --chown=mercury:mercury gateway /home/mercury/src/mercury
WORKDIR /home/mercury/src/mercury
RUN npm --version
RUN npm install
WORKDIR /home/mercury



