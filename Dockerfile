FROM python:3.11-slim-bookworm
# ARG NODE_VERSION=24

# Install common pre-reqs
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y gnupg wget curl git unzip bash jq

# # Install NVM and Node.js
# RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
# ENV NVM_DIR=/root/.nvm
# RUN bash -c "source $NVM_DIR/nvm.sh && nvm install $NODE_VERSION"

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash
RUN apt-get install -y nodejs
RUN node -v
# RUN \
#  echo "deb https://deb.nodesource.com/node_20.x bullseye main" > /etc/apt/sources.list.d/nodesource.list && \
#  wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
#  apt-get update
# RUN apt-get install -y nodejs
# RUN npm install --global npm jq commander

# Install SF CLI
RUN npm install --global @salesforce/cli --ignore-scripts

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt-get install -y gh

# Install PowerShell
RUN apt-get install -y apt-transport-https software-properties-common
WORKDIR /tmp
RUN . /etc/os-release && wget -q https://packages.microsoft.com/config/debian/$VERSION_ID/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN rm packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y powershell

# Install Salesforce Code Analyzer:
RUN sf plugins install code-analyzer

# Install CumulusCI
RUN pip install --no-cache-dir --upgrade pip pip-tools
RUN pip --no-cache-dir install docutils
RUN pip --no-cache-dir install cumulusci

# Copy devhub auth script and make it executable
COPY devhub.sh /usr/local/bin/devhub.sh
RUN chmod +x /usr/local/bin/devhub.sh

# Create d2x user
RUN useradd -r -m -s /bin/bash -c "D2X User" d2x

# Setup PATH
RUN echo 'export PATH=~/.local/bin:$PATH' >> /root/.bashrc
RUN echo 'export PATH=~/.local/bin:$PATH' >> /home/d2x/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /root/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /home/d2x/.bashrc

# USER d2x
# ENTRYPOINT ["bash", "-c", "source $NVM_DIR/nvm.sh && exec \"$@\"", "--"]
CMD ["bash"]
