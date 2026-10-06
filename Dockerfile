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

# Automation stack - unpinned for now, so pip always resolves valid current versions.
# Once this builds successfully, run `pip3 show ansible netmiko napalm pyats genie`
# inside the container and pin these to the exact versions that worked, for
# long-term reproducibility.
RUN pip3 install --break-system-packages \
    ansible \
    netmiko \
    napalm \
    pyats[full] \
    genie \
    ansible-pylibssh

# Cisco Ansible collections
RUN ansible-galaxy collection install \
    cisco.ios \
    cisco.nxos \
    cisco.iosxr

# Working directory where the templates/playbooks repo will be mounted
WORKDIR /netauto-repo

CMD ["/bin/bash"]

