# RUN BELOW COMMANDs FROM THE FOLDER WHERE THIS "Dockerfile" IS SAVED, THIS WILL CREATE A DOCKER CONTAINER BASED ON UBUNTU 24/04 AND INSTALL PYTHON, GIT AND OTHER PACKAGES/DEPENDENCIES

# docker build -t netauto:latest .  --> BUILDS A NEW DOCKER IMAGE BASED ON THE "Dockerfile" CONTENTS (DOT '.' IS REQUIRED)
# docker run -dit --name netauto -v /home/adheer/netauto-repo:/netauto-repo --network host netauto:latest    --> CREATES AND STARTS A NEW CONTAINER FROM SPECIFIED IMAGE "netauto:latest"
# docker run -dit --name netauto -v /mnt/c/Users/<USENAME>/netauto-repo:/netauto-repo --network host netauto:latest .  --> FOR WINDOWS WSL
# docker start netauto  --> STARTS/RESTARTS AN EXISTING CONTAINER NAMED "netauto"
# docker exec -it netauto bash   --> OPENS AN INTERACTIVE BASH SHELL INSIDE THE RUNNING CONTAINER

# other docker commands
# sudo docker images
# sudo docker rmi -f netauto:latest
# sudo docker system prune

# misc commands
# 1  ansible-galaxy collection list --format yaml > collections_installed.yaml
# 2  cat collections_installed.yaml
# 3  cat requirements.txt
# 4  grep -A1 -E "cisco.ios:|ansible.netcommon:|ansible.utils:" collections_installed.yaml
# 5  touch requirements.yml
# 6  vim requirements.yml
# 7  grep -iE "^(ansible|ansible-core|ansible-pylibssh|ncclient|paramiko|pyats|genie|jinja2|netaddr|xmltodict|lxml)==" requirements.txt

FROM ubuntu:24.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# System packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    openssh-client \
    sshpass \
    vim \
    netcat-openbsd \
    curl \
    wget \
    net-tools \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Python packages, pinned to the versions tested on Cat9kv IOS-XE 17.10 (October 2026).
# To upgrade: change versions in requirements.txt, rebuild, and re-test in the lab.
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --break-system-packages -r /tmp/requirements.txt

# Ansible collections, pinned (cisco.ios, ansible.netcommon, ansible.utils)
COPY requirements.yml /tmp/requirements.yml
RUN ansible-galaxy collection install -r /tmp/requirements.yml

# Working directory where the repo is mounted (must match the docker run -v target)
WORKDIR /netauto-repo

CMD ["/bin/bash"]

RUN git config --global --add safe.directory /netauto-repo
